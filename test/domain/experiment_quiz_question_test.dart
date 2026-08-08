import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/domain/models/reaction_experiment/experiment_quiz_question.dart';

void main() {
  const q = ExperimentQuizQuestion(
    id: 'q1',
    questionTextVi: 'Câu hỏi tiếng Việt',
    questionTextEn: 'English question',
    optionsVi: ['A Vi', 'B Vi', 'C Vi', 'D Vi'],
    optionsEn: ['A En', 'B En', 'C En', 'D En'],
    correctIndex: 1,
    explanationVi: 'Giải thích tiếng Việt',
    explanationEn: 'English explanation',
  );

  group('questionText()', () {
    test('isVi=true → VI text', () {
      expect(q.questionText(true), 'Câu hỏi tiếng Việt');
    });

    test('isVi=false → EN text', () {
      expect(q.questionText(false), 'English question');
    });

    test('VI và EN không giống nhau', () {
      expect(q.questionText(true), isNot(q.questionText(false)));
    });
  });

  group('options()', () {
    test('isVi=true → options VI', () {
      expect(q.options(true), ['A Vi', 'B Vi', 'C Vi', 'D Vi']);
    });

    test('isVi=false → options EN', () {
      expect(q.options(false), ['A En', 'B En', 'C En', 'D En']);
    });

    test('VI và EN cùng độ dài', () {
      expect(q.options(true).length, q.options(false).length);
    });

    test('correctIndex nằm trong phạm vi options', () {
      expect(q.correctIndex, lessThan(q.options(true).length));
      expect(q.correctIndex, lessThan(q.options(false).length));
      expect(q.correctIndex, greaterThanOrEqualTo(0));
    });
  });

  group('explanation()', () {
    test('isVi=true → VI explanation', () {
      expect(q.explanation(true), 'Giải thích tiếng Việt');
    });

    test('isVi=false → EN explanation', () {
      expect(q.explanation(false), 'English explanation');
    });
  });

  group('boundary – correctIndex = 0', () {
    test('correctIndex 0 hợp lệ', () {
      const q0 = ExperimentQuizQuestion(
        id: 'q0',
        questionTextVi: '',
        questionTextEn: '',
        optionsVi: ['Đúng'],
        optionsEn: ['Correct'],
        correctIndex: 0,
        explanationVi: '',
        explanationEn: '',
      );
      expect(q0.correctIndex, 0);
      expect(q0.options(true)[q0.correctIndex], 'Đúng');
    });
  });

  group('string rỗng', () {
    test('id rỗng vẫn tạo được', () {
      const qEmpty = ExperimentQuizQuestion(
        id: '',
        questionTextVi: '',
        questionTextEn: '',
        optionsVi: [],
        optionsEn: [],
        correctIndex: 0,
        explanationVi: '',
        explanationEn: '',
      );
      expect(qEmpty.id, '');
      expect(qEmpty.options(true), isEmpty);
    });
  });
}
