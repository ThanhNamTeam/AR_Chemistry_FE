class StudentQuizAttemptAnswerDetailModel {
  final String questionId;
  final int questionOrder;
  final String questionText;

  final String? studentAnswer;
  final String? correctAnswer;

  final bool correct;
  final String? explanation;
  final DateTime? answeredAt;

  const StudentQuizAttemptAnswerDetailModel({
    required this.questionId,
    required this.questionOrder,
    required this.questionText,
    this.studentAnswer,
    this.correctAnswer,
    required this.correct,
    this.explanation,
    this.answeredAt,
  });

  factory StudentQuizAttemptAnswerDetailModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StudentQuizAttemptAnswerDetailModel(
      questionId: json['questionId']?.toString() ?? '',
      questionOrder:
      (json['questionOrder'] as num?)?.toInt() ?? 0,
      questionText:
      json['questionText']?.toString() ?? '',
      studentAnswer:
      json['studentAnswer']?.toString() ??
          json['selectedAnswer']?.toString(),
      correctAnswer:
      json['correctAnswer']?.toString(),
      correct:
      json['correct'] as bool? ??
          json['isCorrect'] as bool? ??
          false,
      explanation:
      json['explanation']?.toString(),
      answeredAt: _parseDateTime(
        json['answeredAt'],
      ),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}