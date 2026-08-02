import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/api/student_reaction_quiz_api.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/active_quiz_attempt.dart';
import '../../../domain/models/student_reaction_quiz_models.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';

/// Máy trạng thái một lần làm quiz theo contract mới:
///
///   WAITING_AR ──(quét 2 thẻ + phản ứng AR ok / complete-ar)──► RUNNING
///   RUNNING ──(submit | hết 7 phút)──► SUBMITTED / TIMEOUT ──► màn kết quả
///
/// - Ở WAITING_AR: hướng dẫn + nút mở máy quét; arm [ActiveQuizAttempt] để
///   luồng AR biết attempt nào cần `complete-ar`; poll state 5s/lần.
/// - Ở RUNNING: script + câu hỏi, timer đếm lùi từ server, autosave từng
///   đáp án ngay khi chọn, nút nộp có xác nhận.
class QuizAttemptFlowScreen extends StatefulWidget {
  const QuizAttemptFlowScreen({
    super.key,
    required this.attemptCode,
    required this.reactionName,
    required this.equation,
  });

  final String attemptCode;
  final String reactionName;
  final String equation;

  @override
  State<QuizAttemptFlowScreen> createState() => _QuizAttemptFlowScreenState();
}

class _QuizAttemptFlowScreenState extends State<QuizAttemptFlowScreen> {
  final _api = StudentReactionQuizApi();

  QuizAttemptStateModel? _state;
  QuizContentModel? _content;
  String? _error;
  bool _loading = true;
  bool _submitting = false;

  /// Đáp án đang chọn (questionId -> optionKey) — seed từ server khi resume.
  final Map<String, String> _answers = {};

  Timer? _pollTimer;
  Timer? _countdown;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdown?.cancel();
    ActiveQuizAttempt.disarm(widget.attemptCode);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Trạng thái
  // ---------------------------------------------------------------------------

  Future<void> _refreshState() async {
    try {
      final state = await _api.getState(widget.attemptCode);
      if (!mounted) return;
      setState(() {
        _state = state;
        _error = null;
        _loading = false;
      });

      if (state.isEnded) {
        _goToResult();
      } else if (state.quizUnlocked) {
        _pollTimer?.cancel();
        ActiveQuizAttempt.disarm(widget.attemptCode);
        if (_content == null) await _loadContent();
      } else {
        // WAITING_AR: giữ holder armed + poll đều — người dùng có thể hoàn
        // thành AR ở màn khác rồi quay lại.
        ActiveQuizAttempt.arm(widget.attemptCode);
        _pollTimer ??= Timer.periodic(
          const Duration(seconds: 5),
          (_) => _refreshState(),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _loadContent() async {
    try {
      final content = await _api.getContent(widget.attemptCode);
      if (!mounted) return;
      setState(() {
        _content = content;
        for (final q in content.questions) {
          if (q.selectedAnswer != null && q.selectedAnswer!.isNotEmpty) {
            _answers[q.questionId] = q.selectedAnswer!;
          }
        }
      });
      _startCountdown(content.remainingSeconds);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  void _startCountdown(int seconds) {
    _countdown?.cancel();
    _remaining = seconds;
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining -= 1);
      if (_remaining <= 0) {
        t.cancel();
        // Hết giờ: server tự chấm TIMEOUT — đồng bộ rồi sang kết quả.
        _refreshState();
      }
    });
  }

  void _goToResult() {
    _pollTimer?.cancel();
    _countdown?.cancel();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.quizAttemptDetail,
      arguments: {'attemptCode': widget.attemptCode},
    );
  }

  // ---------------------------------------------------------------------------
  // Hành động
  // ---------------------------------------------------------------------------

  Future<void> _openArScanner() async {
    ActiveQuizAttempt.arm(widget.attemptCode);
    await Navigator.pushNamed(context, AppRoutes.arAssetLoading);
    if (mounted) _refreshState();
  }

  Future<void> _select(String questionId, String optionKey) async {
    final previous = _answers[questionId];
    setState(() => _answers[questionId] = optionKey);
    try {
      await _api.saveAnswer(widget.attemptCode, questionId, optionKey);
    } catch (_) {
      if (!mounted) return;
      // Lưu hỏng: trả lại lựa chọn cũ để UI không nói dối là "đã lưu".
      setState(() {
        if (previous == null) {
          _answers.remove(questionId);
        } else {
          _answers[questionId] = previous;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).quizAnswerSaveFailed,
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final total = _content?.questions.length ?? 0;
    final answered = _answers.length;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        content: Text(
          answered < total
              ? l10n.quizSubmitConfirmUnanswered(total - answered)
              : l10n.quizSubmitConfirm,
          style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.quizSubmit),
          ),
        ],
      ),
    );
    if (ok != true || _submitting) return;

    setState(() => _submitting = true);
    try {
      await _api.submit(widget.attemptCode);
      if (mounted) _goToResult();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.quizSubmitFailed,
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Back khi ĐANG làm bài: hỏi rõ — thoát là bỏ bài (BE chuyển ABANDONED).
  Future<bool> _confirmLeave() async {
    if (_state?.quizUnlocked != true || _state?.isEnded == true) return true;
    final l10n = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        content: Text(
          l10n.quizAbandonConfirm,
          style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.quizAbandon),
          ),
        ],
      ),
    );
    if (leave == true) {
      try {
        await _api.abandon(widget.attemptCode);
      } catch (_) {
        // Bỏ bài là hành động thoát — lỗi mạng không nên giữ người dùng lại.
      }
      return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          title: Text(
            widget.reactionName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          actions: [
            if (_state?.quizUnlocked == true && _content != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(child: _TimerBadge(seconds: _remaining)),
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(top: false, child: _buildBody(l10n)),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _state == null) {
      return _ErrorView(onRetry: () {
        setState(() {
          _loading = true;
          _error = null;
        });
        _refreshState();
      });
    }
    if (_state?.quizUnlocked == true) {
      return _content == null
          ? const Center(child: CircularProgressIndicator())
          : _buildQuiz(l10n);
    }
    return _buildWaitingAr(l10n);
  }

  Widget _buildWaitingAr(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        Icon(Icons.view_in_ar, size: 72, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          l10n.quizWaitingArTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.equation,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.accentText,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.quizWaitingArDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.5,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _openArScanner,
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(l10n.quizOpenArScanner),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _refreshState,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(l10n.quizCheckArStatus),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            l10n.quizWaitingArAutoCheck,
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuiz(AppLocalizations l10n) {
    final content = _content!;
    final answered = _answers.length;
    final total = content.questions.length;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              if (content.script.trim().isNotEmpty)
                _ScriptCard(script: content.script),
              ...content.questions.map(
                (q) => _QuestionCard(
                  question: q,
                  selected: _answers[q.questionId],
                  onSelect: _submitting
                      ? null
                      : (key) => _select(q.questionId, key),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.navBarBg,
            border: Border(
              top: BorderSide(
                color: AppColors.cardBorder.withValues(alpha: .5),
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                '$answered/$total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.quizSubmit),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final s = seconds < 0 ? 0 : seconds;
    final text =
        '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
    final danger = s <= 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (danger ? AppColors.error : AppColors.primary)
            .withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: danger ? AppColors.error : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ScriptCard extends StatelessWidget {
  const _ScriptCard({required this.script});

  final String script;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: .5)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            AppLocalizations.of(context).quizScriptTitle,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            Text(
              script,
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  final QuizQuestionModel question;
  final String? selected;
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${question.questionOrder}. ${question.questionText}',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          ...question.options.map((o) {
            final isSelected = selected == o.optionKey;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onSelect == null ? null : () => onSelect!(o.optionKey),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: .14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBorder.withValues(alpha: .6),
                      width: isSelected ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        o.optionKey,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? AppColors.accentText
                              : AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          o.optionText,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.35,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 40, color: AppColors.error),
            const SizedBox(height: 10),
            Text(
              l10n.quizStateLoadFailed,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(l10n.userMgmtRetry),
            ),
          ],
        ),
      ),
    );
  }
}
