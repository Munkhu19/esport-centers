import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/owner_application.dart';

class OwnerApplicationStore {
  static const String _applicationsKey = 'owner_applications_v1';

  static Future<Map<String, OwnerApplication>> _loadApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_applicationsKey);
    if (raw == null || raw.isEmpty) return <String, OwnerApplication>{};

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return <String, OwnerApplication>{};

    final applications = <String, OwnerApplication>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        applications[entry.key] = OwnerApplication.fromJson(value);
      } else if (value is Map) {
        applications[entry.key] = OwnerApplication.fromJson(
          value.map((key, item) => MapEntry(key.toString(), item)),
        );
      }
    }
    return applications;
  }

  static Future<void> _saveApplications(
    Map<String, OwnerApplication> applications,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = applications.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString(_applicationsKey, jsonEncode(encoded));
  }

  static Future<void> saveApplication(OwnerApplication application) async {
    final applications = await _loadApplications();
    applications[application.email] = application;
    await _saveApplications(applications);
  }

  static Future<OwnerApplication?> applicationForEmail(String email) async {
    final applications = await _loadApplications();
    return applications[email];
  }

  static Future<Map<String, OwnerApplication>> allApplications() async {
    return _loadApplications();
  }

  static Future<void> removeApplication(String email) async {
    final applications = await _loadApplications();
    applications.remove(email);
    await _saveApplications(applications);
  }
}
