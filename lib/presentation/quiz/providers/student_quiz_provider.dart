import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/api/student_quiz_api.dart';
import '../../../core/models/response/submit_quiz_response_model.dart';
import '../../../domain/models/student_quiz_attempt_detail_model.dart';
import '../../../domain/models/student_quiz_attempt_history_model.dart';
import '../../../domain/models/student_quiz_detail_model.dart';
import '../../../domain/models/student_quiz_summary_model.dart';
import '../../../domain/models/student_reaction_detail_model.dart';
import '../../../domain/models/student_reaction_model.dart';

class StudentQuizProvider extends ChangeNotifier {
  final StudentQuizApi _studentQuizApi = StudentQuizApi();

  // =========================
  // Reaction và quiz summary
  // =========================

  List<StudentReactionModel> _reactions = [];

  bool _loadingReactions = false;
  String? _reactionsError;

  int _reactionPage = 0;
  int _reactionTotalPages = 0;
  bool _reactionLastPage = true;

  List<StudentReactionModel> get reactions =>
      List.unmodifiable(_reactions);

  StudentReactionDetailModel? _reactionDetail;

  bool _loadingReactionDetail = false;
  String? _reactionDetailError;

  StudentReactionDetailModel? get reactionDetail =>
      _reactionDetail;

  bool get loadingReactionDetail =>
      _loadingReactionDetail;

  String? get reactionDetailError =>
      _reactionDetailError;
  bool get loadingReactions => _loadingReactions;

  String? get reactionsError => _reactionsError;

  int get reactionPage => _reactionPage;

  int get reactionTotalPages => _reactionTotalPages;

  bool get reactionLastPage => _reactionLastPage;

  StudentQuizSummaryModel? _quizSummary;

  bool _loadingSummary = false;
  String? _summaryError;

  StudentQuizSummaryModel? get quizSummary => _quizSummary;

  bool get loadingSummary => _loadingSummary;

  String? get summaryError => _summaryError;

  bool get hasQuiz => _quizSummary != null;

  // =========================
  // Attempt hiện tại
  // =========================

  String? _reactionId;
  String? _attemptCode;
  String? _attemptStatus;

  bool _startingAttempt = false;
  String? _startAttemptError;

  String? get reactionId => _reactionId;

  String? get attemptCode => _attemptCode;

  String? get attemptStatus => _attemptStatus;

  bool get startingAttempt => _startingAttempt;

  String? get startAttemptError => _startAttemptError;

  bool get hasActiveAttempt {
    return _attemptCode != null &&
        _attemptCode!.isNotEmpty;
  }

  bool get waitingAr {
    return _attemptStatus == 'WAITING_AR';
  }

  bool get running {
    return _attemptStatus == 'RUNNING';
  }

  bool get submitted {
    return _attemptStatus == 'SUBMITTED';
  }

  bool get timedOut {
    return _attemptStatus == 'TIMEOUT';
  }

  bool get abandoned {
    return _attemptStatus == 'ABANDONED';
  }

  // =========================
  // AR
  // =========================

  bool _completingAr = false;
  String? _completeArError;

  bool get completingAr => _completingAr;

  String? get completeArError => _completeArError;

  // =========================
  // Attempt state và timer
  // =========================

  bool _loadingAttemptState = false;
  String? _attemptStateError;

  int _remainingSeconds = 0;
  DateTime? _expiredAt;

  Timer? _countdownTimer;

  bool get loadingAttemptState =>
      _loadingAttemptState;

  String? get attemptStateError =>
      _attemptStateError;

  int get remainingSeconds => _remainingSeconds;

  DateTime? get expiredAt => _expiredAt;

  String get formattedRemainingTime {
    final safeSeconds =
    _remainingSeconds < 0 ? 0 : _remainingSeconds;

    final minutes = safeSeconds ~/ 60;
    final seconds = safeSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // =========================
  // Quiz content
  // =========================

  StudentQuizDetailModel? _quizDetail;

  bool _loadingQuizContent = false;
  String? _quizContentError;

  StudentQuizDetailModel? get quizDetail =>
      _quizDetail;

  bool get loadingQuizContent =>
      _loadingQuizContent;

  String? get quizContentError =>
      _quizContentError;

  bool get hasLoadedQuestions =>
      _quizDetail != null;

  int get totalQuestions =>
      _quizDetail?.questions.length ?? 0;

  // Các getter cũ để màn hình chưa báo lỗi ngay.
  bool get loadingQuestions =>
      _loadingQuizContent;

  String? get questionsError =>
      _quizContentError;

  // =========================
  // Answer
  // =========================

  final Map<String, String> _answers = {};

  final Set<String> _savingQuestionIds = {};

  String? _saveAnswerError;

  Map<String, String> get answers =>
      Map.unmodifiable(_answers);

  String? get saveAnswerError =>
      _saveAnswerError;

  int get answeredCount => _answers.length;

  bool isSavingAnswer(String questionId) {
    return _savingQuestionIds.contains(questionId);
  }

  bool get canSubmit {
    if (!running) {
      return false;
    }

    final total = totalQuestions;

    if (total == 0) {
      return false;
    }

    return answeredCount == total;
  }

  // =========================
  // Submit
  // =========================

  SubmitQuizResponseModel? _submitResult;

  bool _submitting = false;
  String? _submitError;

  SubmitQuizResponseModel? get submitResult =>
      _submitResult;

  bool get submitting => _submitting;

  String? get submitError => _submitError;

  // =========================
  // Attempt result
  // =========================

  StudentQuizAttemptDetailModel? _attemptDetail;

  bool _loadingAttemptDetail = false;
  String? _attemptDetailError;

  StudentQuizAttemptDetailModel? get attemptDetail =>
      _attemptDetail;

  bool get loadingAttemptDetail =>
      _loadingAttemptDetail;

  String? get attemptDetailError =>
      _attemptDetailError;

  // =========================
  // Attempt history
  // =========================

  List<StudentQuizAttemptHistoryModel>
  _attemptHistory = [];

  bool _loadingAttemptHistory = false;
  String? _attemptHistoryError;

  List<StudentQuizAttemptHistoryModel>
  get attemptHistory =>
      List.unmodifiable(_attemptHistory);

  bool get loadingAttemptHistory =>
      _loadingAttemptHistory;

  String? get attemptHistoryError =>
      _attemptHistoryError;

  // ==================================================
  // 1. Lấy quiz đang publish theo reaction
  // ==================================================

  Future<void> loadPublishedQuizByReaction(
      String reactionId,
      ) async {
    _loadingSummary = true;
    _summaryError = null;

    _reactionId = reactionId;
    _quizSummary = null;

    _clearAttemptData(
      clearReaction: false,
    );

    notifyListeners();

    try {
      _quizSummary = await _studentQuizApi
          .getPublishedQuizByReaction(
        reactionId: reactionId,
      );
    } catch (e) {
      _summaryError = e.toString();
    } finally {
      _loadingSummary = false;
      notifyListeners();
    }
  }

  // ==================================================
  // 2. Bắt đầu attempt
  // ==================================================

  Future<void> loadReactions({
    required int grade,
    required String reactionCategory,
    String? keyword,
    int page = 0,
    int size = 10,
  }) async {

    debugPrint(
      '[LOAD-REACTIONS] grade=$grade, '
          'category=$reactionCategory, '
          'keyword=$keyword',
    );
    _loadingReactions = true;
    _reactionsError = null;

    if (page == 0) {
      _reactions = [];
    }

    notifyListeners();

    try {
      final result = await _studentQuizApi.getReactions(
        grade: grade,
        reactionCategory: reactionCategory,
        keyword: keyword,
        page: page,
        size: size,
      );

      debugPrint(
        '[LOAD-REACTIONS] items=${result.items.length}, '
            'page=${result.page}, '
            'totalPages=${result.totalPages}',
      );

      for (final reaction in result.items) {
        debugPrint(
          '[LOAD-REACTIONS] item: '
              'id=${reaction.reactionId}, '
              'code=${reaction.reactionCode}, '
              'name=${reaction.reactionName}',
        );
      }

      _reactions = result.items;
      _reactionPage = result.page;
      _reactionTotalPages = result.totalPages;
      _reactionLastPage = result.last;
    } catch (e) {
      _reactionsError = e.toString();
    } finally {
      _loadingReactions = false;
      notifyListeners();
    }
  }

  Future<void> loadReactionDetail(
      String reactionId,
      ) async {
    _loadingReactionDetail = true;
    _reactionDetailError = null;
    _reactionDetail = null;

    _reactionId = reactionId;

    notifyListeners();

    try {
      _reactionDetail =
      await _studentQuizApi.getReactionDetail(
        reactionId: reactionId,
      );
    } catch (e) {
      _reactionDetailError = e.toString();
    } finally {
      _loadingReactionDetail = false;
      notifyListeners();
    }
  }

  Future<void> selectReaction(
      String reactionId,
      ) async {
    resetQuizSession();

    _reactionId = reactionId;

    await loadReactionDetail(reactionId);

    if (_reactionDetail != null) {
      await loadPublishedQuizByReaction(
        reactionId,
      );
    }
  }

  Future<bool> startQuiz({
    required String reactionId,
  }) async {
    if (_startingAttempt) {
      return false;
    }

    _startingAttempt = true;
    _startAttemptError = null;
    _reactionId = reactionId;

    notifyListeners();

    try {
      final data = await _studentQuizApi.startQuiz(
        reactionId: reactionId,
      );

      _applyAttemptData(data);

      return _attemptCode != null &&
          _attemptCode!.isNotEmpty;
    } catch (e) {
      _startAttemptError = e.toString();
      return false;
    } finally {
      _startingAttempt = false;
      notifyListeners();
    }
  }

  // ==================================================
  // 3. Hoàn thành AR
  // ==================================================

  Future<bool> completeAr({
    required List<String> scannedCardCodes,
    required bool reactionSuccessful,
    String? arSessionCode,
  }) async {
    final currentAttemptCode = _attemptCode;

    if (currentAttemptCode == null ||
        currentAttemptCode.isEmpty) {
      _completeArError =
      'Không tìm thấy attempt hiện tại';

      notifyListeners();
      return false;
    }

    if (_completingAr) {
      return false;
    }

    _completingAr = true;
    _completeArError = null;

    notifyListeners();

    try {
      final data = await _studentQuizApi.completeAr(
        attemptCode: currentAttemptCode,
        scannedCardCodes: scannedCardCodes,
        reactionSuccessful: reactionSuccessful,
        arSessionCode: arSessionCode,
      );

      _applyAttemptData(data);

      if (_attemptStatus == 'RUNNING') {
        _startCountdown();
      }

      return _attemptStatus == 'RUNNING';
    } catch (e) {
      _completeArError = e.toString();
      return false;
    } finally {
      _completingAr = false;
      notifyListeners();
    }
  }

  // ==================================================
  // 4. Đồng bộ attempt state
  // ==================================================

  Future<void> syncAttemptState() async {
    final currentAttemptCode = _attemptCode;

    if (currentAttemptCode == null ||
        currentAttemptCode.isEmpty) {
      return;
    }

    _loadingAttemptState = true;
    _attemptStateError = null;

    notifyListeners();

    try {
      final data =
      await _studentQuizApi.getAttemptState(
        attemptCode: currentAttemptCode,
      );

      _applyAttemptData(data);

      if (_attemptStatus == 'RUNNING') {
        _startCountdown();
      } else {
        _stopCountdown();
      }
    } catch (e) {
      _attemptStateError = e.toString();
    } finally {
      _loadingAttemptState = false;
      notifyListeners();
    }
  }

  // ==================================================
  // 5. Lấy script và 5 câu hỏi
  // ==================================================

  Future<void> loadQuizContent() async {
    final currentAttemptCode = _attemptCode;

    if (currentAttemptCode == null ||
        currentAttemptCode.isEmpty) {
      _quizContentError =
      'Không tìm thấy attempt hiện tại';

      notifyListeners();
      return;
    }

    _loadingQuizContent = true;
    _quizContentError = null;

    _quizDetail = null;
    _submitResult = null;
    _answers.clear();

    notifyListeners();

    try {
      _quizDetail =
      await _studentQuizApi.getQuizContent(
        attemptCode: currentAttemptCode,
      );

      _remainingSeconds =
          _quizDetail?.remainingSeconds ?? 0;

      _expiredAt =
          _quizDetail?.expiredAt;

      _restoreSavedAnswersFromContent();

      if (_attemptStatus == 'RUNNING') {
        _startCountdown();
      }
    } catch (e) {
      _quizContentError = e.toString();
    } finally {
      _loadingQuizContent = false;
      notifyListeners();
    }
  }

  // ==================================================
  // 6. Chọn và lưu từng đáp án
  // ==================================================

  Future<void> selectAnswer({
    required String questionId,
    required String answer,
  }) async {
    final currentAttemptCode = _attemptCode;

    if (currentAttemptCode == null ||
        currentAttemptCode.isEmpty) {
      _saveAnswerError =
      'Không tìm thấy attempt hiện tại';

      notifyListeners();
      return;
    }

    if (!running) {
      _saveAnswerError =
      'Attempt hiện không ở trạng thái RUNNING';

      notifyListeners();
      return;
    }

    final previousAnswer = _answers[questionId];

    // Optimistic update để giao diện phản hồi ngay.
    _answers[questionId] = answer;
    _savingQuestionIds.add(questionId);
    _saveAnswerError = null;

    notifyListeners();

    try {
      await _studentQuizApi.saveAnswer(
        attemptCode: currentAttemptCode,
        questionId: questionId,
        selectedAnswer: answer,
      );
    } catch (e) {
      // API lỗi thì khôi phục đáp án trước đó.
      if (previousAnswer == null) {
        _answers.remove(questionId);
      } else {
        _answers[questionId] = previousAnswer;
      }

      _saveAnswerError = e.toString();
    } finally {
      _savingQuestionIds.remove(questionId);
      notifyListeners();
    }
  }

  // ==================================================
  // 7. Submit attempt
  // ==================================================

  Future<bool> submitCurrentAttempt() async {
    final currentAttemptCode = _attemptCode;

    if (currentAttemptCode == null ||
        currentAttemptCode.isEmpty) {
      _submitError =
      'Không tìm thấy attempt hiện tại';

      notifyListeners();
      return false;
    }

    if (!canSubmit) {
      _submitError =
      'Bạn cần trả lời đầy đủ các câu hỏi';

      notifyListeners();
      return false;
    }

    if (_submitting) {
      return false;
    }

    _submitting = true;
    _submitError = null;

    notifyListeners();

    try {
      _submitResult =
      await _studentQuizApi.submitAttempt(
        attemptCode: currentAttemptCode,
      );

      _attemptStatus = 'SUBMITTED';
      _stopCountdown();

      return true;
    } catch (e) {
      _submitError = e.toString();
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  // Giữ tên cũ tạm thời để màn hình cũ chưa báo lỗi.
  Future<void> submitCurrentQuiz() async {
    await submitCurrentAttempt();
  }

  // ==================================================
  // 8. Lấy chi tiết kết quả
  // ==================================================

  Future<void> loadAttemptDetail(
      String attemptCode,
      ) async {
    _loadingAttemptDetail = true;
    _attemptDetailError = null;
    _attemptDetail = null;

    notifyListeners();

    try {
      _attemptDetail = await _studentQuizApi
          .getQuizAttemptResult(
        attemptCode: attemptCode,
      );
    } catch (e) {
      _attemptDetailError = e.toString();
    } finally {
      _loadingAttemptDetail = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentAttemptResult() async {
    final currentAttemptCode = _attemptCode;

    if (currentAttemptCode == null ||
        currentAttemptCode.isEmpty) {
      return;
    }

    await loadAttemptDetail(
      currentAttemptCode,
    );
  }

  // ==================================================
  // 9. Lịch sử theo reaction
  // ==================================================

  Future<void> loadAttemptHistory({
    required String reactionId,
    int page = 0,
    int size = 10,
  }) async {
    _loadingAttemptHistory = true;
    _attemptHistoryError = null;

    notifyListeners();

    try {
      final result = await _studentQuizApi
          .getReactionAttemptHistory(
        reactionId: reactionId,
        page: page,
        size: size,
      );

      _attemptHistory = result.items;
    } catch (e) {
      _attemptHistoryError = e.toString();
    } finally {
      _loadingAttemptHistory = false;
      notifyListeners();
    }
  }

  // ==================================================
  // 10. Abandon attempt
  // ==================================================

  Future<bool> abandonCurrentAttempt() async {
    final currentAttemptCode = _attemptCode;

    if (currentAttemptCode == null ||
        currentAttemptCode.isEmpty) {
      return true;
    }

    try {
      await _studentQuizApi.abandonAttempt(
        attemptCode: currentAttemptCode,
      );

      _attemptStatus = 'ABANDONED';
      _stopCountdown();

      notifyListeners();

      return true;
    } catch (e) {
      _attemptStateError = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ==================================================
  // Timer
  // ==================================================

  void _startCountdown() {
    _stopCountdown();

    if (_attemptStatus != 'RUNNING') {
      return;
    }

    if (_remainingSeconds <= 0) {
      _handleLocalTimeout();
      return;
    }

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        }

        if (_remainingSeconds <= 0) {
          timer.cancel();
          _handleLocalTimeout();
        }
      },
    );
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _handleLocalTimeout() {
    _remainingSeconds = 0;
    _stopCountdown();

    // Đây chỉ là trạng thái tạm trên giao diện.
    // Backend vẫn là nguồn trạng thái chính.
    syncAttemptState();
  }

  // ==================================================
  // Helper parse response
  // ==================================================

  void _applyAttemptData(
      Map<String, dynamic> data,
      ) {
    final returnedAttemptCode =
    data['attemptCode']?.toString();

    if (returnedAttemptCode != null &&
        returnedAttemptCode.isNotEmpty) {
      _attemptCode = returnedAttemptCode;
    }

    final returnedStatus =
    data['status']?.toString();

    if (returnedStatus != null &&
        returnedStatus.isNotEmpty) {
      _attemptStatus = returnedStatus;
    }

    final rawRemainingSeconds =
    data['remainingSeconds'];

    if (rawRemainingSeconds is int) {
      _remainingSeconds = rawRemainingSeconds;
    } else if (rawRemainingSeconds is num) {
      _remainingSeconds =
          rawRemainingSeconds.toInt();
    } else if (rawRemainingSeconds != null) {
      _remainingSeconds =
          int.tryParse(
            rawRemainingSeconds.toString(),
          ) ??
              _remainingSeconds;
    }

    final rawExpiredAt =
    data['expiredAt']?.toString();

    if (rawExpiredAt != null &&
        rawExpiredAt.isNotEmpty) {
      _expiredAt =
          DateTime.tryParse(rawExpiredAt);
    }
  }

  void _restoreSavedAnswersFromContent() {
    final detail = _quizDetail;

    if (detail == null) {
      return;
    }

    _answers.clear();

    for (final question in detail.questions) {
      final selectedAnswer =
          question.selectedAnswer;

      if (selectedAnswer != null &&
          selectedAnswer.isNotEmpty) {
        _answers[question.questionId] =
            selectedAnswer;
      }
    }
  }

  // ==================================================
  // Reset
  // ==================================================

  void resetQuizSession() {
    _stopCountdown();

    _reactionId = null;
    _reactionDetail = null;
    _quizSummary = null;

    _attemptCode = null;
    _attemptStatus = null;

    _remainingSeconds = 0;
    _expiredAt = null;

    _quizDetail = null;
    _submitResult = null;
    _attemptDetail = null;

    _answers.clear();
    _savingQuestionIds.clear();

    _summaryError = null;
    _reactionDetailError = null;
    _startAttemptError = null;
    _completeArError = null;
    _attemptStateError = null;
    _quizContentError = null;
    _saveAnswerError = null;
    _submitError = null;

    notifyListeners();
  }

  void _clearAttemptData({
    required bool clearReaction,
  }) {
    _stopCountdown();

    if (clearReaction) {
      _reactionId = null;
    }

    _attemptCode = null;
    _attemptStatus = null;

    _remainingSeconds = 0;
    _expiredAt = null;

    _quizDetail = null;
    _submitResult = null;
    _attemptDetail = null;

    _answers.clear();
    _savingQuestionIds.clear();

    _startAttemptError = null;
    _completeArError = null;
    _attemptStateError = null;
    _quizContentError = null;
    _saveAnswerError = null;
    _submitError = null;
    _attemptDetailError = null;
  }

  @override
  void dispose() {
    _stopCountdown();
    super.dispose();
  }
}