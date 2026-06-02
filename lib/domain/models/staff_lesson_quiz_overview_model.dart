class StaffLessonQuizOverviewModel {
  final String lessonCode;
  final int? lessonNumber;
  final String lessonTitle;
  final String? chapter;

  final bool hasQuiz;

  final String? latestQuizCode;
  final String? latestQuizTitle;
  final String? latestQuizStatus;
  final int? latestQuizVersion;

  final int questionCount;

  const StaffLessonQuizOverviewModel({
    required this.lessonCode,
    this.lessonNumber,
    required this.lessonTitle,
    this.chapter,
    required this.hasQuiz,
    this.latestQuizCode,
    this.latestQuizTitle,
    this.latestQuizStatus,
    this.latestQuizVersion,
    required this.questionCount,
  });

  factory StaffLessonQuizOverviewModel.fromJson(Map<String, dynamic> json) {
    return StaffLessonQuizOverviewModel(
      lessonCode: json['lessonCode'] as String? ?? '',
      lessonNumber: json['lessonNumber'] as int?,
      lessonTitle: json['lessonTitle'] as String? ?? '',
      chapter: json['chapter'] as String?,
      hasQuiz: json['hasQuiz'] as bool? ?? false,
      latestQuizCode: json['latestQuizCode'] as String?,
      latestQuizTitle: json['latestQuizTitle'] as String?,
      latestQuizStatus: json['latestQuizStatus'] as String?,
      latestQuizVersion: json['latestQuizVersion'] as int?,
      questionCount: json['questionCount'] as int? ?? 0,
    );
  }
}