import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  static const String _assetPath =
      'assets/aba9eafe-30d0-426c-b69e-c483d331db67.jpg';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _assetPath,
          fit: BoxFit.fitHeight,
          alignment: Alignment.center,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF140326).withValues(alpha: 0.28),
                const Color(0xFF1B0C38).withValues(alpha: 0.44),
                const Color(0xFF0E1022).withValues(alpha: 0.82),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.18),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.34),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
