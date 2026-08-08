class StaffReactionQuizPromptModel {
  final String reactionCode;
  final String reactionName;
  final String prompt;

  const StaffReactionQuizPromptModel({
    required this.reactionCode,
    required this.reactionName,
    required this.prompt,
  });

  factory StaffReactionQuizPromptModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StaffReactionQuizPromptModel(
      reactionCode: json['reactionCode'] as String,
      reactionName: json['reactionName'] as String,
      prompt: json['prompt'] as String,
    );
  }
}