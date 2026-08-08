import 'staff_quiz_option_model.dart';

class StaffQuizQuestionModel {
  final String id;
  final int questionOrder;
  final String questionText;
  final List<StaffQuizOptionModel> options;
  final String correctAnswer;
  final String? explanation;
  final String status;

  const StaffQuizQuestionModel({
    required this.id,
    required this.questionOrder,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.status,
  });

  factory StaffQuizQuestionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawOptions =
        json['options'] as List<dynamic>? ?? [];

    return StaffQuizQuestionModel(
      id: json['id']?.toString() ?? '',
      questionOrder:
      (json['questionOrder'] as num?)?.toInt() ?? 0,
      questionText:
      json['questionText']?.toString() ?? '',
      options: rawOptions
          .whereType<Map<String, dynamic>>()
          .map(StaffQuizOptionModel.fromJson)
          .toList(),
      correctAnswer:
      json['correctAnswer']?.toString() ?? '',
      explanation:
      json['explanation']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }
}