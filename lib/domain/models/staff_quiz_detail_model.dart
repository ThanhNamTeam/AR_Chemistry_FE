import '../../core/models/response/page_response.dart';
import 'staff_quiz_question_model.dart';

class StaffQuizDetailModel {
  final String quizCode;

  final String reactionId;
  final String reactionCode;
  final String reactionName;
  final String equation;
  final int grade;
  final String reactionCategory;

  final String title;
  final String status;

  final String? generatedBy;
  final int version;

  final int questionLimit;
  final int durationSeconds;

  final PageResponse<StaffQuizQuestionModel> questions;

  const StaffQuizDetailModel({
    required this.quizCode,
    required this.reactionId,
    required this.reactionCode,
    required this.reactionName,
    required this.equation,
    required this.grade,
    required this.reactionCategory,
    required this.title,
    required this.status,
    this.generatedBy,
    required this.version,
    required this.questionLimit,
    required this.durationSeconds,
    required this.questions,
  });

  factory StaffQuizDetailModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final questionsJson = json['questions'];

    return StaffQuizDetailModel(
      quizCode: json['quizCode']?.toString() ?? '',

      reactionId: json['reactionId']?.toString() ?? '',
      reactionCode: json['reactionCode']?.toString() ?? '',
      reactionName: json['reactionName']?.toString() ?? '',
      equation: json['equation']?.toString() ?? '',
      grade: (json['grade'] as num?)?.toInt() ?? 0,
      reactionCategory:
      json['reactionCategory']?.toString() ?? '',

      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',

      generatedBy: json['generatedBy']?.toString(),

      version: (json['version'] as num?)?.toInt() ?? 1,

      questionLimit:
      (json['questionLimit'] as num?)?.toInt() ?? 5,

      durationSeconds:
      (json['durationSeconds'] as num?)?.toInt() ?? 420,

      questions: questionsJson is Map<String, dynamic>
          ? PageResponse<StaffQuizQuestionModel>.fromJson(
        questionsJson,
            (item) => StaffQuizQuestionModel.fromJson(item),
      )
          : PageResponse<StaffQuizQuestionModel>.fromJson(
        const {
          'items': [],
          'page': 0,
          'size': 10,
          'totalItems': 0,
          'totalPages': 0,
          'first': true,
          'last': true,
          'hasNext': false,
          'hasPrevious': false,
        },
            (item) => StaffQuizQuestionModel.fromJson(item),
      ),
    );
  }
}