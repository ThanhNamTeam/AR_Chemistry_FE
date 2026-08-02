/// Models cho luồng quiz MỚI: quiz gắn theo phản ứng, mở khoá bằng AR.
/// Khớp các DTO trong StudentQuizController của backend.
library;

/// Một phản ứng trong danh sách duyệt (GET /student/reactions).
/// Backend trả sẵn các cờ hành động — UI chỉ việc tuân theo.
class StudentReactionModel {
  final String reactionId;
  final String reactionCode;
  final String reactionName;
  final String equation;
  final int grade;
  final String reactionCategory;
  final bool completed;
  final bool hasRunningAttempt;
  final String? activeAttemptCode;
  final int? remainingSeconds;
  final String? latestCompletedAttemptCode;
  final bool canStart;
  final bool canContinue;
  final bool canViewHistory;
  final bool canRetry;

  const StudentReactionModel({
    required this.reactionId,
    required this.reactionCode,
    required this.reactionName,
    required this.equation,
    required this.grade,
    required this.reactionCategory,
    required this.completed,
    required this.hasRunningAttempt,
    required this.canStart,
    required this.canContinue,
    required this.canViewHistory,
    required this.canRetry,
    this.activeAttemptCode,
    this.remainingSeconds,
    this.latestCompletedAttemptCode,
  });

  factory StudentReactionModel.fromJson(Map<String, dynamic> json) {
    return StudentReactionModel(
      reactionId: json['reactionId'] as String? ?? '',
      reactionCode: json['reactionCode'] as String? ?? '',
      reactionName: json['reactionName'] as String? ?? '',
      equation: json['equation'] as String? ?? '',
      grade: (json['grade'] as num?)?.toInt() ?? 0,
      reactionCategory: json['reactionCategory'] as String? ?? '',
      completed: json['completed'] == true,
      hasRunningAttempt: json['hasRunningAttempt'] == true,
      activeAttemptCode: json['activeAttemptCode'] as String?,
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt(),
      latestCompletedAttemptCode:
          json['latestCompletedAttemptCode'] as String?,
      canStart: json['canStart'] == true,
      canContinue: json['canContinue'] == true,
      canViewHistory: json['canViewHistory'] == true,
      canRetry: json['canRetry'] == true,
    );
  }
}

/// Trạng thái một attempt (GET /quiz-attempts/{code}/state).
/// status: WAITING_AR / RUNNING / SUBMITTED / TIMEOUT / ABANDONED.
class QuizAttemptStateModel {
  final String attemptCode;
  final String quizCode;
  final String reactionId;
  final String status;
  final bool arCompleted;
  final bool quizUnlocked;
  final int? remainingSeconds;
  final bool submitted;

  const QuizAttemptStateModel({
    required this.attemptCode,
    required this.quizCode,
    required this.reactionId,
    required this.status,
    required this.arCompleted,
    required this.quizUnlocked,
    required this.submitted,
    this.remainingSeconds,
  });

  factory QuizAttemptStateModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptStateModel(
      attemptCode: json['attemptCode'] as String? ?? '',
      quizCode: json['quizCode'] as String? ?? '',
      reactionId: json['reactionId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      arCompleted: json['arCompleted'] == true,
      quizUnlocked: json['quizUnlocked'] == true,
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt(),
      submitted: json['submitted'] == true,
    );
  }

  bool get isEnded =>
      submitted || status == 'SUBMITTED' || status == 'TIMEOUT';
}

class QuizOptionModel {
  final String optionKey;
  final String optionText;
  final int optionOrder;

  const QuizOptionModel({
    required this.optionKey,
    required this.optionText,
    required this.optionOrder,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      optionKey: json['optionKey'] as String? ?? '',
      optionText: json['optionText'] as String? ?? '',
      optionOrder: (json['optionOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

class QuizQuestionModel {
  final String questionId;
  final int questionOrder;
  final String questionText;

  /// Đáp án đã lưu server-side — attempt tiếp tục giữa chừng vẫn còn.
  final String? selectedAnswer;
  final List<QuizOptionModel> options;

  const QuizQuestionModel({
    required this.questionId,
    required this.questionOrder,
    required this.questionText,
    required this.options,
    this.selectedAnswer,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? const [];
    final options = rawOptions
        .whereType<Map<String, dynamic>>()
        .map(QuizOptionModel.fromJson)
        .toList()
      ..sort((a, b) => a.optionOrder.compareTo(b.optionOrder));
    return QuizQuestionModel(
      questionId: json['questionId'] as String? ?? '',
      questionOrder: (json['questionOrder'] as num?)?.toInt() ?? 0,
      questionText: json['questionText'] as String? ?? '',
      selectedAnswer: json['selectedAnswer'] as String?,
      options: options,
    );
  }
}

/// Nội dung bài làm (GET /quiz-attempts/{code}/content) — chỉ lấy được khi
/// AR đã xong và attempt đang RUNNING.
class QuizContentModel {
  final String attemptCode;
  final String reactionName;
  final String equation;
  final String script;
  final int remainingSeconds;
  final List<QuizQuestionModel> questions;

  const QuizContentModel({
    required this.attemptCode,
    required this.reactionName,
    required this.equation,
    required this.script,
    required this.remainingSeconds,
    required this.questions,
  });

  factory QuizContentModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? const [];
    final questions = rawQuestions
        .whereType<Map<String, dynamic>>()
        .map(QuizQuestionModel.fromJson)
        .toList()
      ..sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
    return QuizContentModel(
      attemptCode: json['attemptCode'] as String? ?? '',
      reactionName: json['reactionName'] as String? ?? '',
      equation: json['equation'] as String? ?? '',
      script: json['script'] as String? ?? '',
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt() ?? 0,
      questions: questions,
    );
  }
}

/// Kết quả start attempt (POST /reactions/{id}/attempts).
class StartQuizModel {
  final String attemptCode;
  final String quizCode;
  final String status;

  const StartQuizModel({
    required this.attemptCode,
    required this.quizCode,
    required this.status,
  });

  factory StartQuizModel.fromJson(Map<String, dynamic> json) {
    return StartQuizModel(
      attemptCode: json['attemptCode'] as String? ?? '',
      quizCode: json['quizCode'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
