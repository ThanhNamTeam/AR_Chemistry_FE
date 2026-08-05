import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/friendly_error.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../providers/student_quiz_provider.dart';
import '../../../domain/models/student_quiz_question_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? _reactionId;
  String? _reactionName;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _reactionId = args['reactionId']?.toString();
      _reactionName = args['reactionName']?.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reactionId = _reactionId;

      if (reactionId == null || reactionId.isEmpty) {
        return;
      }

      context
          .read<StudentQuizProvider>()
          .loadPublishedQuizByReaction(reactionId);
    });
  }

  /// Đang làm dở bài (đã tải câu hỏi, đã chọn ít nhất một đáp án, chưa nộp)
  /// thì thoát màn sẽ mất toàn bộ bài làm — phải hỏi trước.
  bool _hasUnsavedAttempt(StudentQuizProvider provider) {
    return provider.hasLoadedQuestions &&
        provider.submitResult == null &&
        provider.answeredCount > 0;
  }

  Future<bool> _confirmLeave() async {
    final l10n = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text(
          l10n.quizLeaveTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10n.quizLeaveMessage,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.quizKeepDoing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.quizLeaveConfirm,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return leave == true;
  }

  Future<void> _handleBack(StudentQuizProvider provider) async {
    if (_hasUnsavedAttempt(provider) && !await _confirmLeave()) return;
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<ThemeProvider>();
    final quizProvider = context.watch<StudentQuizProvider>();

    return PopScope(
      canPop: !_hasUnsavedAttempt(quizProvider),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmLeave() && mounted) Navigator.pop(context);
      },
      child: Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _QuizHeader(
                title: _reactionName ?? l10n.navQuiz,
                onBack: () => _handleBack(quizProvider),
              ),
              Expanded(
                child: _buildBody(context, quizProvider),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, StudentQuizProvider provider) {
    final l10n = AppLocalizations.of(context);
    if (_reactionId == null || _reactionId!.isEmpty) {
      return _EmptyState(
        icon: Icons.error_outline,
        title: l10n.lessonNotFound,
        message: l10n.quizRequiresLessonCode,
        actionLabel: l10n.goHome,
        onAction: () => _goHome(context),
      );
    }

    if (provider.loadingSummary) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.summaryError != null) {
      return _EmptyState(
        icon: Icons.error_outline,
        title: l10n.cannotLoadQuiz,
        // Raw exception KHÔNG được lên UI — friendlyError phân loại +
        // đẩy chi tiết thật vào debugPrint/log.
        message: friendlyError(l10n, provider.summaryError, context: 'quizSummary'),
        actionLabel: l10n.tryAgain,
        onAction: () {
          context
              .read<StudentQuizProvider>()
              .loadPublishedQuizByReaction(_reactionId!);
        },
      );
    }

    if (!provider.hasQuiz) {
      return _EmptyState(
        icon: Icons.quiz_outlined,
        title: l10n.noQuiz,
        message: l10n.lessonNoPublishedQuiz,
        actionLabel: l10n.goHome,
        onAction: () => _goHome(context),
      );
    }

    if (!provider.hasLoadedQuestions) {
      return _QuizIntro(provider: provider);
    }

    if (provider.submitResult != null) {
      return _QuizResultView(provider: provider);
    }

    return _QuizQuestionList(provider: provider);
  }

  void _goHome(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
            (_) => false,
      );
    }
  }
}

class _QuizHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _QuizHeader({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizIntro extends StatelessWidget {
  final StudentQuizProvider provider;

  const _QuizIntro({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quiz = provider.quizSummary!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  size: 44,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                quiz.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${quiz.questionCount} câu hỏi',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.startingAttempt
                      ? null
                      : () async {
                    final reactionId = provider.reactionId;

                    if (reactionId == null || reactionId.isEmpty) {
                      return;
                    }

                    final quizProvider =
                    context.read<StudentQuizProvider>();

                    final started = await quizProvider.startQuiz(
                      reactionId: reactionId,
                    );

                    if (!context.mounted || !started) {
                      return;
                    }

                    if (quizProvider.waitingAr) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.arAssetLoading,
                      );
                      return;
                    }

                    if (quizProvider.running) {
                      await quizProvider.loadQuizContent();
                    }
                  },
                  icon: provider.startingAttempt
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    provider.startingAttempt
                        ? l10n.loading
                        : l10n.startQuiz,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              if (provider.questionsError != null) ...[
                const SizedBox(height: 12),
                Text(
                  provider.questionsError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizQuestionList extends StatelessWidget {
  final StudentQuizProvider provider;

  const _QuizQuestionList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quiz = provider.quizDetail!;
    final questions = quiz.questions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          quiz.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Đã trả lời ${provider.answeredCount}/${provider.totalQuestions}',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 14),
        ...questions.map(
              (question) => _QuestionCard(
            question: question,
                selectedAnswer:
                provider.answers[question.questionId],
                onSelectAnswer: (answer) {
                  context.read<StudentQuizProvider>().selectAnswer(
                    questionId: question.questionId,
                    answer: answer,
                  );
                },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.canSubmit && !provider.submitting
                ? () async {
              // Nộp bài là không hoàn tác được — xác nhận kèm số câu đã làm.
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.cardBg,
                  title: Text(
                    l10n.quizSubmitConfirmTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: Text(
                    l10n.quizSubmitConfirmMessage(
                      provider.answeredCount,
                      provider.totalQuestions,
                    ),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l10n.submitQuiz),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                context.read<StudentQuizProvider>().submitCurrentQuiz();
              }
            }
                : null,
            icon: provider.submitting
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.check_circle_outline),
            label: Text(provider.submitting ? l10n.submitting : l10n.submitQuiz),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (provider.submitError != null) ...[
          const SizedBox(height: 10),
          Text(
            provider.submitError!,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final StudentQuizQuestionModel question;
  final String? selectedAnswer;
  final ValueChanged<String> onSelectAnswer;

  const _QuestionCard({
    required this.question,
    required this.selectedAnswer,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final options = [...question.options]
      ..sort(
            (a, b) =>
            a.optionOrder.compareTo(b.optionOrder),
      );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Badge(
                text: 'Câu ${question.questionOrder}',
              ),
              const SizedBox(width: 8),
              const _Badge(
                text: 'Trắc nghiệm',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.questionText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          if (options.isNotEmpty)
            ...options.map(
                  (option) => _AnswerOption(
                label: option.optionKey,
                text: option.optionText,
                selected:
                selectedAnswer == option.optionKey,
                onTap: () {
                  onSelectAnswer(option.optionKey);
                },
              ),
            )
          else
            Text(
              'Không có đáp án',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(0.7)
                : AppColors.textSecondary.withOpacity(0.22),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label. ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontFamily: 'Inter',
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  final StudentQuizProvider provider;

  const _QuizResultView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = provider.submitResult!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                color: Colors.white,
                size: 46,
              ),
              const SizedBox(height: 12),
              Text(
                '${result.correctCount}/${result.total}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.quizResult,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...result.results.map(
              (r) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: r.correct
                    ? AppColors.success.withOpacity(0.5)
                    : AppColors.error.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                  r.correct ? l10n.correct : l10n.incorrect,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: r.correct ? AppColors.success : AppColors.error,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bạn chọn: ${r.studentAnswer ?? '-'}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'Đáp án đúng: ${r.correctAnswer ?? '-'}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                if (r.explanation != null && r.explanation!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    r.explanation!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: AppColors.primary),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}