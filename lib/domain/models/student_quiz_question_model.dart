import 'package:labedu/domain/models/student_quiz_option_model.dart';

class StudentQuizQuestionModel {
  final String questionId;
  final int questionOrder;
  final String questionText;
  final List<StudentQuizOptionModel> options;
  final String? selectedAnswer;

  const StudentQuizQuestionModel({
    required this.questionId,
    required this.questionOrder,
    required this.questionText,
    required this.options,
    this.selectedAnswer,
  });

  factory StudentQuizQuestionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawOptions =
        json['options'] as List<dynamic>? ?? [];

    return StudentQuizQuestionModel(
      questionId:
      json['questionId']?.toString() ??
          json['id']?.toString() ??
          '',
      questionOrder:
      (json['questionOrder'] as num?)?.toInt() ?? 0,
      questionText:
      json['questionText']?.toString() ?? '',
      options: rawOptions
          .whereType<Map<String, dynamic>>()
          .map(StudentQuizOptionModel.fromJson)
          .toList(),
      selectedAnswer:
      json['selectedAnswer']?.toString(),
    );
  }
}