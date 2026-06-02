class SubmitQuizResponseModel {
  final int score;
  final int total;
  final int correctCount;
  final List<QuestionResultModel> results;

  const SubmitQuizResponseModel({
    required this.score,
    required this.total,
    required this.correctCount,
    required this.results,
  });

  factory SubmitQuizResponseModel.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? [];

    return SubmitQuizResponseModel(
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      results: rawResults
          .map(
            (item) => QuestionResultModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class QuestionResultModel {
  final String questionId;
  final bool correct;
  final String? studentAnswer;
  final String? correctAnswer;
  final String? explanation;

  const QuestionResultModel({
    required this.questionId,
    required this.correct,
    this.studentAnswer,
    this.correctAnswer,
    this.explanation,
  });

  factory QuestionResultModel.fromJson(Map<String, dynamic> json) {
    return QuestionResultModel(
      questionId: json['questionId']?.toString() ?? '',
      correct: json['correct'] as bool? ?? false,
      studentAnswer: json['studentAnswer'] as String?,
      correctAnswer: json['correctAnswer'] as String?,
      explanation: json['explanation'] as String?,
    );
  }
}