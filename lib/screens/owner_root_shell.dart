import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'owner_bookings_screen.dart';
import 'owner_centers_screen.dart';
import 'owner_dashboard_screen.dart';
import 'profile_screen.dart';

class OwnerRootShell extends StatefulWidget {
  const OwnerRootShell({super.key});

  @override
  State<OwnerRootShell> createState() => _OwnerRootShellState();
}

class _OwnerRootShellState extends State<OwnerRootShell> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = const [
    OwnerDashboardScreen(),
    OwnerCentersScreen(),
    OwnerBookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            backgroundColor: const Color(0xFF0C1424).withValues(alpha: 0.86),
            indicatorColor: const Color(0xFF22C55E).withValues(alpha: 0.2),
            labelBehavior:
                NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard_rounded),
                label: '',
                tooltip: l10n.ownerDashboardTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.storefront_outlined),
                selectedIcon: const Icon(Icons.storefront_rounded),
                label: '',
                tooltip: l10n.ownerCentersTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long_rounded),
                label: '',
                tooltip: l10n.ownerBookingsTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: '',
                tooltip: l10n.profileTitle,
              ),
            ],
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
