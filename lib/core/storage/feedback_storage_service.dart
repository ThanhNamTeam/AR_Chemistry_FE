import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FeedbackStorageService {
  static const _key = 'feedback_submissions_v1';

  Future<void> appendSubmission(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getSubmissions();
    list.add({
      ...entry,
      'submittedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> getSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
