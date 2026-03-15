import '../models/booking_record.dart';
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BookingStore {
  static const String _historyKey = 'booking_history_v1';
  static final Map<String, Set<int>> _selectedByCenter = {};
  static final Map<String, Set<int>> _bookedByCenter = {};
  static final Map<String, StreamController<Set<int>>> _bookedControllers = {};
  static final List<BookingRecord> _history = [];
  static bool _initialized = false;

  static StreamController<Set<int>> _bookedController(String centerId) {
    return _bookedControllers.putIfAbsent(centerId, () {
      late final StreamController<Set<int>> controller;
      controller = StreamController<Set<int>>.broadcast(
        onListen: () {
          controller.add(Set.unmodifiable(bookedSeats(centerId)));
        },
      );
      return controller;
    });
  }

  static void _emitBooked(String centerId) {
    final controller = _bookedControllers[centerId];
    if (controller == null || controller.isClosed) return;
    controller.add(Set.unmodifiable(bookedSeats(centerId)));
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
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final loaded = decoded
          .whereType<Map>()
          .map((e) => BookingRecord.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      // Migration: drop legacy records that have no owner info.
      final migrated = loaded
          .where(
            (item) =>
                (item.createdByUid?.isNotEmpty ?? false) ||
                (item.createdByEmail?.isNotEmpty ?? false),
          )
          .toList();

      _history
        ..clear()
        ..addAll(migrated);

      _bookedByCenter.clear();
      for (final item in _history) {
        if (item.isCanceled) continue;
        bookedSeats(item.centerId).addAll(item.seatIndexes);
      }

      for (final centerId in _bookedControllers.keys) {
        _emitBooked(centerId);
      }

      if (migrated.length != loaded.length) {
        await _saveToDisk();
      }
    } catch (_) {
      // Ignore malformed persisted data and continue with empty state.
    }
  }

  static Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_history.map((e) => e.toMap()).toList());
      await prefs.setString(_historyKey, encoded);
    } catch (_) {
      // Ignore persistence failures; in-memory state remains functional.
    }
  }

  static Set<int> selectedSeats(String centerId) {
    return _selectedByCenter.putIfAbsent(centerId, () => <int>{});
  }

  static Set<int> bookedSeats(String centerId) {
    return _bookedByCenter.putIfAbsent(centerId, () => <int>{});
  }

  static Stream<Set<int>> bookedSeatsStream(String centerId) {
    return _bookedController(centerId).stream;
  }

  static void toggleSeat(String centerId, int seatIndex) {
    final selected = selectedSeats(centerId);
    if (selected.contains(seatIndex)) {
      selected.remove(seatIndex);
    } else {
      selected.add(seatIndex);
    }
  }

  static BookingRecord confirmBooking({
    required String centerId,
    required String centerName,
    required String customerName,
    required String phone,
    required int durationHours,
    required int pricePerHour,
    String? createdByUid,
    String? createdByEmail,
  }) {
    final selected = selectedSeats(centerId);
    final booked = bookedSeats(centerId);
    final confirmed = selected.toList()..sort();

    booked.addAll(confirmed);
    selected.clear();
    _emitBooked(centerId);

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
      createdAt: DateTime.now(),
      createdByUid: createdByUid,
      createdByEmail: createdByEmail,
    );

    _history.insert(0, record);
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

  static bool cancelBooking(String bookingId) {
    final index = _history.indexWhere((item) => item.id == bookingId);
    if (index == -1) return false;

    final target = _history[index];
    if (target.isCanceled) return false;

    bookedSeats(target.centerId).removeAll(target.seatIndexes);
    selectedSeats(target.centerId).removeAll(target.seatIndexes);
    _history[index] = target.copyWith(
      isCanceled: true,
      canceledAt: DateTime.now(),
    );
    _emitBooked(target.centerId);
    unawaited(_saveToDisk());

    return true;
  }
}
