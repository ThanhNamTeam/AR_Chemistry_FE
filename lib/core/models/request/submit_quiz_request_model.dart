class SubmitQuizRequestModel {
  final List<StudentAnswerModel> answers;

  const SubmitQuizRequestModel({
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class StudentAnswerModel {
  final String questionId;
  final String answer;

  const StudentAnswerModel({
    required this.questionId,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
    };
  }
}