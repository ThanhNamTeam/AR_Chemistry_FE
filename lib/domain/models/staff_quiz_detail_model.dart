import '../../core/models/response/page_response.dart';
import 'staff_quiz_question_model.dart';

class StaffQuizDetailModel {
  final String quizCode;
  final String lessonCode;
  final String title;
  final String status;
  final String? generatedBy;
  final int? version;
  final PageResponse<StaffQuizQuestionModel> questions;

  const StaffQuizDetailModel({
    required this.quizCode,
    required this.lessonCode,
    required this.title,
    required this.status,
    this.generatedBy,
    this.version,
    required this.questions,
  });

  factory StaffQuizDetailModel.fromJson(Map<String, dynamic> json) {
    return StaffQuizDetailModel(
      quizCode: json['quizCode'] as String? ?? '',
      lessonCode: json['lessonCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      generatedBy: json['generatedBy'] as String?,
      version: json['version'] as int?,
      questions: PageResponse<StaffQuizQuestionModel>.fromJson(
        json['questions'] as Map<String, dynamic>,
            (item) => StaffQuizQuestionModel.fromJson(item),
      ),
    );
  }
}