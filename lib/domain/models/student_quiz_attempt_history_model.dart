class StudentQuizAttemptHistoryModel {
  final String attemptCode;
  final String quizCode;
  final String quizTitle;
  final String lessonCode;
  final String lessonTitle;
  final int score;
  final int totalQuestions;
  final int correctCount;
  final String status;
  final DateTime? submittedAt;

  const StudentQuizAttemptHistoryModel({
    required this.attemptCode,
    required this.quizCode,
    required this.quizTitle,
    required this.lessonCode,
    required this.lessonTitle,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.status,
    this.submittedAt,
  });

  factory StudentQuizAttemptHistoryModel.fromJson(Map<String, dynamic> json) {
    return StudentQuizAttemptHistoryModel(
      attemptCode: json['attemptCode'] as String? ?? '',
      quizCode: json['quizCode'] as String? ?? '',
      quizTitle: json['quizTitle'] as String? ?? '',
      lessonCode: json['lessonCode'] as String? ?? '',
      lessonTitle: json['lessonTitle'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? ''),
    );
  }
}