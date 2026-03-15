import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/center.dart';
import '../widgets/language_toggle_button.dart';
import 'booking_screen.dart';
import 'seat_screen.dart';

class CenterDetail extends StatelessWidget {
  final EsportCenter center;

  const CenterDetail({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(center.name),
        actions: const [LanguageToggleButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.addressLabel(center.address), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(l10n.pcCountLabel(center.pcCount), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(l10n.pcSpecLabel(center.pcSpec), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(l10n.pricePerHourLabel(center.price), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(l10n.phoneLabel(center.phone), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeatScreen(center: center),
                  ),
                );
              },
              child: Text(l10n.selectPcSeats),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(center: center),
                  ),
                );
              },
              child: Text(l10n.makeBooking),
            ),
          ],
        ),
      ),
    );
  }
}
