class StaffQuizSummaryModel {
  final String quizCode;
  final String title;
  final String status;
  final String? generatedBy;
  final int? version;
  final int questionCount;

  const StaffQuizSummaryModel({
    required this.quizCode,
    required this.title,
    required this.status,
    this.generatedBy,
    this.version,
    required this.questionCount,
  });

  factory StaffQuizSummaryModel.fromJson(Map<String, dynamic> json) {
    return StaffQuizSummaryModel(
      quizCode: json['quizCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      generatedBy: json['generatedBy'] as String?,
      version: json['version'] as int?,
      questionCount: json['questionCount'] as int? ?? 0,
    );
  }
}