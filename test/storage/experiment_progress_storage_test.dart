import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/core/storage/experiment_progress_storage.dart';
import 'package:labedu/domain/models/reaction_experiment/experiment_attempt_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

ExperimentQuestionResult _makeResult({bool correct = true}) {
  return ExperimentQuestionResult(
    questionId: 'q1',
    questionText: 'Test question?',
    options: const ['A', 'B', 'C'],
    selectedIndex: correct ? 0 : 2,
    correctIndex: 0,
    explanation: 'Because A.',
  );
}

ExperimentAttemptRecord _makeRecord({
  String code = 'zn_hcl_g8',
  int grade = 8,
  String categoryKey = 'metal',
  int score = 4,
  int total = 5,
  List<ExperimentQuestionResult>? results,
}) {
  return ExperimentAttemptRecord(
    reactionCode: code,
    grade: grade,
    categoryKey: categoryKey,
    score: score,
    total: total,
    completedAt: DateTime.utc(2026, 8, 8),
    results: results ?? [_makeResult()],
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late ExperimentProgressStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = ExperimentProgressStorage();
  });

  // ── grade ─────────────────────────────────────────────────────────────────

  group('selectedGrade', () {
    test('save lớp 10, load = 10', () async {
      await storage.saveSelectedGrade(10);
      expect(await storage.getSelectedGrade(), 10);
    });

    test('getSelectedGrade chưa lưu → null', () async {
      expect(await storage.getSelectedGrade(), isNull);
    });

    test('boundary grade 8 (min)', () async {
      await storage.saveSelectedGrade(8);
      expect(await storage.getSelectedGrade(), 8);
    });

    test('boundary grade 12 (max)', () async {
      await storage.saveSelectedGrade(12);
      expect(await storage.getSelectedGrade(), 12);
    });

    test('ghi đè lớp cũ', () async {
      await storage.saveSelectedGrade(9);
      await storage.saveSelectedGrade(11);
      expect(await storage.getSelectedGrade(), 11);
    });
  });

  // ── attempts ──────────────────────────────────────────────────────────────

  group('saveAttempt / loadAttempts', () {
    test('save 1 record, load → map có 1 entry', () async {
      await storage.saveAttempt(_makeRecord());
      final all = await storage.loadAttempts();
      expect(all.length, 1);
      expect(all.containsKey('zn_hcl_g8'), isTrue);
      expect(all['zn_hcl_g8']?.score, 4);
    });

    test('loadAttempts chưa lưu → map rỗng', () async {
      final all = await storage.loadAttempts();
      expect(all, isEmpty);
    });

    test('save 2 code khác nhau → map có 2 entry', () async {
      await storage.saveAttempt(_makeRecord(code: 'zn_hcl_g8', score: 4));
      await storage.saveAttempt(_makeRecord(code: 'fe_hcl_g8', score: 5));
      final all = await storage.loadAttempts();
      expect(all.length, 2);
      expect(all['fe_hcl_g8']?.score, 5);
    });

    test('save cùng code 2 lần → ghi đè, chỉ giữ lần cuối', () async {
      await storage.saveAttempt(_makeRecord(score: 3));
      await storage.saveAttempt(_makeRecord(score: 5));
      final all = await storage.loadAttempts();
      expect(all.length, 1);
      expect(all['zn_hcl_g8']?.score, 5);
    });

    test('record với nhiều kết quả câu hỏi được lưu đầy đủ', () async {
      final results = [
        _makeResult(correct: true),
        _makeResult(correct: false),
        _makeResult(correct: true),
      ];
      await storage.saveAttempt(_makeRecord(results: results));
      final all = await storage.loadAttempts();
      expect(all['zn_hcl_g8']?.results.length, 3);
      expect(all['zn_hcl_g8']?.results[0].isCorrect, isTrue);
      expect(all['zn_hcl_g8']?.results[1].isCorrect, isFalse);
    });

    test('grade và categoryKey được lưu đúng', () async {
      await storage.saveAttempt(
          _makeRecord(grade: 11, categoryKey: 'acid'));
      final all = await storage.loadAttempts();
      expect(all['zn_hcl_g8']?.grade, 11);
      expect(all['zn_hcl_g8']?.categoryKey, 'acid');
    });
  });

  // ── historyFor ────────────────────────────────────────────────────────────

  group('historyFor', () {
    test('có record → list 1 phần tử', () async {
      await storage.saveAttempt(_makeRecord());
      final hist = await storage.historyFor('zn_hcl_g8');
      expect(hist.length, 1);
      expect(hist.first.reactionCode, 'zn_hcl_g8');
    });

    test('code không tồn tại → list rỗng', () async {
      final hist = await storage.historyFor('not_exist');
      expect(hist, isEmpty);
    });

    test('string rỗng → list rỗng', () async {
      final hist = await storage.historyFor('');
      expect(hist, isEmpty);
    });

    test('historyFor trả về record mới nhất sau ghi đè', () async {
      await storage.saveAttempt(_makeRecord(score: 2));
      await storage.saveAttempt(_makeRecord(score: 5));
      final hist = await storage.historyFor('zn_hcl_g8');
      expect(hist.first.score, 5);
    });
  });
}
