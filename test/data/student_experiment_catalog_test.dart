import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/data/reaction_experiment/student_experiment_catalog.dart';
import 'package:labedu/domain/models/reaction_experiment/reaction_category.dart';

void main() {
  // ── all() ─────────────────────────────────────────────────────────────────

  group('StudentExperimentCatalog.all()', () {
    test('danh sách không rỗng', () {
      expect(StudentExperimentCatalog.all(), isNotEmpty);
    });

    test('mỗi reaction có đúng 5 câu quiz', () {
      for (final r in StudentExperimentCatalog.all()) {
        expect(r.questions.length, 5,
            reason: 'reaction "${r.code}" thiếu/thừa câu quiz');
      }
    });

    test('code là duy nhất trong toàn catalog', () {
      final codes = StudentExperimentCatalog.all().map((r) => r.code).toList();
      expect(codes.toSet().length, codes.length,
          reason: 'Có code bị trùng lặp');
    });

    test('grade nằm trong khoảng 8–12', () {
      for (final r in StudentExperimentCatalog.all()) {
        expect(r.grade, inInclusiveRange(8, 12),
            reason: 'reaction "${r.code}" có grade ngoài phạm vi');
      }
    });

    test('mỗi reaction có nameVi và nameEn không rỗng', () {
      for (final r in StudentExperimentCatalog.all()) {
        expect(r.nameVi, isNotEmpty,
            reason: 'reaction "${r.code}" thiếu nameVi');
        expect(r.nameEn, isNotEmpty,
            reason: 'reaction "${r.code}" thiếu nameEn');
      }
    });

    test('mỗi reaction có equation không rỗng', () {
      for (final r in StudentExperimentCatalog.all()) {
        expect(r.equation, isNotEmpty,
            reason: 'reaction "${r.code}" thiếu equation');
      }
    });

    test('mỗi reaction có ít nhất 1 reactantLabel', () {
      for (final r in StudentExperimentCatalog.all()) {
        expect(r.reactantLabels, isNotEmpty,
            reason: 'reaction "${r.code}" không có reactant');
      }
    });

    test('gọi all() 2 lần trả về cùng instance (caching)', () {
      final first = StudentExperimentCatalog.all();
      final second = StudentExperimentCatalog.all();
      expect(identical(first, second), isTrue);
    });
  });

  // ── forGradeAndCategory() ─────────────────────────────────────────────────

  group('StudentExperimentCatalog.forGradeAndCategory()', () {
    test('lọc đúng grade và category', () {
      final list = StudentExperimentCatalog.forGradeAndCategory(
        grade: 8,
        category: ReactionCategory.metal,
      );
      expect(list, isNotEmpty);
      for (final r in list) {
        expect(r.grade, 8);
        expect(r.category, ReactionCategory.metal);
      }
    });

    test('tất cả 4 category đều có dữ liệu cho grade 8', () {
      for (final cat in ReactionCategory.values) {
        final list = StudentExperimentCatalog.forGradeAndCategory(
          grade: 8,
          category: cat,
        );
        expect(list, isNotEmpty,
            reason: 'Grade 8 / ${cat.name} không có phản ứng');
      }
    });

    test('tất cả grade 8–12 đều có dữ liệu', () {
      for (final grade in [8, 9, 10, 11, 12]) {
        final all = ReactionCategory.values
            .expand((cat) => StudentExperimentCatalog.forGradeAndCategory(
                  grade: grade,
                  category: cat,
                ))
            .toList();
        expect(all, isNotEmpty,
            reason: 'Grade $grade không có phản ứng nào');
      }
    });

    test('grade không tồn tại (7) → list rỗng', () {
      final list = StudentExperimentCatalog.forGradeAndCategory(
        grade: 7,
        category: ReactionCategory.metal,
      );
      expect(list, isEmpty);
    });

    test('grade quá lớn (13) → list rỗng', () {
      final list = StudentExperimentCatalog.forGradeAndCategory(
        grade: 13,
        category: ReactionCategory.acid,
      );
      expect(list, isEmpty);
    });
  });

  // ── byCode() ──────────────────────────────────────────────────────────────

  group('StudentExperimentCatalog.byCode()', () {
    test('seed reaction "zn_hcl_g8" tìm được', () {
      final r = StudentExperimentCatalog.byCode('zn_hcl_g8');
      expect(r, isNotNull);
      expect(r!.code, 'zn_hcl_g8');
    });

    test('seed reaction "fe_hcl_g8" tìm được', () {
      expect(StudentExperimentCatalog.byCode('fe_hcl_g8'), isNotNull);
    });

    test('code không tồn tại → null', () {
      expect(StudentExperimentCatalog.byCode('fake_code_xyz'), isNull);
    });

    test('string rỗng → null', () {
      expect(StudentExperimentCatalog.byCode(''), isNull);
    });
  });

  // ── bilingual helpers ─────────────────────────────────────────────────────

  group('Bilingual – name / script / questions', () {
    late final reaction = StudentExperimentCatalog.byCode('zn_hcl_g8')!;

    test('name(true) VI ≠ name(false) EN', () {
      expect(reaction.name(true), isNot(reaction.name(false)));
    });

    test('name(true) là tiếng Việt (chứa ký tự VI)', () {
      expect(reaction.name(true), contains('Kẽm'));
    });

    test('script(true) VI ≠ script(false) EN', () {
      expect(reaction.script(true), isNot(reaction.script(false)));
    });

    test('mỗi câu quiz: questionText VI ≠ EN', () {
      for (final q in reaction.questions) {
        expect(q.questionText(true), isNot(q.questionText(false)));
      }
    });

    test('mỗi câu quiz: options VI ≠ EN', () {
      for (final q in reaction.questions) {
        expect(q.options(true), isNot(equals(q.options(false))));
      }
    });

    test('mỗi câu quiz: explanation VI ≠ EN', () {
      for (final q in reaction.questions) {
        expect(q.explanation(true), isNot(q.explanation(false)));
      }
    });

    test('correctIndex hợp lệ cho cả hai locale', () {
      for (final q in reaction.questions) {
        expect(q.correctIndex, inInclusiveRange(0, q.options(true).length - 1));
        expect(q.correctIndex, inInclusiveRange(0, q.options(false).length - 1));
      }
    });
  });

  // ── AR scan response handling (unit, không mock AR) ───────────────────────

  group('AR recognition result – khớp code catalog', () {
    test('code từ catalog có thể dùng làm expectedReactionCode', () {
      final allCodes = StudentExperimentCatalog.all()
          .map((r) => r.code)
          .toList();
      for (final code in allCodes) {
        expect(StudentExperimentCatalog.byCode(code)?.code, code);
      }
    });
  });
}
