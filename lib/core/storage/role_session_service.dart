import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/user_role.dart';

class RoleSessionService {
  static const _roleKey = 'session_role';
  static const _emailKey = 'session_role_email';

  String _profileKey(UserRole role) => 'role_profile_${role.name}';

  Future<void> save(UserRole role, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.name);
    await prefs.setString(_emailKey, email);
  }

  Future<({UserRole role, String email})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString(_roleKey);
    final email = prefs.getString(_emailKey);
    if (roleName == null || email == null) return null;
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => UserRole.user,
    );
    if (role == UserRole.user) return null;
    return (role: role, email: email);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    await prefs.remove(_emailKey);
  }

  Future<Map<String, dynamic>?> getProfile(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey(role));
    if (raw == null) return null;
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> saveProfile(UserRole role, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey(role), jsonEncode(data));
  }
}
