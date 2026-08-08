class ExperimentQuestionResult {
  final String questionId;
  final String questionText;
  final List<String> options;
  final int selectedIndex;
  final int correctIndex;
  final String explanation;

  const ExperimentQuestionResult({
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    required this.explanation,
  });

  bool get isCorrect => selectedIndex == correctIndex;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'questionText': questionText,
        'options': options,
        'selectedIndex': selectedIndex,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };

  factory ExperimentQuestionResult.fromJson(Map<String, dynamic> json) {
    return ExperimentQuestionResult(
      questionId: json['questionId'] as String? ?? '',
      questionText: json['questionText'] as String? ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      selectedIndex: json['selectedIndex'] as int? ?? -1,
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class ExperimentAttemptRecord {
  final String reactionCode;
  final int grade;
  final String categoryKey;
  final int score;
  final int total;
  final DateTime completedAt;
  final List<ExperimentQuestionResult> results;

  const ExperimentAttemptRecord({
    required this.reactionCode,
    required this.grade,
    required this.categoryKey,
    required this.score,
    required this.total,
    required this.completedAt,
    required this.results,
  });

  Map<String, dynamic> toJson() => {
        'reactionCode': reactionCode,
        'grade': grade,
        'categoryKey': categoryKey,
        'score': score,
        'total': total,
        'completedAt': completedAt.toIso8601String(),
        'results': results.map((r) => r.toJson()).toList(),
      };

  factory ExperimentAttemptRecord.fromJson(Map<String, dynamic> json) {
    return ExperimentAttemptRecord(
      reactionCode: json['reactionCode'] as String? ?? '',
      grade: json['grade'] as int? ?? 8,
      categoryKey: json['categoryKey'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 5,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      results: (json['results'] as List?)
              ?.map((e) => ExperimentQuestionResult.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList() ??
          const [],
    );
  }
}
