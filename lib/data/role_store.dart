import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleStore {
  static const String _rolesKey = 'user_roles_v1';
  static const String customerRole = 'customer';
  static const String adminRole = 'admin';
  static const String ownerPendingRole = 'owner_pending';
  static const String ownerRole = 'owner';
  static final ValueNotifier<int> rolesRevision = ValueNotifier<int>(0);
  static const Set<String> _adminEmails = <String>{
    'batsaikhanbatmunkh88@gmail.com',
  };

  static Future<Map<String, String>> _loadRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_rolesKey);
    if (raw == null || raw.isEmpty) return <String, String>{};

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return <String, String>{};
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  static Future<void> _saveRoles(Map<String, String> roles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rolesKey, jsonEncode(roles));
  }

  static Future<void> saveRole({
    required String email,
    required String role,
  }) async {
    final roles = await _loadRoles();
    roles[email] = role;
    await _saveRoles(roles);
    rolesRevision.value++;
  }

  static Future<void> removeRole(String email) async {
    final roles = await _loadRoles();
    roles.remove(email);
    await _saveRoles(roles);
    rolesRevision.value++;
  }

  static Future<String> roleForEmail(String? email) async {
    if (email == null || email.isEmpty) return customerRole;
    if (_adminEmails.contains(email)) return adminRole;
    final roles = await _loadRoles();
    final localRole = roles[email];
    if (localRole != null && localRole.isNotEmpty) {
      return localRole;
    }
    return roles[email] ?? customerRole;
  }

  static bool isAdminEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return _adminEmails.contains(email);
  }

  static Future<List<MapEntry<String, String>>> pendingOwnerRequests() async {
    final roles = await _loadRoles();
    return roles.entries
        .where((entry) => entry.value == ownerPendingRole)
        .toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  static Future<Map<String, String>> allRoles() async {
    final roles = await _loadRoles();
    for (final email in _adminEmails) {
      roles[email] = adminRole;
    }
    return roles;
  }
}
