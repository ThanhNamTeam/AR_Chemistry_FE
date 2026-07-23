class StaffQuizSummaryModel {
  final String quizCode;
  final String reactionId;
  final String reactionCode;
  final String reactionName;
  final String title;
  final String status;
  final String generatedBy;
  final int version;
  final int durationSeconds;
  final int questionLimit;
  final int questionCount;

  const StaffQuizSummaryModel({
    required this.quizCode,
    required this.reactionId,
    required this.reactionCode,
    required this.reactionName,
    required this.title,
    required this.status,
    required this.generatedBy,
    required this.version,
    required this.durationSeconds,
    required this.questionLimit,
    required this.questionCount,
  });

  factory StaffQuizSummaryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StaffQuizSummaryModel(
      quizCode: json['quizCode'] as String,
      reactionId: json['reactionId'] as String,
      reactionCode: json['reactionCode'] as String,
      reactionName: json['reactionName'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      generatedBy: json['generatedBy'] as String,
      version: (json['version'] as num).toInt(),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      questionLimit: (json['questionLimit'] as num).toInt(),
      questionCount: (json['questionCount'] as num).toInt(),
    );
  }
}