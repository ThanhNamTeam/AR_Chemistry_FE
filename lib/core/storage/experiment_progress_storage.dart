import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/reaction_experiment/experiment_attempt_record.dart';

class ExperimentProgressStorage {
  static const _gradeKey = 'experiment_selected_grade';
  static const _attemptsKey = 'experiment_attempts_v1';

  Future<void> saveSelectedGrade(int grade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gradeKey, grade);
  }

  Future<int?> getSelectedGrade() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_gradeKey);
  }

  Future<Map<String, ExperimentAttemptRecord>> loadAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_attemptsKey);
    if (raw == null) return {};

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};

    return decoded.map(
      (key, value) => MapEntry(
        key.toString(),
        ExperimentAttemptRecord.fromJson(
          Map<String, dynamic>.from(value as Map),
        ),
      ),
    );
  }

  Future<void> saveAttempt(ExperimentAttemptRecord record) async {
    final all = await loadAttempts();
    all[record.reactionCode] = record;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _attemptsKey,
      jsonEncode(all.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  Future<List<ExperimentAttemptRecord>> historyFor(String reactionCode) async {
    final all = await loadAttempts();
    final record = all[reactionCode];
    return record == null ? [] : [record];
  }
}
