import 'experiment_quiz_question.dart';
import 'reaction_category.dart';

class StudentExperimentReaction {
  final String code;
  final String nameVi;
  final String nameEn;
  final String equation;
  final int grade;
  final ReactionCategory category;
  final String scriptVi;
  final String scriptEn;
  final List<String> reactantLabels;
  final List<ExperimentQuizQuestion> questions;

  const StudentExperimentReaction({
    required this.code,
    required this.nameVi,
    required this.nameEn,
    required this.equation,
    required this.grade,
    required this.category,
    required this.scriptVi,
    required this.scriptEn,
    required this.reactantLabels,
    required this.questions,
  });

  String name(bool isVi) => isVi ? nameVi : nameEn;

  String script(bool isVi) => isVi ? scriptVi : scriptEn;
}
