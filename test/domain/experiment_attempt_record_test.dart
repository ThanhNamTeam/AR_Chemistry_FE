import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/domain/models/reaction_experiment/experiment_attempt_record.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

ExperimentQuestionResult _makeResult({
  String id = 'q1',
  String questionText = 'Q?',
  List<String> options = const ['A', 'B', 'C'],
  int selectedIndex = 0,
  int correctIndex = 0,
  String explanation = 'Vì A là đúng.',
}) {
  return ExperimentQuestionResult(
    questionId: id,
    questionText: questionText,
    options: options,
    selectedIndex: selectedIndex,
    correctIndex: correctIndex,
    explanation: explanation,
  );
}

ExperimentAttemptRecord _makeRecord({
  String code = 'zn_hcl_g8',
  int grade = 8,
  String categoryKey = 'metal',
  int score = 4,
  int total = 5,
  DateTime? completedAt,
  List<ExperimentQuestionResult>? results,
}) {
  return ExperimentAttemptRecord(
    reactionCode: code,
    grade: grade,
    categoryKey: categoryKey,
    score: score,
    total: total,
    completedAt: completedAt ?? DateTime.utc(2026, 8, 8, 12),
    results: results ?? [_makeResult()],
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  // ── ExperimentQuestionResult ──────────────────────────────────────────────

  group('ExperimentQuestionResult.isCorrect', () {
    test('selected == correct → true', () {
      expect(_makeResult(selectedIndex: 0, correctIndex: 0).isCorrect, isTrue);
      expect(_makeResult(selectedIndex: 2, correctIndex: 2).isCorrect, isTrue);
    });

    test('selected != correct → false', () {
      expect(_makeResult(selectedIndex: 1, correctIndex: 0).isCorrect, isFalse);
      expect(_makeResult(selectedIndex: 0, correctIndex: 2).isCorrect, isFalse);
    });

    test('selectedIndex = -1 (chưa trả lời) → false', () {
      expect(_makeResult(selectedIndex: -1, correctIndex: 0).isCorrect, isFalse);
    });
  });

  group('ExperimentQuestionResult toJson / fromJson', () {
    test('round-trip đầy đủ', () {
      final r = _makeResult(
        id: 'q2',
        questionText: 'H₂O là gì?',
        options: ['Nước', 'Axit', 'Bazơ'],
        selectedIndex: 0,
        correctIndex: 0,
        explanation: 'H₂O là nước.',
      );
      final json = r.toJson();
      final restored = ExperimentQuestionResult.fromJson(json);

      expect(restored.questionId, 'q2');
      expect(restored.questionText, 'H₂O là gì?');
      expect(restored.options, ['Nước', 'Axit', 'Bazơ']);
      expect(restored.selectedIndex, 0);
      expect(restored.correctIndex, 0);
      expect(restored.explanation, 'H₂O là nước.');
      expect(restored.isCorrect, isTrue);
    });

    test('toJson chứa tất cả key cần thiết', () {
      final json = _makeResult().toJson();
      expect(json.containsKey('questionId'), isTrue);
      expect(json.containsKey('questionText'), isTrue);
      expect(json.containsKey('options'), isTrue);
      expect(json.containsKey('selectedIndex'), isTrue);
      expect(json.containsKey('correctIndex'), isTrue);
      expect(json.containsKey('explanation'), isTrue);
    });

    test('fromJson với json rỗng → default không crash', () {
      final r = ExperimentQuestionResult.fromJson({});
      expect(r.questionId, '');
      expect(r.questionText, '');
      expect(r.options, isEmpty);
      expect(r.selectedIndex, -1);
      expect(r.correctIndex, 0);
      expect(r.isCorrect, isFalse);
    });

    test('fromJson options null → list rỗng', () {
      final r = ExperimentQuestionResult.fromJson({'options': null});
      expect(r.options, isEmpty);
    });
  });

  // ── ExperimentAttemptRecord ───────────────────────────────────────────────

  group('ExperimentAttemptRecord toJson / fromJson', () {
    test('round-trip đầy đủ', () {
      final now = DateTime.utc(2026, 8, 8, 12);
      final record = _makeRecord(
        code: 'fe_hcl_g8',
        grade: 9,
        categoryKey: 'acid',
        score: 3,
        total: 5,
        completedAt: now,
        results: [
          _makeResult(id: 'q1', selectedIndex: 1, correctIndex: 1),
          _makeResult(id: 'q2', selectedIndex: 0, correctIndex: 2),
        ],
      );

      final json = record.toJson();
      final restored = ExperimentAttemptRecord.fromJson(json);

      expect(restored.reactionCode, 'fe_hcl_g8');
      expect(restored.grade, 9);
      expect(restored.categoryKey, 'acid');
      expect(restored.score, 3);
      expect(restored.total, 5);
      expect(restored.results.length, 2);
      expect(restored.results[0].isCorrect, isTrue);
      expect(restored.results[1].isCorrect, isFalse);
    });

    test('completedAt serialization ISO 8601', () {
      final now = DateTime.utc(2026, 8, 8, 12, 0, 0);
      final json = _makeRecord(completedAt: now).toJson();
      expect(json['completedAt'], '2026-08-08T12:00:00.000Z');

      final restored = ExperimentAttemptRecord.fromJson(json);
      expect(restored.completedAt.year, 2026);
      expect(restored.completedAt.month, 8);
      expect(restored.completedAt.day, 8);
    });

    test('fromJson với json rỗng → default không crash', () {
      final r = ExperimentAttemptRecord.fromJson({});
      expect(r.reactionCode, '');
      expect(r.grade, 8);
      expect(r.score, 0);
      expect(r.total, 5);
      expect(r.results, isEmpty);
    });

    test('fromJson completedAt invalid string → fallback DateTime.now()', () {
      final r = ExperimentAttemptRecord.fromJson({'completedAt': 'not-a-date'});
      expect(r.completedAt, isA<DateTime>());
    });

    test('score = 0 hợp lệ (điểm bằng 0)', () {
      final r = _makeRecord(score: 0, total: 5);
      final restored = ExperimentAttemptRecord.fromJson(r.toJson());
      expect(restored.score, 0);
    });

    test('score = total hợp lệ (điểm tuyệt đối)', () {
      final r = _makeRecord(score: 5, total: 5);
      final restored = ExperimentAttemptRecord.fromJson(r.toJson());
      expect(restored.score, 5);
      expect(restored.total, 5);
    });
  });
}
