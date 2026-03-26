import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking_record.dart';

class BookingStore {
  static const String _historyKey = 'booking_history_v2';
  static const String _blockedKey = 'blocked_seats_v2';
  static final Map<String, Set<int>> _selectedByCenter = {};
  static final Map<String, Set<int>> _bookedByCenter = {};
  static final Map<String, Set<int>> _blockedByCenter = {};
  static final Map<String, StreamController<Set<int>>> _bookedControllers = {};
  static final Map<String, StreamController<Set<int>>> _blockedControllers = {};
  static final StreamController<List<BookingRecord>> _historyController =
      StreamController<List<BookingRecord>>.broadcast(onListen: _emitHistory);
  static final List<BookingRecord> _history = [];
  static bool _initialized = false;

  static StreamController<Set<int>> _bookedController(String centerId) {
    return _bookedControllers.putIfAbsent(centerId, () {
      late final StreamController<Set<int>> controller;
      controller = StreamController<Set<int>>.broadcast(
        onListen: () => controller.add(Set.unmodifiable(bookedSeats(centerId))),
      );
      return controller;
    });
  }

  static StreamController<Set<int>> _blockedController(String centerId) {
    return _blockedControllers.putIfAbsent(centerId, () {
      late final StreamController<Set<int>> controller;
      controller = StreamController<Set<int>>.broadcast(
        onListen: () => controller.add(Set.unmodifiable(blockedSeats(centerId))),
      );
      return controller;
    });
  }

  static void _emitBooked(String centerId) {
    final controller = _bookedControllers[centerId];
    if (controller == null || controller.isClosed) return;
    controller.add(Set.unmodifiable(bookedSeats(centerId)));
  }

  static void _emitBlocked(String centerId) {
    final controller = _blockedControllers[centerId];
    if (controller == null || controller.isClosed) return;
    controller.add(Set.unmodifiable(blockedSeats(centerId)));
  }

  static void _emitHistory() {
    if (_historyController.isClosed) return;
    _historyController.add(List.unmodifiable(_history));
  }

  static void _rebuildBookedSeats() {
    _bookedByCenter.clear();
    final now = DateTime.now();
    for (final item in _history) {
      if (item.isCanceled) continue;
      final isActiveNow = !item.startAt.isAfter(now) && item.endAt.isAfter(now);
      if (!isActiveNow) continue;
      bookedSeats(item.centerId).addAll(item.seatIndexes);
    }
  }

  static bool _hasOverlap({
    required DateTime startA,
    required DateTime endA,
    required DateTime startB,
    required DateTime endB,
  }) {
    return startA.isBefore(endB) && startB.isBefore(endA);
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _loadFromDisk();
  }

  static Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      final blockedRaw = prefs.getString(_blockedKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final loaded = decoded
          .whereType<Map>()
          .map((e) => BookingRecord.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      _history
        ..clear()
        ..addAll(loaded);

      _rebuildBookedSeats();

      _blockedByCenter.clear();
      if (blockedRaw != null && blockedRaw.isNotEmpty) {
        final blockedDecoded = jsonDecode(blockedRaw);
        if (blockedDecoded is Map<String, dynamic>) {
          for (final entry in blockedDecoded.entries) {
            final seats = (entry.value as List<dynamic>)
                .map((e) => int.tryParse(e.toString()) ?? -1)
                .where((e) => e >= 0)
                .toSet();
            _blockedByCenter[entry.key] = seats;
          }
        }
      }

      for (final centerId in _bookedControllers.keys) {
        _emitBooked(centerId);
      }
      for (final centerId in _blockedControllers.keys) {
        _emitBlocked(centerId);
      }

      _emitHistory();
    } catch (_) {}
  }

  static Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_history.map((e) => e.toMap()).toList());
      await prefs.setString(_historyKey, encoded);
      final blockedEncoded = jsonEncode(
        _blockedByCenter.map(
          (key, value) => MapEntry(key, value.toList()..sort()),
        ),
      );
      await prefs.setString(_blockedKey, blockedEncoded);
    } catch (_) {}
  }

  static Set<int> selectedSeats(String centerId) {
    return _selectedByCenter.putIfAbsent(centerId, () => <int>{});
  }

  static Set<int> bookedSeats(String centerId) {
    return _bookedByCenter.putIfAbsent(centerId, () => <int>{});
  }

  static Set<int> blockedSeats(String centerId) {
    return _blockedByCenter.putIfAbsent(centerId, () => <int>{});
  }

  static Stream<Set<int>> bookedSeatsStream(String centerId) {
    return _bookedController(centerId).stream;
  }

  static Stream<Set<int>> blockedSeatsStream(String centerId) {
    return _blockedController(centerId).stream;
  }

  static Stream<List<BookingRecord>> bookingHistoryStream() {
    return _historyController.stream;
  }

  static void toggleSeat(String centerId, int seatIndex) {
    final selected = selectedSeats(centerId);
    if (blockedSeats(centerId).contains(seatIndex)) return;
    if (selected.contains(seatIndex)) {
      selected.remove(seatIndex);
    } else {
      selected.add(seatIndex);
    }
  }

  static bool toggleBlockedSeat(String centerId, int seatIndex) {
    final blocked = blockedSeats(centerId);
    if (bookedSeats(centerId).contains(seatIndex)) return false;

    if (blocked.contains(seatIndex)) {
      blocked.remove(seatIndex);
    } else {
      blocked.add(seatIndex);
      selectedSeats(centerId).remove(seatIndex);
    }

    _emitBlocked(centerId);
    unawaited(_saveToDisk());
    return true;
  }

  static Future<BookingRecord> confirmBooking({
    required String centerId,
    required String centerName,
    required String customerName,
    required String phone,
    required int durationHours,
    required int pricePerHour,
    required DateTime startAt,
    String? createdByUid,
    String? createdByEmail,
  }) async {
    final selected = selectedSeats(centerId);
    final blocked = blockedSeats(centerId);
    final confirmed = selected.toList()..sort();
    final endAt = startAt.add(Duration(hours: durationHours));

    if (confirmed.any(blocked.contains)) {
      throw Exception('One or more selected seats are blocked.');
    }
    for (final item in _history) {
      if (item.isCanceled || item.centerId != centerId) continue;
      if (!item.seatIndexes.any(confirmed.contains)) continue;
      if (_hasOverlap(
        startA: startAt,
        endA: endAt,
        startB: item.startAt,
        endB: item.endAt,
      )) {
        final seats = item.seatIndexes
            .where(confirmed.contains)
            .map((seat) => 'PC ${seat + 1}')
            .join(', ');
        throw Exception('$seats already booked for that time.');
      }
    }

    final totalPrice = confirmed.length * durationHours * pricePerHour;
    final record = BookingRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      centerId: centerId,
      centerName: centerName,
      customerName: customerName,
      phone: phone,
      durationHours: durationHours,
      pricePerHour: pricePerHour,
      totalPrice: totalPrice,
      seatIndexes: confirmed,
      startAt: startAt,
      createdAt: DateTime.now(),
      createdByUid: createdByUid,
      createdByEmail: createdByEmail,
    );

    selected.clear();
    _history.insert(0, record);
    _rebuildBookedSeats();
    for (final emittedCenterId in _bookedControllers.keys) {
      _emitBooked(emittedCenterId);
    }
    _emitHistory();
    unawaited(_saveToDisk());
    return record;
  }

  static List<BookingRecord> bookingHistory({
    String? centerId,
    String? createdByUid,
    String? createdByEmail,
  }) {
    Iterable<BookingRecord> items = _history;
    if (centerId != null) {
      items = items.where((item) => item.centerId == centerId);
    }
    if (createdByUid != null && createdByUid.isNotEmpty) {
      items = items.where((item) => item.createdByUid == createdByUid);
    } else if (createdByEmail != null && createdByEmail.isNotEmpty) {
      items = items.where((item) => item.createdByEmail == createdByEmail);
    }
    return List.unmodifiable(items);
  }

  static Set<int> scheduledBookedSeats({
    required String centerId,
    required DateTime startAt,
    required int durationHours,
  }) {
    final endAt = startAt.add(Duration(hours: durationHours));
    final result = <int>{};
    for (final item in _history) {
      if (item.isCanceled || item.centerId != centerId) continue;
      if (_hasOverlap(
        startA: startAt,
        endA: endAt,
        startB: item.startAt,
        endB: item.endAt,
      )) {
        result.addAll(item.seatIndexes);
      }
    }
    return result;
  }

  static Future<bool> cancelBooking(String bookingId) async {
    final index = _history.indexWhere((item) => item.id == bookingId);
    if (index == -1) return false;

    final target = _history[index];
    if (target.isCanceled) return false;

    selectedSeats(target.centerId).removeAll(target.seatIndexes);
    _history[index] = target.copyWith(
      isCanceled: true,
      canceledAt: DateTime.now(),
    );
    _rebuildBookedSeats();
    for (final centerId in _bookedControllers.keys) {
      _emitBooked(centerId);
    }
    _emitHistory();
    unawaited(_saveToDisk());
    return true;
  }

  static Future<void> clearBookingsForCenters(Set<String> centerIds) async {
    if (centerIds.isEmpty) return;
    _history.removeWhere((item) => centerIds.contains(item.centerId));
    for (final centerId in centerIds) {
      selectedSeats(centerId).clear();
    }
    _rebuildBookedSeats();
    for (final centerId in _bookedControllers.keys) {
      _emitBooked(centerId);
    }
    _emitHistory();
    await _saveToDisk();
  }

  static Future<void> removeCenters(Set<String> centerIds) async {
    if (centerIds.isEmpty) return;
    _history.removeWhere((item) => centerIds.contains(item.centerId));
    for (final centerId in centerIds) {
      _selectedByCenter.remove(centerId);
      _bookedByCenter.remove(centerId);
      _blockedByCenter.remove(centerId);
      _emitBooked(centerId);
      _emitBlocked(centerId);
    }
    _rebuildBookedSeats();
    for (final centerId in _bookedControllers.keys) {
      _emitBooked(centerId);
    }
    for (final centerId in _blockedControllers.keys) {
      _emitBlocked(centerId);
    }
    _emitHistory();
    await _saveToDisk();
  }

  static Future<void> removeBookingsByCreator({
    String? createdByUid,
    String? createdByEmail,
  }) async {
    final beforeCount = _history.length;
    _history.removeWhere((item) {
      if (createdByUid != null && createdByUid.isNotEmpty) {
        return item.createdByUid == createdByUid;
      }
      if (createdByEmail != null && createdByEmail.isNotEmpty) {
        return item.createdByEmail == createdByEmail;
      }
      return false;
    });
    if (_history.length == beforeCount) return;
    _rebuildBookedSeats();
    for (final centerId in _bookedControllers.keys) {
      _emitBooked(centerId);
    }
    _emitHistory();
    await _saveToDisk();
  }

  static Future<void> clearCanceledBookingsForCenters(Set<String> centerIds) async {
    if (centerIds.isEmpty) return;
    final beforeCount = _history.length;
    _history.removeWhere(
      (item) => item.isCanceled && centerIds.contains(item.centerId),
    );
    if (_history.length == beforeCount) return;
    _rebuildBookedSeats();
    for (final centerId in _bookedControllers.keys) {
      _emitBooked(centerId);
    }
    _emitHistory();
    await _saveToDisk();
  }

  static Future<void> clearCanceledBookings({
    String? createdByUid,
    String? createdByEmail,
  }) async {
    final beforeCount = _history.length;
    _history.removeWhere((item) {
      if (!item.isCanceled) return false;
      if (createdByUid != null && createdByUid.isNotEmpty) {
        return item.createdByUid == createdByUid;
      }
      if (createdByEmail != null && createdByEmail.isNotEmpty) {
        return item.createdByEmail == createdByEmail;
      }
      return false;
    });
    if (_history.length == beforeCount) return;
    _rebuildBookedSeats();
    for (final centerId in _bookedControllers.keys) {
      _emitBooked(centerId);
    }
    _emitHistory();
    await _saveToDisk();
  }
}
