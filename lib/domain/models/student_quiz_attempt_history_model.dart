class StudentQuizAttemptHistoryModel {
  final String attemptCode;

  final String quizCode;
  final String quizTitle;

  final String reactionId;
  final String reactionCode;
  final String reactionName;
  final String equation;
  final int grade;
  final String reactionCategory;

  final int score;
  final int totalQuestions;
  final int correctCount;

  final String status;

  final DateTime? startedAt;
  final DateTime? expiredAt;
  final DateTime? submittedAt;

  const StudentQuizAttemptHistoryModel({
    required this.attemptCode,
    required this.quizCode,
    required this.quizTitle,
    required this.reactionId,
    required this.reactionCode,
    required this.reactionName,
    required this.equation,
    required this.grade,
    required this.reactionCategory,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.status,
    this.startedAt,
    this.expiredAt,
    this.submittedAt,
  });

  factory StudentQuizAttemptHistoryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StudentQuizAttemptHistoryModel(
      attemptCode:
      json['attemptCode']?.toString() ?? '',

      quizCode:
      json['quizCode']?.toString() ?? '',

      quizTitle:
      json['quizTitle']?.toString() ??
          json['title']?.toString() ??
          '',

      reactionId:
      json['reactionId']?.toString() ?? '',

      reactionCode:
      json['reactionCode']?.toString() ?? '',

      reactionName:
      json['reactionName']?.toString() ?? '',

      equation:
      json['equation']?.toString() ?? '',

      grade:
      (json['grade'] as num?)?.toInt() ?? 0,

      reactionCategory:
      json['reactionCategory']?.toString() ?? '',

      score:
      (json['score'] as num?)?.toInt() ?? 0,

      totalQuestions:
      (json['totalQuestions'] as num?)?.toInt() ?? 0,

      correctCount:
      (json['correctCount'] as num?)?.toInt() ?? 0,

      status:
      json['status']?.toString() ?? '',

      startedAt: _parseDateTime(
        json['startedAt'],
      ),

      expiredAt: _parseDateTime(
        json['expiredAt'],
      ),

      submittedAt: _parseDateTime(
        json['submittedAt'],
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