import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/booking_store.dart';
import '../data/center_store.dart';
import '../data/firebase_state.dart';
import '../l10n/app_localizations.dart';
import '../models/booking_record.dart';
import '../widgets/language_toggle_button.dart';

enum _OwnerBookingFilter {
  all,
  active,
  canceled,
}

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  _OwnerBookingFilter _filter = _OwnerBookingFilter.all;

  String _normalizeText(String value) {
    return value.trim().toLowerCase();
  }

  bool _isOwnedBooking(
    BookingRecord booking,
    Set<String> ownedCenterIds,
    Set<String> ownedCenterNames,
  ) {
    if (ownedCenterIds.contains(booking.centerId)) {
      return true;
    }
    return ownedCenterNames.contains(_normalizeText(booking.centerName));
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  String _formatSchedule(BookingRecord booking) {
    return '${_formatDate(booking.startAt)} - ${_formatDate(booking.endAt)}';
  }

  List<BookingRecord> _sortBookings(List<BookingRecord> items) {
    final sorted = items.toList(growable: false);
    sorted.sort((a, b) {
      final aDate = a.canceledAt ?? a.createdAt;
      final bDate = b.canceledAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ownerEmail = firebaseAvailable ? FirebaseAuth.instance.currentUser?.email : null;

    return ValueListenableBuilder(
      valueListenable: CenterStore.centersNotifier,
      builder: (context, value, child) {
        final ownedCenterIds = CenterStore.ownedBy(ownerEmail).map((e) => e.id).toSet();
        final ownedCenterNames = CenterStore.ownedBy(ownerEmail)
            .map((e) => _normalizeText(e.name))
            .toSet();

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.ownerBookingsTitle),
            actions: const [LanguageToggleButton()],
          ),
          body: StreamBuilder<List<BookingRecord>>(
            stream: BookingStore.bookingHistoryStream(),
            initialData: BookingStore.bookingHistory(),
            builder: (context, snapshot) {
              final allItems = (snapshot.data ?? const <BookingRecord>[])
                  .where(
                    (booking) => _isOwnedBooking(
                      booking,
                      ownedCenterIds,
                      ownedCenterNames,
                    ),
                  )
                  .toList(growable: false);
              final sortedItems = _sortBookings(allItems);
              final items = sortedItems.where((booking) {
                switch (_filter) {
                  case _OwnerBookingFilter.active:
                    return !booking.isCanceled;
                  case _OwnerBookingFilter.canceled:
                    return booking.isCanceled;
                  case _OwnerBookingFilter.all:
                    return true;
                }
              }).toList(growable: false);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: SegmentedButton<_OwnerBookingFilter>(
                      segments: [
                        ButtonSegment<_OwnerBookingFilter>(
                          value: _OwnerBookingFilter.all,
                          label: Text(l10n.ownerFilterAll),
                        ),
                        ButtonSegment<_OwnerBookingFilter>(
                          value: _OwnerBookingFilter.active,
                          label: Text(l10n.statusActive),
                        ),
                        ButtonSegment<_OwnerBookingFilter>(
                          value: _OwnerBookingFilter.canceled,
                          label: Text(l10n.statusCanceled),
                        ),
                      ],
                      selected: <_OwnerBookingFilter>{_filter},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _filter = selection.first;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              sortedItems.isEmpty
                                  ? l10n.ownerNoBookings
                                  : l10n.ownerNoBookingsForFilter,
                              style: const TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final booking = items[index];
                              final seats = booking.seatIndexes
                                  .map((e) => 'PC ${e + 1}')
                                  .join(', ');

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
                                      Text(l10n.bookingTimeLabel(_formatSchedule(booking))),
                                      Text(l10n.durationLabel(booking.durationHours)),
                                      Text(l10n.seatsLabel(seats)),
                                      Text(
                                        l10n.totalPriceLabel(booking.totalPrice),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(l10n.createdLabel(_formatDate(booking.createdAt))),
                                      if (booking.isCanceled && booking.canceledAt != null)
                                        Text(
                                          l10n.canceledLabel(
                                            _formatDate(booking.canceledAt!),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
