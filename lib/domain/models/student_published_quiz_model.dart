class StudentPublishedQuizModel {
  final String lessonCode;
  final String lessonTitle;
  final String? chapter;
  final String quizCode;
  final String quizTitle;
  final int? version;
  final int questionCount;

  const StudentPublishedQuizModel({
    required this.lessonCode,
    required this.lessonTitle,
    this.chapter,
    required this.quizCode,
    required this.quizTitle,
    this.version,
    required this.questionCount,
  });

  factory StudentPublishedQuizModel.fromJson(Map<String, dynamic> json) {
    return StudentPublishedQuizModel(
      lessonCode: json['lessonCode'] as String? ?? '',
      lessonTitle: json['lessonTitle'] as String? ?? '',
      chapter: json['chapter'] as String?,
      quizCode: json['quizCode'] as String? ?? '',
      quizTitle: json['quizTitle'] as String? ?? '',
      version: json['version'] as int?,
      questionCount: json['questionCount'] as int? ?? 0,
    );
  }
}