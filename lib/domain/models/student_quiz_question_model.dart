class StudentQuizQuestionModel {
  final String id;
  final int? questionOrder;
  final String type;
  final String questionText;
  final String? optionsJson;
  final String? difficulty;

  const StudentQuizQuestionModel({
    required this.id,
    this.questionOrder,
    required this.type,
    required this.questionText,
    this.optionsJson,
    this.difficulty,
  });

  factory StudentQuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return StudentQuizQuestionModel(
      id: json['id']?.toString() ?? '',
      questionOrder: json['questionOrder'] as int?,
      type: json['type'] as String? ?? '',
      questionText: json['questionText'] as String? ?? '',
      optionsJson: json['optionsJson'] as String?,
      difficulty: json['difficulty'] as String?,
    );
  }
}