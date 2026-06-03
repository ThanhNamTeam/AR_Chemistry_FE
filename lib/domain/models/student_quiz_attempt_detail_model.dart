class StudentQuizAttemptDetailModel {
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

  final List<StudentQuizAttemptAnswerDetailModel> answers;

  const StudentQuizAttemptDetailModel({
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
    required this.answers,
  });

  factory StudentQuizAttemptDetailModel.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as List<dynamic>? ?? [];

    return StudentQuizAttemptDetailModel(
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
      answers: rawAnswers
          .map(
            (item) => StudentQuizAttemptAnswerDetailModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class StudentQuizAttemptAnswerDetailModel {
  final String questionId;
  final int? questionOrder;
  final String questionText;

  final String? studentAnswer;
  final String? correctAnswer;
  final bool correct;
  final String? explanation;

  const StudentQuizAttemptAnswerDetailModel({
    required this.questionId,
    this.questionOrder,
    required this.questionText,
    this.studentAnswer,
    this.correctAnswer,
    required this.correct,
    this.explanation,
  });

  factory StudentQuizAttemptAnswerDetailModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StudentQuizAttemptAnswerDetailModel(
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