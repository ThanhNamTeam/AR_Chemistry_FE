import 'package:flutter/foundation.dart';

import '../../../core/models/response/reaction_check_response.dart';
import '../../../core/storage/experiment_progress_storage.dart';
import '../../../domain/models/reaction_experiment/reaction_category.dart';
import '../../../domain/models/student_reaction_model.dart';
import '../../quiz/providers/student_quiz_provider.dart';

enum ExperimentSessionPhase {
  idle,
  ready,
  scanning,
  cardsReady,
  reactionRunning,
  scriptUnlocked,
  submitted,
  timeout,
  abandoned,
}

class ReactionExperimentSessionProvider
    extends ChangeNotifier {
  ReactionExperimentSessionProvider(
      this._storage,
      this._studentQuizProvider,
      );
  ReactionCheckResponse? _lastReactionCheck;

  ReactionCheckResponse? get lastReactionCheck =>
      _lastReactionCheck;
  final ExperimentProgressStorage _storage;
  final StudentQuizProvider _studentQuizProvider;

  int? selectedGrade;
  ReactionCategory? selectedCategory;

  StudentReactionModel? activeReaction;

  ExperimentSessionPhase phase =
      ExperimentSessionPhase.idle;

  bool hasReturnedFromArOnce = false;

  String? sessionError;

  StudentQuizProvider get quizProvider =>
      _studentQuizProvider;

  bool get arCompleted {
    return _studentQuizProvider.running ||
        _studentQuizProvider.submitted ||
        _studentQuizProvider.timedOut;
  }

  bool get scriptAndQuizUnlocked {
    return _studentQuizProvider.running ||
        _studentQuizProvider.submitted ||
        _studentQuizProvider.timedOut;
  }

  bool get showResult {
    return _studentQuizProvider.submitted ||
        _studentQuizProvider.timedOut;
  }

  int get remainingSeconds =>
      _studentQuizProvider.remainingSeconds;

  String get attemptCode =>
      _studentQuizProvider.attemptCode ?? '';

  bool get isTimerRunning =>
      _studentQuizProvider.running &&
          _studentQuizProvider.remainingSeconds > 0;

  bool get canOpenScan {
    return activeReaction != null &&
        (phase == ExperimentSessionPhase.ready ||
            phase == ExperimentSessionPhase.scanning ||
            phase == ExperimentSessionPhase.cardsReady);
  }

  bool get canStartReaction {
    return activeReaction != null &&
        phase == ExperimentSessionPhase.cardsReady &&
        !_studentQuizProvider.running;
  }

  bool get canShowQuizSection {
    return scriptAndQuizUnlocked && !showResult;
  }

  Future<void> loadProgress() async {
    selectedGrade =
    await _storage.getSelectedGrade();

    notifyListeners();
  }

  Future<void> selectGrade(int grade) async {
    selectedGrade = grade;

    await _storage.saveSelectedGrade(grade);

    notifyListeners();
  }

  void selectCategory(
      ReactionCategory category,
      ) {
    selectedCategory = category;
    notifyListeners();
  }

  Future<bool> beginReaction(
      StudentReactionModel reaction,
      ) async {
    activeReaction = reaction;
    _lastReactionCheck = null;

    phase = ExperimentSessionPhase.ready;
    hasReturnedFromArOnce = false;
    sessionError = null;

    notifyListeners();

    await _studentQuizProvider.selectReaction(
      reaction.reactionId,
    );

    if (_studentQuizProvider.reactionDetail == null) {
      sessionError =
          _studentQuizProvider.reactionDetailError ??
              'Không thể tải thông tin phản ứng';

      notifyListeners();
      return false;
    }

    final started =
    await _studentQuizProvider.startQuiz(
      reactionId: reaction.reactionId,
    );

    if (!started) {
      sessionError =
          _studentQuizProvider.startAttemptError ??
              'Không thể bắt đầu attempt';

      notifyListeners();
      return false;
    }

    if (_studentQuizProvider.running) {
      phase = ExperimentSessionPhase.scriptUnlocked;

      await _studentQuizProvider.loadQuizContent();
    } else {
      phase = ExperimentSessionPhase.ready;
    }

    notifyListeners();
    return true;
  }

  void markEnteringScan() {
    if (phase == ExperimentSessionPhase.ready ||
        phase ==
            ExperimentSessionPhase.cardsReady) {
      phase = ExperimentSessionPhase.scanning;
      notifyListeners();
    }
  }

  Future<void> handleExperimentReactionCheck(
      ReactionCheckResponse result,
      ) async {
    debugPrint(
      '[EXPERIMENT-SESSION] handleReactionCheck được gọi: '
          'matched=${result.matched}, '
          'actual=${result.reactionCode}, '
          'expected=${activeReaction?.reactionCode}, '
          'qr=${result.affectedQrPayloads}',
    );
    final expectedCode = activeReaction?.reactionCode;

    if (expectedCode == null || expectedCode.isEmpty) {
      return;
    }

    if (!result.matched) {
      _lastReactionCheck = null;
      sessionError = result.message;
      phase = ExperimentSessionPhase.scanning;

      notifyListeners();
      return;
    }

    final actualReactionCode = result.reactionCode;

    if (actualReactionCode == null ||
        actualReactionCode.trim().isEmpty ||
        actualReactionCode != expectedCode) {
      _lastReactionCheck = null;
      sessionError =
      'Phản ứng quét được không khớp với phản ứng đang học';
      phase = ExperimentSessionPhase.scanning;

      notifyListeners();
      return;
    }

    _lastReactionCheck = result;
    sessionError = null;
    phase = ExperimentSessionPhase.cardsReady;

    notifyListeners();
  }

  Future<bool> completeScannedReaction() async {
    final result = _lastReactionCheck;

    debugPrint(
      '[EXPERIMENT] completeScannedReaction '
          'result=${result != null}, '
          'matched=${result?.matched}, '
          'reactionCode=${result?.reactionCode}, '
          'qrPayloads=${result?.affectedQrPayloads}',
    );

    if (result == null || !result.matched) {
      sessionError = 'Chưa có kết quả quét phản ứng hợp lệ';
      notifyListeners();
      return false;
    }

    final scannedCodes = result.affectedQrPayloads;

    if (scannedCodes.isEmpty) {
      sessionError = 'Không tìm thấy dữ liệu QR của các chất đã quét';
      debugPrint('[EXPERIMENT] affectedQrPayloads đang rỗng');
      notifyListeners();
      return false;
    }

    debugPrint('[EXPERIMENT] Gọi completeAr với $scannedCodes');

    return startReactionAfterScan(
      scannedCardCodes: scannedCodes,
    );
  }

  Future<bool> startReactionAfterScan({
    required List<String> scannedCardCodes,
    String? arSessionCode,
  }) async {
    if (!canStartReaction) {
      return false;
    }

    sessionError = null;
    phase = ExperimentSessionPhase.reactionRunning;

    notifyListeners();

    final completed = await _studentQuizProvider.completeAr(
      scannedCardCodes: scannedCardCodes,
      reactionSuccessful: true,
      arSessionCode: arSessionCode,
    );

    debugPrint(
      '[EXPERIMENT] completeAr result=$completed '
          'error=${_studentQuizProvider.completeArError} '
          'running=${_studentQuizProvider.running} '
          'waitingAr=${_studentQuizProvider.waitingAr}',
    );

    if (!completed) {
      sessionError =
          _studentQuizProvider.completeArError ??
              'Không thể xác nhận AR';

      phase = ExperimentSessionPhase.cardsReady;

      notifyListeners();
      return false;
    }

    phase = ExperimentSessionPhase.scriptUnlocked;

    await _studentQuizProvider.loadQuizContent();
    debugPrint(
      '[EXPERIMENT] loadQuizContent xong '
          'quizDetail=${_studentQuizProvider.quizDetail != null} '
          'error=${_studentQuizProvider.quizContentError}',
    );
    if (_studentQuizProvider.quizDetail == null) {
      sessionError =
          _studentQuizProvider.quizContentError ??
              'Không thể tải nội dung quiz';

      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<void> onReturnFromExperimentScan() async {
    hasReturnedFromArOnce = true;

    if (phase == ExperimentSessionPhase.cardsReady &&
        _lastReactionCheck != null) {
      final completed =
      await completeScannedReaction();

      if (!completed) {
        notifyListeners();
        return;
      }
    } else {
      await syncWithBackend();
    }

    if (_studentQuizProvider.running) {
      phase = ExperimentSessionPhase.scriptUnlocked;

      if (_studentQuizProvider.quizDetail == null) {
        await _studentQuizProvider.loadQuizContent();
      }
    } else if (_studentQuizProvider.waitingAr) {
      phase = ExperimentSessionPhase.ready;
    }

    notifyListeners();
  }

  Future<void> syncWithBackend() async {
    await _studentQuizProvider.syncAttemptState();

    if (_studentQuizProvider.running) {
      phase = ExperimentSessionPhase.scriptUnlocked;
    } else if (_studentQuizProvider.submitted) {
      phase = ExperimentSessionPhase.submitted;
    } else if (_studentQuizProvider.timedOut) {
      phase = ExperimentSessionPhase.timeout;

      await _studentQuizProvider
          .loadCurrentAttemptResult();
    } else if (_studentQuizProvider.abandoned) {
      phase = ExperimentSessionPhase.abandoned;
    } else if (_studentQuizProvider.waitingAr) {
      phase = ExperimentSessionPhase.ready;
    }

    notifyListeners();
  }

  Future<void> selectAnswer({
    required String questionId,
    required String optionKey,
  }) async {
    await _studentQuizProvider.selectAnswer(
      questionId: questionId,
      answer: optionKey,
    );

    notifyListeners();
  }

  String? answerFor(String questionId) {
    return _studentQuizProvider
        .answers[questionId];
  }

  bool get allQuestionsAnswered {
    return _studentQuizProvider.canSubmit;
  }

  Future<bool> submit() async {
    sessionError = null;

    final submitted =
    await _studentQuizProvider
        .submitCurrentAttempt();

    if (!submitted) {
      sessionError =
          _studentQuizProvider.submitError ??
              'Không thể nộp bài';

      notifyListeners();
      return false;
    }

    phase = ExperimentSessionPhase.submitted;

    await _studentQuizProvider
        .loadCurrentAttemptResult();

    notifyListeners();
    return true;
  }

  Future<bool> abandonSession() async {
    if (phase ==
        ExperimentSessionPhase.submitted ||
        phase == ExperimentSessionPhase.timeout ||
        phase == ExperimentSessionPhase.idle) {
      clearActiveSession();
      return true;
    }

    final abandoned =
    await _studentQuizProvider
        .abandonCurrentAttempt();

    if (!abandoned) {
      sessionError =
          _studentQuizProvider.attemptStateError ??
              'Không thể hủy attempt';

      notifyListeners();
      return false;
    }

    phase = ExperimentSessionPhase.abandoned;

    clearActiveSession();
    return true;
  }

  Future<bool> resetForRetry() async {
    final reaction = activeReaction;

    if (reaction == null) {
      return false;
    }

    _studentQuizProvider.resetQuizSession();

    return beginReaction(reaction);
  }

  void clearActiveSession() {
    activeReaction = null;
    phase = ExperimentSessionPhase.idle;
    hasReturnedFromArOnce = false;
    sessionError = null;
    _lastReactionCheck = null;

    _studentQuizProvider.resetQuizSession();

    notifyListeners();
  }

  bool get shouldAbandonOnLeave {
    return activeReaction != null &&
        phase != ExperimentSessionPhase.submitted &&
        phase != ExperimentSessionPhase.timeout &&
        phase != ExperimentSessionPhase.abandoned &&
        phase != ExperimentSessionPhase.idle;
  }

  String formatRemaining() {
    return _studentQuizProvider
        .formattedRemainingTime;
  }
}