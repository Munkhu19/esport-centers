import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/booking_store.dart';
import '../data/seat_sync_service.dart';
import '../l10n/app_localizations.dart';
import '../models/booking_record.dart';
import '../models/center.dart';
import 'root_shell.dart';
import '../widgets/language_toggle_button.dart';

class BookingScreen extends StatefulWidget {
  final EsportCenter center;
  final DateTime? initialStartAt;
  final int? initialDurationHours;

  const BookingScreen({
    super.key,
    required this.center,
    this.initialStartAt,
    this.initialDurationHours,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final durationController = TextEditingController();
  bool _isSubmitting = false;
  late DateTime _startAt;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialStartAt;
    if (initial != null) {
      _startAt = initial;
    } else {
      final now = DateTime.now().add(const Duration(hours: 1));
      _startAt = DateTime(now.year, now.month, now.day, now.hour);
    }
    if (widget.initialDurationHours != null &&
        widget.initialDurationHours! > 0) {
      durationController.text = widget.initialDurationHours!.toString();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    durationController.dispose();
    super.dispose();
  }

  int _previewTotalPrice(int seatCount) {
    final hours = int.tryParse(durationController.text.trim()) ?? 0;
    if (hours <= 0) return 0;
    return widget.center.price * hours * seatCount;
  }

  String _formatDateTime(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Future<void> _pickStartAt() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: _startAt,
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );
    if (!mounted || time == null) return;

    setState(() {
      _startAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> submitBooking() async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final selected = BookingStore.selectedSeats(widget.center.id).toList()..sort();
    final hours = int.tryParse(durationController.text.trim());

    if (name.isEmpty ||
        phone.isEmpty ||
        durationController.text.trim().isEmpty) {
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

    if (_startAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidStartTime)),
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
        startAt: _startAt,
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
    final seatText = record.seatIndexes.map((e) => 'PC ${e + 1}').join(', ');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.bookingConfirmed),
        content: Text(
          '${l10n.bookingTimeLabel(_formatDateTime(record.startAt))}\n\n'
          '${l10n.bookingReceipt(
            record.centerName,
            seatText,
            record.durationHours,
            record.pricePerHour,
            record.totalPrice,
          )}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              rootShellTabNotifier.value = 2;
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );

    nameController.clear();
    phoneController.clear();
    durationController.clear();
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = BookingStore.selectedSeats(widget.center.id).toList()..sort();
    final seats = selected.isEmpty
        ? l10n.noneSelected
        : selected.map((e) => 'PC ${e + 1}').join(', ');
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
            InkWell(
              onTap: _pickStartAt,
              borderRadius: BorderRadius.circular(15),
              child: InputDecorator(
                decoration: InputDecoration(labelText: l10n.bookingStartTime),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDateTime(_startAt)),
                    const Icon(Icons.schedule),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: durationController,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                    : Text(
                        l10n.confirmBooking,
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
