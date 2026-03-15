import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../data/booking_store.dart';
import '../data/seat_sync_service.dart';
import '../models/center.dart';
import '../widgets/language_toggle_button.dart';

class SeatScreen extends StatefulWidget {
  final EsportCenter center;

  const SeatScreen({super.key, required this.center});

  @override
  State<SeatScreen> createState() => _SeatScreenState();
}

class _SeatScreenState extends State<SeatScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectSeatsTitle(widget.center.name)),
        actions: const [LanguageToggleButton()],
      ),
      body: StreamBuilder<Set<int>>(
        stream: SeatSyncService.bookedSeatsStream(centerId: widget.center.id),
        initialData: BookingStore.bookedSeats(widget.center.id),
        builder: (context, snapshot) {
          final bookedSeats = snapshot.data ?? <int>{};
          final selectedSeats = BookingStore.selectedSeats(widget.center.id);

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: widget.center.pcCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final isBooked = bookedSeats.contains(index);
              final isSelected = selectedSeats.contains(index);

              final Color color;
              if (isBooked) {
                color = Colors.red;
              } else if (isSelected) {
                color = Colors.green;
              } else {
                color = Colors.grey.shade300;
              }

              return GestureDetector(
                onTap: () {
                  if (isBooked) return;
                  setState(() {
                    BookingStore.toggleSeat(widget.center.id, index);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "PC ${index + 1}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
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
