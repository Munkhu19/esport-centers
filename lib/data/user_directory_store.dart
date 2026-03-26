import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserDirectoryStore {
  static const String _usersKey = 'app_users_v1';

  static Future<Set<String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return <String>{};

    final decoded = jsonDecode(raw);
    if (decoded is! List) return <String>{};

    return decoded
        .whereType<Object>()
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  static Future<void> _saveUsers(Set<String> users) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = users.toList()..sort();
    await prefs.setString(_usersKey, jsonEncode(sorted));
  }

  static Future<void> register(String? email) async {
    if (email == null || email.trim().isEmpty) return;
    final users = await _loadUsers();
    users.add(email.trim());
    await _saveUsers(users);
  }

  static Future<void> remove(String email) async {
    final users = await _loadUsers();
    users.remove(email.trim());
    await _saveUsers(users);
  }

  static Future<Set<String>> all() async {
    return _loadUsers();
  }
}
