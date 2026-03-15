import 'package:flutter/material.dart';
import '../data/firebase_state.dart';
import '../l10n/app_localizations.dart';
import '../data/seat_sync_service.dart';
import '../models/booking_record.dart';
import '../widgets/language_toggle_button.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return "$y-$m-$d $hh:$mm";
  }

  Future<void> _cancelBooking(BookingRecord booking) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelBookingTitle),
        content: Text(l10n.cancelBookingQuestion(booking.centerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yesCancel),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    bool isCanceled = false;
    try {
      isCanceled = await SeatSyncService.cancelBooking(booking);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      return;
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCanceled ? l10n.bookingCanceled : l10n.bookingAlreadyCanceled,
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!firebaseAvailable) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.bookingHistoryTitle),
          actions: const [LanguageToggleButton()],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.authFirebaseNotInitialized,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingHistoryTitle),
        actions: const [LanguageToggleButton()],
      ),
      body: StreamBuilder<List<BookingRecord>>(
        stream: SeatSyncService.bookingHistoryStream(),
        initialData: const <BookingRecord>[],
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <BookingRecord>[];
          if (items.isEmpty) {
            return Center(
              child: Text(
                l10n.noBookingHistory,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final booking = items[index];
              final seats = booking.seatIndexes.map((e) => "PC ${e + 1}").join(", ");

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.centerName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              booking.isCanceled
                                  ? l10n.statusCanceled
                                  : l10n.statusActive,
                            ),
                            backgroundColor: booking.isCanceled
                                ? Colors.red.withValues(alpha: 0.2)
                                : Colors.green.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(l10n.customerLabel(booking.customerName)),
                      Text(l10n.phoneLabel(booking.phone)),
                      Text(l10n.durationLabel(booking.durationHours)),
                      Text(l10n.pricePerHourLabel(booking.pricePerHour)),
                      Text(l10n.seatsLabel(seats)),
                      Text(
                        l10n.totalPriceLabel(booking.totalPrice),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(l10n.createdLabel(_formatDate(booking.createdAt))),
                      if (booking.isCanceled && booking.canceledAt != null)
                        Text(l10n.canceledLabel(_formatDate(booking.canceledAt!))),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: booking.isCanceled
                              ? null
                              : () => _cancelBooking(booking),
                          child: Text(l10n.cancelBookingAction),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
