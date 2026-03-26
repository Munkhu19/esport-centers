import 'package:flutter/material.dart';

import '../data/booking_store.dart';
import '../l10n/app_localizations.dart';
import '../models/booking_record.dart';
import '../models/center.dart';
import '../widgets/language_toggle_button.dart';

class OwnerSeatManagerScreen extends StatefulWidget {
  const OwnerSeatManagerScreen({super.key, required this.center});

  final EsportCenter center;

  @override
  State<OwnerSeatManagerScreen> createState() => _OwnerSeatManagerScreenState();
}

class _OwnerSeatManagerScreenState extends State<OwnerSeatManagerScreen> {
  late DateTime _previewStartAt;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().add(const Duration(hours: 1));
    _previewStartAt = DateTime(now.year, now.month, now.day, now.hour);
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDateTime(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Future<void> _pickPreviewStartAt() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: _previewStartAt,
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_previewStartAt),
    );
    if (!mounted || time == null) return;

    setState(() {
      _previewStartAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ownerSeatManagerTitle(widget.center.name)),
        actions: const [LanguageToggleButton()],
      ),
      body: StreamBuilder<List<BookingRecord>>(
        stream: BookingStore.bookingHistoryStream(),
        initialData: BookingStore.bookingHistory(centerId: widget.center.id),
        builder: (context, historySnapshot) {
          return StreamBuilder<Set<int>>(
            stream: BookingStore.blockedSeatsStream(widget.center.id),
            initialData: BookingStore.blockedSeats(widget.center.id),
            builder: (context, blockedSnapshot) {
              final blockedSeats = blockedSnapshot.data ?? const <int>{};
              const durationHours = 1;
              final bookedSeats = durationHours <= 0
                  ? <int>{}
                  : BookingStore.scheduledBookedSeats(
                      centerId: widget.center.id,
                      startAt: _previewStartAt,
                      durationHours: durationHours,
                    );

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _pickPreviewStartAt,
                          borderRadius: BorderRadius.circular(15),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.bookingStartTime,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDateTime(_previewStartAt)),
                                const Icon(Icons.schedule),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Legend(
                              color: Colors.green,
                              label: l10n.ownerSeatAvailable,
                            ),
                            _Legend(
                              color: Colors.orange,
                              label: l10n.ownerSeatBlocked,
                            ),
                            _Legend(
                              color: Colors.red,
                              label: l10n.ownerSeatBooked,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: widget.center.pcCount,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final isBooked = bookedSeats.contains(index);
                        final isBlocked = blockedSeats.contains(index);
                        final color = isBooked
                            ? Colors.red
                            : isBlocked
                                ? Colors.orange
                                : Colors.green;

                        return GestureDetector(
                          onTap: isBooked
                              ? null
                              : () {
                                  BookingStore.toggleBlockedSeat(
                                    widget.center.id,
                                    index,
                                  );
                                  setState(() {});
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'PC ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      l10n.ownerSeatManagerHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
