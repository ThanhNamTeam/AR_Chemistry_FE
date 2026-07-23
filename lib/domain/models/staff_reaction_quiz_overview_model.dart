class StaffReactionQuizOverviewModel {
  final String reactionId;
  final String reactionCode;
  final String reactionName;
  final String equation;
  final int grade;
  final String reactionCategory;
  final String reactionType;
  final bool active;
  final bool hasQuiz;

  final String? latestQuizCode;
  final String? latestQuizTitle;
  final String? latestQuizStatus;
  final int? latestQuizVersion;

  final int questionCount;

  const StaffReactionQuizOverviewModel({
    required this.reactionId,
    required this.reactionCode,
    required this.reactionName,
    required this.equation,
    required this.grade,
    required this.reactionCategory,
    required this.reactionType,
    required this.active,
    required this.hasQuiz,
    this.latestQuizCode,
    this.latestQuizTitle,
    this.latestQuizStatus,
    this.latestQuizVersion,
    required this.questionCount,
  });

  factory StaffReactionQuizOverviewModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StaffReactionQuizOverviewModel(
      reactionId: json['reactionId']?.toString() ?? '',
      reactionCode: json['reactionCode']?.toString() ?? '',
      reactionName: json['reactionName']?.toString() ?? '',
      equation: json['equation']?.toString() ?? '',
      grade: (json['grade'] as num?)?.toInt() ?? 0,
      reactionCategory:
      json['reactionCategory']?.toString() ?? '',
      reactionType: json['reactionType']?.toString() ?? '',
      active: json['active'] as bool? ?? false,
      hasQuiz: json['hasQuiz'] as bool? ?? false,
      latestQuizCode: json['latestQuizCode']?.toString(),
      latestQuizTitle: json['latestQuizTitle']?.toString(),
      latestQuizStatus: json['latestQuizStatus']?.toString(),
      latestQuizVersion:
      (json['latestQuizVersion'] as num?)?.toInt(),
      questionCount:
      (json['questionCount'] as num?)?.toInt() ?? 0,
    );
  }
}