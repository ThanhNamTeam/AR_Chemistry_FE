class ExperimentQuizQuestion {
  final String id;
  final String questionTextVi;
  final String questionTextEn;
  final List<String> optionsVi;
  final List<String> optionsEn;
  final int correctIndex;
  final String explanationVi;
  final String explanationEn;

  const ExperimentQuizQuestion({
    required this.id,
    required this.questionTextVi,
    required this.questionTextEn,
    required this.optionsVi,
    required this.optionsEn,
    required this.correctIndex,
    required this.explanationVi,
    required this.explanationEn,
  });

  String questionText(bool isVi) => isVi ? questionTextVi : questionTextEn;

  List<String> options(bool isVi) => isVi ? optionsVi : optionsEn;

  String explanation(bool isVi) => isVi ? explanationVi : explanationEn;
}
