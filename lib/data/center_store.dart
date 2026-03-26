import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/center.dart';
import 'centers.dart';

class CenterStore {
  static const String _centersKey = 'centers_v2';

  static final ValueNotifier<List<EsportCenter>> centersNotifier =
      ValueNotifier<List<EsportCenter>>(
        List<EsportCenter>.unmodifiable(seedCenters),
      );

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_centersKey);
    if (raw == null || raw.isEmpty) {
      await _save(seedCenters);
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        await _save(seedCenters);
        return;
      }
      final loaded = decoded
          .whereType<Map>()
          .map((e) => EsportCenter.fromMap(Map<String, dynamic>.from(e)))
          .where((center) => center.id.isNotEmpty)
          .toList(growable: false);
      final filtered = loaded
          .where((center) => !_isRemovedLegacyCenter(center))
          .toList(growable: false);
      if (filtered.length != loaded.length) {
        await _save(filtered.isEmpty ? seedCenters : filtered);
        return;
      }
      if (loaded.isEmpty) {
        await _save(seedCenters);
        return;
      }
      centersNotifier.value = List<EsportCenter>.unmodifiable(loaded);
    } catch (_) {
      await _save(seedCenters);
    }
  }

  static List<EsportCenter> all() => centersNotifier.value;

  static List<EsportCenter> ownedBy(String? ownerEmail) {
    final normalizedOwnerEmail = _normalizeOwnerEmail(ownerEmail);
    if (normalizedOwnerEmail == null) return const <EsportCenter>[];
    return centersNotifier.value
        .where(
          (center) => _normalizeOwnerEmail(center.ownerEmail) == normalizedOwnerEmail,
        )
        .toList(growable: false);
  }

  static Future<void> addCenter(EsportCenter center) async {
    final next = [...centersNotifier.value, center];
    await _save(next);
  }

  static Future<void> updateCenter(EsportCenter center) async {
    final next = centersNotifier.value
        .map((item) => item.id == center.id ? center : item)
        .toList(growable: false);
    await _save(next);
  }

  static Future<void> deleteCenter(String centerId) async {
    final next = centersNotifier.value
        .where((item) => item.id != centerId)
        .toList(growable: false);
    await _save(next);
  }

  static Future<void> deleteCenters(Set<String> centerIds) async {
    if (centerIds.isEmpty) return;
    final next = centersNotifier.value
        .where((item) => !centerIds.contains(item.id))
        .toList(growable: false);
    await _save(next);
  }

  static Future<void> _save(List<EsportCenter> centers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _centersKey,
      jsonEncode(centers.map((e) => e.toMap()).toList()),
    );
    centersNotifier.value = List<EsportCenter>.unmodifiable(centers);
  }

  static bool _isRemovedLegacyCenter(EsportCenter center) {
    final normalizedName = center.name.toLowerCase().replaceAll(' ', '');
    final normalizedId = center.id.toLowerCase().replaceAll(' ', '');
    final hasOwner = center.ownerEmail != null && center.ownerEmail!.isNotEmpty;
    if (hasOwner) return false;
    return normalizedName == 'uniongaming' && normalizedId == 'uniongaming';
  }

  static String? _normalizeOwnerEmail(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
