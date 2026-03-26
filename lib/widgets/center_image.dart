import 'dart:convert';

import 'package:flutter/material.dart';

class CenterImage extends StatelessWidget {
  const CenterImage({
    super.key,
    required this.imageBase64,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
  });

  final String? imageBase64;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final data = imageBase64;
    if (data == null || data.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1D4ED8).withValues(alpha: 0.55),
              const Color(0xFF7C3AED).withValues(alpha: 0.45),
            ],
          ),
        ),
        child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 34),
      );
    }

    try {
      final bytes = base64Decode(data);
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    } catch (_) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: const Color(0xFF172033),
        ),
        child: const Icon(Icons.broken_image_outlined, color: Colors.white70),
      );
    }
  }
}
