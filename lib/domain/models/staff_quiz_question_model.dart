class StaffQuizQuestionModel {
  final String id;
  final int? questionOrder;
  final String type;
  final String questionText;
  final String? optionsJson;
  final String? correctAnswer;
  final String? explanation;
  final String? difficulty;
  final String? status;

  const StaffQuizQuestionModel({
    required this.id,
    this.questionOrder,
    required this.type,
    required this.questionText,
    this.optionsJson,
    this.correctAnswer,
    this.explanation,
    this.difficulty,
    this.status,
  });

  factory StaffQuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return StaffQuizQuestionModel(
      id: json['id']?.toString() ?? '',
      questionOrder: json['questionOrder'] as int?,
      type: json['type'] as String? ?? '',
      questionText: json['questionText'] as String? ?? '',
      optionsJson: json['optionsJson'] as String?,
      correctAnswer: json['correctAnswer'] as String?,
      explanation: json['explanation'] as String?,
      difficulty: json['difficulty'] as String?,
      status: json['status'] as String?,
    );
  }
}