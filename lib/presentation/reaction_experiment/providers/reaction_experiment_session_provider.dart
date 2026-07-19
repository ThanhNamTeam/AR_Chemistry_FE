import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/response/reaction_check_response.dart';
import '../../../core/storage/experiment_progress_storage.dart';
import '../../../domain/models/reaction_experiment/experiment_attempt_record.dart';
import '../../../domain/models/reaction_experiment/reaction_category.dart';
import '../../../domain/models/reaction_experiment/student_experiment_reaction.dart';

enum ExperimentSessionPhase {
  idle,
  ready,
  scanning,
  cardsReady,
  reactionRunning,
  scriptUnlocked,
  submitted,
}

class ReactionExperimentSessionProvider extends ChangeNotifier {
  ReactionExperimentSessionProvider(this._storage);

  final ExperimentProgressStorage _storage;

  static const sessionDurationSeconds = 7 * 60;

  int? selectedGrade;
  ReactionCategory? selectedCategory;
  StudentExperimentReaction? activeReaction;

  ExperimentSessionPhase phase = ExperimentSessionPhase.idle;
  bool arCompleted = false;
  bool hasReturnedFromArOnce = false;
  bool scriptAndQuizUnlocked = false;
  bool showResult = false;

  final Map<String, int?> _answers = {};

  int remainingSeconds = 0;
  Timer? _timer;
  DateTime? _timerEndsAt;

  ExperimentAttemptRecord? lastSubmitResult;
  Map<String, ExperimentAttemptRecord> _completed = {};
  bool _submitLocaleIsVi = true;

  Map<String, ExperimentAttemptRecord> get completedAttempts =>
      Map.unmodifiable(_completed);

  bool get isTimerRunning =>
      phase == ExperimentSessionPhase.reactionRunning ||
      (phase == ExperimentSessionPhase.scriptUnlocked && remainingSeconds > 0);

  bool get canOpenScan =>
      activeReaction != null &&
      (phase == ExperimentSessionPhase.ready ||
          phase == ExperimentSessionPhase.scanning ||
          phase == ExperimentSessionPhase.cardsReady ||
          phase == ExperimentSessionPhase.reactionRunning);

  bool get canStartReaction =>
      phase == ExperimentSessionPhase.cardsReady && !arCompleted;

  bool get canShowQuizSection => scriptAndQuizUnlocked && !showResult;

  Future<void> loadProgress() async {
    selectedGrade = await _storage.getSelectedGrade();
    _completed = await _storage.loadAttempts();
    notifyListeners();
  }

  Future<void> selectGrade(int grade) async {
    selectedGrade = grade;
    await _storage.saveSelectedGrade(grade);
    notifyListeners();
  }

  void selectCategory(ReactionCategory category) {
    selectedCategory = category;
    notifyListeners();
  }

  void beginReaction(StudentExperimentReaction reaction) {
    _cancelTimer();
    activeReaction = reaction;
    phase = ExperimentSessionPhase.ready;
    arCompleted = false;
    hasReturnedFromArOnce = false;
    scriptAndQuizUnlocked = false;
    showResult = false;
    _answers.clear();
    lastSubmitResult = null;
    remainingSeconds = 0;
    _timerEndsAt = null;
    notifyListeners();
  }

  void markEnteringScan() {
    if (phase == ExperimentSessionPhase.ready ||
        phase == ExperimentSessionPhase.reactionRunning) {
      phase = ExperimentSessionPhase.scanning;
      notifyListeners();
    }
  }

  Future<void> handleExperimentReactionCheck(
    ReactionCheckResponse result,
  ) async {
    final expected = activeReaction?.code;
    if (expected == null) return;
    if (!result.matched) return;

    if (result.reactionCode != null && result.reactionCode != expected) {
      return;
    }

    if (phase == ExperimentSessionPhase.scanning ||
        phase == ExperimentSessionPhase.ready) {
      phase = ExperimentSessionPhase.cardsReady;
      notifyListeners();
    }
  }

  void startReactionAfterScan() {
    if (!canStartReaction) return;
    arCompleted = true;
    phase = ExperimentSessionPhase.reactionRunning;
    _startTimer();
    notifyListeners();
  }

  void onReturnFromExperimentScan() {
    if (arCompleted && !hasReturnedFromArOnce) {
      hasReturnedFromArOnce = true;
      scriptAndQuizUnlocked = true;
      phase = ExperimentSessionPhase.scriptUnlocked;
      notifyListeners();
    } else if (phase == ExperimentSessionPhase.scanning ||
        phase == ExperimentSessionPhase.cardsReady) {
      phase = arCompleted
          ? ExperimentSessionPhase.reactionRunning
          : ExperimentSessionPhase.ready;
      notifyListeners();
    }
  }

  void syncSubmitLocale(bool isVi) {
    _submitLocaleIsVi = isVi;
  }

  void selectAnswer(String questionId, int index) {
    _answers[questionId] = index;
    notifyListeners();
  }

  int? answerFor(String questionId) => _answers[questionId];

  bool get allQuestionsAnswered {
    final qs = activeReaction?.questions ?? const [];
    if (qs.isEmpty) return false;
    for (final q in qs) {
      if (_answers[q.id] == null) return false;
    }
    return true;
  }

  Future<bool> submit({required bool force, bool? isVi}) async {
    if (activeReaction == null) return false;
    if (!force && !allQuestionsAnswered) return false;

    final localeIsVi = isVi ?? _submitLocaleIsVi;
    final reaction = activeReaction!;
    final results = <ExperimentQuestionResult>[];
    var score = 0;

    for (final q in reaction.questions) {
      final selected = _answers[q.id] ?? -1;
      final correct = selected == q.correctIndex;
      if (correct) score++;
      results.add(
        ExperimentQuestionResult(
          questionId: q.id,
          questionText: q.questionText(localeIsVi),
          options: q.options(localeIsVi),
          selectedIndex: selected,
          correctIndex: q.correctIndex,
          explanation: q.explanation(localeIsVi),
        ),
      );
    }

    final record = ExperimentAttemptRecord(
      reactionCode: reaction.code,
      grade: reaction.grade,
      categoryKey: reaction.category.storageKey,
      score: score,
      total: reaction.questions.length,
      completedAt: DateTime.now(),
      results: results,
    );

    lastSubmitResult = record;
    _completed[reaction.code] = record;
    await _storage.saveAttempt(record);

    _cancelTimer();
    phase = ExperimentSessionPhase.submitted;
    showResult = true;
    remainingSeconds = 0;
    notifyListeners();
    return true;
  }

  void abandonSession() {
    if (phase == ExperimentSessionPhase.submitted) return;
    _cancelTimer();
    activeReaction = null;
    phase = ExperimentSessionPhase.idle;
    arCompleted = false;
    hasReturnedFromArOnce = false;
    scriptAndQuizUnlocked = false;
    showResult = false;
    _answers.clear();
    lastSubmitResult = null;
    remainingSeconds = 0;
    _timerEndsAt = null;
    notifyListeners();
  }

  void resetForRetry() {
    final reaction = activeReaction;
    if (reaction == null) return;
    beginReaction(reaction);
  }

  void clearActiveSession() {
    _cancelTimer();
    activeReaction = null;
    phase = ExperimentSessionPhase.idle;
    arCompleted = false;
    hasReturnedFromArOnce = false;
    scriptAndQuizUnlocked = false;
    showResult = false;
    _answers.clear();
    lastSubmitResult = null;
    remainingSeconds = 0;
    _timerEndsAt = null;
    notifyListeners();
  }

  bool get shouldAbandonOnLeave =>
      activeReaction != null &&
      phase != ExperimentSessionPhase.submitted &&
      phase != ExperimentSessionPhase.idle;

  bool isReactionCompleted(String code) => _completed.containsKey(code);

  ExperimentAttemptRecord? attemptFor(String code) => _completed[code];

  void _startTimer() {
    _cancelTimer();
    remainingSeconds = sessionDurationSeconds;
    _timerEndsAt = DateTime.now().add(
      const Duration(seconds: sessionDurationSeconds),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_timerEndsAt == null) return;
    final left = _timerEndsAt!.difference(DateTime.now()).inSeconds;
    remainingSeconds = left.clamp(0, sessionDurationSeconds);
    if (remainingSeconds <= 0) {
      unawaited(submit(force: true));
      return;
    }
    notifyListeners();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String formatRemaining() {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
