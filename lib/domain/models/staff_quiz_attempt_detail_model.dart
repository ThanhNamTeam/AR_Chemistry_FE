class StaffQuizAttemptDetailModel {
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

  final List<StaffQuizAttemptAnswerModel> answers;

  const StaffQuizAttemptDetailModel({
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
    required this.answers,
  });

  factory StaffQuizAttemptDetailModel.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as List<dynamic>? ?? [];

    return StaffQuizAttemptDetailModel(
      attemptCode: json['attemptCode'] as String? ?? '',
      studentId: json['studentId'] as String?,
      studentName: json['studentName'] as String? ?? 'Unknown student',
      studentEmail: json['studentEmail'] as String?,
      quizCode: json['quizCode'] as String? ?? '',
      quizTitle: json['quizTitle'] as String? ?? '',
      lessonCode: json['lessonCode'] as String? ?? '',
      lessonTitle: json['lessonTitle'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? ''),
      answers: rawAnswers
          .map(
            (item) => StaffQuizAttemptAnswerModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class StaffQuizAttemptAnswerModel {
  final String questionId;
  final int? questionOrder;
  final String questionText;

  final String? studentAnswer;
  final String? correctAnswer;
  final bool correct;
  final String? explanation;

  const StaffQuizAttemptAnswerModel({
    required this.questionId,
    this.questionOrder,
    required this.questionText,
    this.studentAnswer,
    this.correctAnswer,
    required this.correct,
    this.explanation,
  });

  factory StaffQuizAttemptAnswerModel.fromJson(Map<String, dynamic> json) {
    return StaffQuizAttemptAnswerModel(
      questionId: json['questionId']?.toString() ?? '',
      questionOrder: json['questionOrder'] as int?,
      questionText: json['questionText'] as String? ?? '',
      studentAnswer: json['studentAnswer'] as String?,
      correctAnswer: json['correctAnswer'] as String?,
      correct: json['correct'] as bool? ?? false,
      explanation: json['explanation'] as String?,
    );
  }
}