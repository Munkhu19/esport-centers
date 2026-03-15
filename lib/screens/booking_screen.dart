import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../data/booking_store.dart';
import '../data/seat_sync_service.dart';
import '../models/booking_record.dart';
import '../models/center.dart';
import '../widgets/language_toggle_button.dart';

class BookingScreen extends StatefulWidget {
  final EsportCenter center;

  const BookingScreen({super.key, required this.center});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final timeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    timeController.dispose();
    super.dispose();
  }

  int _previewTotalPrice(int seatCount) {
    final hours = int.tryParse(timeController.text.trim()) ?? 0;
    if (hours <= 0) return 0;
    return widget.center.price * hours * seatCount;
  }

  Future<void> submitBooking() async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final selected = BookingStore.selectedSeats(widget.center.id).toList()
      ..sort();
    final hours = int.tryParse(timeController.text.trim());

    if (name.isEmpty || phone.isEmpty || timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAllFields)),
      );
      return;
    }

    if (hours == null || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidPlayDuration)),
      );
      return;
    }

    if (!RegExp(r'^\d{8}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.phoneMustBe8Digits)),
      );
      return;
    }

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectAtLeastOneSeat)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    late final BookingRecord record;
    try {
      record = await SeatSyncService.confirmBooking(
        centerId: widget.center.id,
        centerName: widget.center.name,
        customerName: name,
        phone: phone,
        durationHours: hours,
        pricePerHour: widget.center.price,
        seatIndexes: selected,
      );
    } on SeatUnavailableException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    if (!mounted) return;
    final seatText = record.seatIndexes.map((e) => "PC ${e + 1}").join(", ");

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.bookingConfirmed),
        content: Text(
          l10n.bookingReceipt(
            record.centerName,
            seatText,
            record.durationHours,
            record.pricePerHour,
            record.totalPrice,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );

    nameController.clear();
    phoneController.clear();
    timeController.clear();
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = BookingStore.selectedSeats(widget.center.id).toList()
      ..sort();
    final seats = selected.isEmpty
        ? l10n.noneSelected
        : selected.map((e) => "PC ${e + 1}").join(", ");
    final totalPrice = _previewTotalPrice(selected.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingTitle),
        actions: const [LanguageToggleButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.centerLabel(widget.center.name),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.selectedSeatsLabel(seats),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.pricePerHourLabel(widget.center.price),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.name),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: InputDecoration(labelText: l10n.phone),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.playDurationHours),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.totalPriceLabel(totalPrice),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : submitBooking,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.confirmBooking),
            ),
          ],
        ),
      ),
    );
  }
}
