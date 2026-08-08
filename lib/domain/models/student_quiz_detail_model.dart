import 'student_quiz_question_model.dart';

class StudentQuizDetailModel {
  final String attemptCode;

  final String quizCode;
  final String title;
  final int version;

  final String reactionId;
  final String reactionCode;
  final String reactionName;
  final String equation;

  final String? script;

  final int durationSeconds;
  final int remainingSeconds;
  final DateTime? expiredAt;

  final List<StudentQuizQuestionModel> questions;

  const StudentQuizDetailModel({
    required this.attemptCode,
    required this.quizCode,
    required this.title,
    required this.version,
    required this.reactionId,
    required this.reactionCode,
    required this.reactionName,
    required this.equation,
    this.script,
    required this.durationSeconds,
    required this.remainingSeconds,
    this.expiredAt,
    required this.questions,
  });

  factory StudentQuizDetailModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawQuestions =
        json['questions'] as List<dynamic>? ?? [];

    final rawExpiredAt =
    json['expiredAt']?.toString();

    return StudentQuizDetailModel(
      attemptCode:
      json['attemptCode']?.toString() ?? '',

      quizCode:
      json['quizCode']?.toString() ?? '',

      title:
      json['title']?.toString() ??
          json['quizTitle']?.toString() ??
          '',

      version:
      (json['version'] as num?)?.toInt() ?? 1,

      reactionId:
      json['reactionId']?.toString() ?? '',

      reactionCode:
      json['reactionCode']?.toString() ?? '',

      reactionName:
      json['reactionName']?.toString() ?? '',

      equation:
      json['equation']?.toString() ?? '',

      script:
      json['script']?.toString(),

      durationSeconds:
      (json['durationSeconds'] as num?)?.toInt() ??
          420,

      remainingSeconds:
      (json['remainingSeconds'] as num?)?.toInt() ??
          0,

      expiredAt:
      rawExpiredAt == null ||
          rawExpiredAt.isEmpty
          ? null
          : DateTime.tryParse(rawExpiredAt),

      questions: rawQuestions
          .whereType<Map<String, dynamic>>()
          .map(StudentQuizQuestionModel.fromJson)
          .toList(),
    );
  }
}