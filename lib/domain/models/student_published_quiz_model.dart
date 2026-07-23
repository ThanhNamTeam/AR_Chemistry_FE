class StudentPublishedQuizModel {
  final String reactionId;
  final String reactionCode;
  final String reactionName;
  final String equation;

  final int grade;
  final String reactionCategory;

  final String quizCode;
  final String quizTitle;

  final int version;
  final int questionCount;
  final int durationSeconds;

  const StudentPublishedQuizModel({
    required this.reactionId,
    required this.reactionCode,
    required this.reactionName,
    required this.equation,
    required this.grade,
    required this.reactionCategory,
    required this.quizCode,
    required this.quizTitle,
    required this.version,
    required this.questionCount,
    required this.durationSeconds,
  });

  factory StudentPublishedQuizModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StudentPublishedQuizModel(
      reactionId:
      json['reactionId']?.toString() ?? '',

      reactionCode:
      json['reactionCode']?.toString() ?? '',

      reactionName:
      json['reactionName']?.toString() ?? '',

      equation:
      json['equation']?.toString() ?? '',

      grade:
      (json['grade'] as num?)?.toInt() ?? 0,

      reactionCategory:
      json['reactionCategory']?.toString() ?? '',

      quizCode:
      json['quizCode']?.toString() ?? '',

      quizTitle:
      json['quizTitle']?.toString() ??
          json['title']?.toString() ??
          '',

      version:
      (json['version'] as num?)?.toInt() ?? 1,

      questionCount:
      (json['questionCount'] as num?)?.toInt() ?? 0,

      durationSeconds:
      (json['durationSeconds'] as num?)?.toInt() ??
          420,
    );
  }
}