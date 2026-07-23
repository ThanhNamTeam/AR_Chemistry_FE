class StaffQuizAttemptModel {
  final String attemptCode;

  final String? studentId;
  final String studentName;
  final String? studentEmail;

  final String quizCode;
  final String quizTitle;

  final String lessonCode;
  final String lessonTitle;

  final int score;
  final int totalQuestions;
  final int correctCount;

  final String status;
  final DateTime? submittedAt;

  const StaffQuizAttemptModel({
    required this.attemptCode,
    this.studentId,
    required this.studentName,
    this.studentEmail,
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

  factory StaffQuizAttemptModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StaffQuizAttemptModel(
      attemptCode:
      json['attemptCode']?.toString() ?? '',

      studentId:
      json['studentId']?.toString(),

      studentName:
      json['studentName']?.toString() ??
          'Unknown student',

      studentEmail:
      json['studentEmail']?.toString(),

      quizCode:
      json['quizCode']?.toString() ?? '',

      quizTitle:
      json['quizTitle']?.toString() ?? '',

      lessonCode:
      json['lessonCode']?.toString() ?? '',

      lessonTitle:
      json['lessonTitle']?.toString() ?? '',

      score:
      (json['score'] as num?)?.toInt() ?? 0,

      totalQuestions:
      (json['totalQuestions'] as num?)?.toInt() ?? 0,

      correctCount:
      (json['correctCount'] as num?)?.toInt() ?? 0,

      status:
      json['status']?.toString() ?? '',

      submittedAt: DateTime.tryParse(
        json['submittedAt']?.toString() ?? '',
      ),
    );
  }
}