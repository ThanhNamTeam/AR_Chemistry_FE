class StudentQuizSummaryModel {
  final String quizCode;
  final String lessonCode;
  final String title;
  final int? version;
  final int questionCount;

  const StudentQuizSummaryModel({
    required this.quizCode,
    required this.lessonCode,
    required this.title,
    this.version,
    required this.questionCount,
  });

  factory StudentQuizSummaryModel.fromJson(Map<String, dynamic> json) {
    return StudentQuizSummaryModel(
      quizCode: json['quizCode'] as String? ?? '',
      lessonCode: json['lessonCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      version: json['version'] as int?,
      questionCount: json['questionCount'] as int? ?? 0,
    );
  }
}