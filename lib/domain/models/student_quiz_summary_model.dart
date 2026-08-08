class StudentQuizSummaryModel {
  final String quizCode;

  final String reactionId;
  final String reactionCode;
  final String reactionName;

  final String title;
  final int version;
  final int questionCount;
  final int durationSeconds;

  const StudentQuizSummaryModel({
    required this.quizCode,
    required this.reactionId,
    required this.reactionCode,
    required this.reactionName,
    required this.title,
    required this.version,
    required this.questionCount,
    required this.durationSeconds,
  });

  factory StudentQuizSummaryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StudentQuizSummaryModel(
      quizCode:
      json['quizCode']?.toString() ?? '',

      reactionId:
      json['reactionId']?.toString() ?? '',

      reactionCode:
      json['reactionCode']?.toString() ?? '',

      reactionName:
      json['reactionName']?.toString() ?? '',

      title:
      json['title']?.toString() ??
          json['quizTitle']?.toString() ??
          '',

      version:
      (json['version'] as num?)?.toInt() ?? 1,

      questionCount:
      (json['questionCount'] as num?)?.toInt() ?? 0,

      durationSeconds:
      (json['durationSeconds'] as num?)?.toInt() ?? 420,
    );
  }
}