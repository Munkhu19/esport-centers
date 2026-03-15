import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMn = localeController.value.languageCode == 'mn';

    return IconButton(
      tooltip: l10n.changeLanguage,
      onPressed: () {
        localeController.toggleLanguage();
      },
      icon: Text(
        isMn ? 'EN' : 'MN',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
