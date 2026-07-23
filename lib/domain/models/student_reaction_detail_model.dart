import 'student_reaction_substance_model.dart';

class StudentReactionDetailModel {
  final String reactionId;
  final String reactionCode;
  final String reactionName;
  final String equation;

  final int grade;
  final String reactionCategory;
  final String reactionType;
  final String arSceneKey;

  final String? description;

  final int questionCount;
  final int durationSeconds;
  final bool hasPublishedQuiz;

  final List<StudentReactionSubstanceModel> reactants;
  final List<StudentReactionSubstanceModel> products;

  const StudentReactionDetailModel({
    required this.reactionId,
    required this.reactionCode,
    required this.reactionName,
    required this.equation,
    required this.grade,
    required this.reactionCategory,
    required this.reactionType,
    required this.arSceneKey,
    this.description,
    required this.questionCount,
    required this.durationSeconds,
    required this.hasPublishedQuiz,
    required this.reactants,
    required this.products,
  });

  factory StudentReactionDetailModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawReactants =
        json['reactants'] as List<dynamic>? ?? [];

    final rawProducts =
        json['products'] as List<dynamic>? ?? [];

    return StudentReactionDetailModel(
      reactionId:
      json['reactionId']?.toString() ??
          json['id']?.toString() ??
          '',
      reactionCode:
      json['reactionCode']?.toString() ??
          json['code']?.toString() ??
          '',
      reactionName:
      json['reactionName']?.toString() ??
          json['name']?.toString() ??
          '',
      equation:
      json['equation']?.toString() ?? '',
      grade:
      (json['grade'] as num?)?.toInt() ?? 0,
      reactionCategory:
      json['reactionCategory']?.toString() ?? '',
      reactionType:
      json['reactionType']?.toString() ?? '',
      arSceneKey:
      json['arSceneKey']?.toString() ?? '',
      description:
      json['description']?.toString(),
      questionCount:
      (json['questionCount'] as num?)?.toInt() ?? 0,
      durationSeconds:
      (json['durationSeconds'] as num?)?.toInt() ??
          420,
      hasPublishedQuiz:
      json['hasPublishedQuiz'] as bool? ??
          json['quizAvailable'] as bool? ??
          false,
      reactants: rawReactants
          .whereType<Map<String, dynamic>>()
          .map(
        StudentReactionSubstanceModel.fromJson,
      )
          .toList(),
      products: rawProducts
          .whereType<Map<String, dynamic>>()
          .map(
        StudentReactionSubstanceModel.fromJson,
      )
          .toList(),
    );
  }
}