import 'student_quiz_question_model.dart';

class StudentQuizDetailModel {
  final String quizCode;
  final String lessonCode;
  final String title;
  final int? version;
  final List<StudentQuizQuestionModel> questions;

  const StudentQuizDetailModel({
    required this.quizCode,
    required this.lessonCode,
    required this.title,
    this.version,
    required this.questions,
  });

  factory StudentQuizDetailModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];

    return StudentQuizDetailModel(
      quizCode: json['quizCode'] as String? ?? '',
      lessonCode: json['lessonCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      version: json['version'] as int?,
      questions: rawQuestions
          .map(
            (item) => StudentQuizQuestionModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}