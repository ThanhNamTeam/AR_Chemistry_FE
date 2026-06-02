import 'package:flutter/foundation.dart';

import '../../../core/api/student_quiz_api.dart';
import '../../../core/models/request/submit_quiz_request_model.dart';
import '../../../core/models/response/submit_quiz_response_model.dart';
import '../../../domain/models/student_published_quiz_model.dart';
import '../../../domain/models/student_quiz_detail_model.dart';
import '../../../domain/models/student_quiz_summary_model.dart';


class StudentQuizProvider extends ChangeNotifier {
  final StudentQuizApi _studentQuizApi = StudentQuizApi();

  StudentQuizSummaryModel? _quizSummary;
  StudentQuizDetailModel? _quizDetail;
  SubmitQuizResponseModel? _submitResult;

  bool _loadingSummary = false;
  bool _loadingQuestions = false;
  bool _submitting = false;

  List<StudentPublishedQuizModel> _publishedQuizzes = [];
  bool _loadingPublishedQuizzes = false;
  String? _publishedQuizzesError;

  List<StudentPublishedQuizModel> get publishedQuizzes =>
      List.unmodifiable(_publishedQuizzes);

  bool get loadingPublishedQuizzes => _loadingPublishedQuizzes;

  String? get publishedQuizzesError => _publishedQuizzesError;

  String? _summaryError;
  String? _questionsError;
  String? _submitError;

  final Map<String, String> _answers = {};

  StudentQuizSummaryModel? get quizSummary => _quizSummary;
  StudentQuizDetailModel? get quizDetail => _quizDetail;
  SubmitQuizResponseModel? get submitResult => _submitResult;

  bool get loadingSummary => _loadingSummary;
  bool get loadingQuestions => _loadingQuestions;
  bool get submitting => _submitting;

  String? get summaryError => _summaryError;
  String? get questionsError => _questionsError;
  String? get submitError => _submitError;

  Map<String, String> get answers => Map.unmodifiable(_answers);

  bool get hasQuiz => _quizSummary != null;

  bool get hasLoadedQuestions => _quizDetail != null;

  int get totalQuestions => _quizDetail?.questions.length ?? 0;

  int get answeredCount => _answers.length;

  bool get canSubmit {
    final total = totalQuestions;
    if (total == 0) return false;
    return answeredCount == total;
  }

  Future<void> loadPublishedQuizByLesson(String lessonCode) async {
    _loadingSummary = true;
    _summaryError = null;
    _quizSummary = null;
    _quizDetail = null;
    _submitResult = null;
    _answers.clear();
    notifyListeners();

    try {
      _quizSummary = await _studentQuizApi.getPublishedQuizByLesson(
        lessonCode: lessonCode,
      );
    } catch (e) {
      _summaryError = e.toString();
    } finally {
      _loadingSummary = false;
      notifyListeners();
    }
  }

  Future<void> loadPublishedQuizzes() async {
    _loadingPublishedQuizzes = true;
    _publishedQuizzesError = null;
    notifyListeners();

    try {
      _publishedQuizzes = await _studentQuizApi.getPublishedQuizzes();
    } catch (e) {
      _publishedQuizzesError = e.toString();
    } finally {
      _loadingPublishedQuizzes = false;
      notifyListeners();
    }
  }

  Future<void> loadQuizQuestions(String quizCode) async {
    _loadingQuestions = true;
    _questionsError = null;
    _quizDetail = null;
    _submitResult = null;
    _answers.clear();
    notifyListeners();

    try {
      _quizDetail = await _studentQuizApi.getQuizQuestions(
        quizCode: quizCode,
      );
    } catch (e) {
      _questionsError = e.toString();
    } finally {
      _loadingQuestions = false;
      notifyListeners();
    }
  }

  void selectAnswer({
    required String questionId,
    required String answer,
  }) {
    _answers[questionId] = answer;
    notifyListeners();
  }

  Future<void> submitCurrentQuiz() async {
    final quizCode = _quizDetail?.quizCode;
    if (quizCode == null || quizCode.isEmpty) return;

    _submitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final request = SubmitQuizRequestModel(
        answers: _answers.entries
            .map(
              (entry) => StudentAnswerModel(
            questionId: entry.key,
            answer: entry.value,
          ),
        )
            .toList(),
      );

      _submitResult = await _studentQuizApi.submitQuiz(
        quizCode: quizCode,
        request: request,
      );
    } catch (e) {
      _submitError = e.toString();
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void resetQuizSession() {
    _quizDetail = null;
    _submitResult = null;
    _questionsError = null;
    _submitError = null;
    _answers.clear();
    notifyListeners();
  }
}