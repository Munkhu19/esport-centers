import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_record.dart';
import 'booking_store.dart';
import 'firebase_state.dart';

class SeatUnavailableException implements Exception {
  final String message;
  SeatUnavailableException(this.message);

  @override
  String toString() => message;
}

class SeatSyncService {
  static Stream<Set<int>> bookedSeatsStream({required String centerId}) {
    return BookingStore.bookedSeatsStream(centerId);
  }

  static Stream<Set<int>> blockedSeatsStream({required String centerId}) {
    return BookingStore.blockedSeatsStream(centerId);
  }

  static Future<BookingRecord> confirmBooking({
    required String centerId,
    required String centerName,
    required String customerName,
    required String phone,
    required int durationHours,
    required int pricePerHour,
    required int graceMinutes,
    required DateTime startAt,
    required List<int> seatIndexes,
  }) async {
    final booked = BookingStore.bookedSeats(centerId);
    final blocked = BookingStore.blockedSeats(centerId);
    for (final seat in seatIndexes) {
      if (booked.contains(seat)) {
        throw SeatUnavailableException('PC ${seat + 1} is already booked.');
      }
      if (blocked.contains(seat)) {
        throw SeatUnavailableException('PC ${seat + 1} is blocked.');
      }
    }

    final selected = BookingStore.selectedSeats(centerId);
    selected
      ..clear()
      ..addAll(seatIndexes);

    final user = firebaseAvailable ? FirebaseAuth.instance.currentUser : null;

    return await BookingStore.confirmBooking(
      centerId: centerId,
      centerName: centerName,
      customerName: customerName,
      phone: phone,
      durationHours: durationHours,
      pricePerHour: pricePerHour,
      graceMinutes: graceMinutes,
      startAt: startAt,
      createdByUid: user?.uid,
      createdByEmail: user?.email,
    );
  }

  static Stream<List<BookingRecord>> bookingHistoryStream() {
    if (!firebaseAvailable) {
      return BookingStore.bookingHistoryStream().map(
        (_) => BookingStore.bookingHistory(),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    return BookingStore.bookingHistoryStream().map(
      (_) => BookingStore.bookingHistory(
        createdByUid: user?.uid,
        createdByEmail: user?.email,
      ),
    );
  }

  static Stream<List<BookingRecord>> ownerBookingHistoryStream({
    required Set<String> centerIds,
  }) {
    return BookingStore.bookingHistoryStream().map(
      (_) => BookingStore.bookingHistory().where(
        (booking) => centerIds.contains(booking.centerId),
      ).toList(growable: false),
    );
  }

  static Future<bool> cancelBooking(BookingRecord booking) async {
    return BookingStore.cancelBooking(booking.id);
  }
}
