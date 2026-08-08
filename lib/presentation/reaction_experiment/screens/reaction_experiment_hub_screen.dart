import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/ar_access_api.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../domain/models/student_quiz_attempt_detail_model.dart';
import '../../../domain/models/student_quiz_question_model.dart';
import '../../ar_view/models/scan_launch_args.dart';
import '../../ar_view/widgets/ar_camera_view.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../../quiz/providers/student_quiz_provider.dart';
import '../providers/reaction_experiment_session_provider.dart';
import '../widgets/experiment_screen_header.dart';

class ReactionExperimentHubScreen extends StatefulWidget {
  const ReactionExperimentHubScreen({super.key});

  @override
  State<ReactionExperimentHubScreen> createState() =>
      _ReactionExperimentHubScreenState();
}

class _ReactionExperimentHubScreenState
    extends State<ReactionExperimentHubScreen> {
  final _arAccessApi = ArAccessApi();
  bool _openingAr = false;

  Future<void> _openExperimentScan() async {
    final session =
    context.read<ReactionExperimentSessionProvider>();

    if (!session.canOpenScan || _openingAr) {
      return;
    }

    final reaction = session.activeReaction;

    if (reaction == null) {
      return;
    }

    setState(() {
      _openingAr = true;
    });

    try {
      final access = await _arAccessApi.getMyArAccess();

      if (!mounted) {
        return;
      }

      if (!access.canScanAR) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(access.message),
          ),
        );

        return;
      }



      session.markEnteringScan();

      ARUnitySession.instance.experimentScanHandler =
          (result) async {

        await session.handleExperimentReactionCheck(result);



        // Quét sai hoặc không đúng phản ứng:
        // giữ nguyên handler để người dùng có thể quét lại.
        if (session.lastReactionCheck == null) {
          if (mounted && session.sessionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(session.sessionError!),
              ),
            );
          }

          return;
        }

        // Quét đúng: tiếp tục complete-ar và tải quiz.
        await session.onReturnFromExperimentScan();


        // Chỉ xóa handler sau khi đã xử lý kết quả thành công.
        ARUnitySession.instance.experimentScanHandler = null;

        if (!mounted) {
          return;
        }

        if (session.sessionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(session.sessionError!),
            ),
          );
        }
      };

      await Navigator.pushNamed(
        context,
        AppRoutes.arAssetLoading,
        arguments: ScanLaunchArgs(
          mode: ScanMode.experiment,
          expectedReactionCode: reaction.reactionCode,
        ),
      );

      // Không xóa handler và không gọi onReturn ở đây,
      // vì route loading có thể kết thúc trước khi Unity quét xong.
    } catch (e) {
      ARUnitySession.instance.experimentScanHandler = null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _openingAr = false;
        });
      }
    }
  }

  Future<void> _confirmSubmit() async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: Text(
            l10n.confirmSubmitTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          content: Text(
            l10n.confirmSubmitMessage,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final session =
    context.read<ReactionExperimentSessionProvider>();

    final submitted = await session.submit();

    if (!mounted) {
      return;
    }

    if (!submitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            session.sessionError ??
                'Không thể nộp bài',
          ),
        ),
      );
    }
  }

  Future<void> _leaveHub({
    required bool abandon,
  }) async {
    final session =
    context.read<ReactionExperimentSessionProvider>();

    if (abandon &&
        session.shouldAbandonOnLeave) {
      final success =
      await session.abandonSession();

      if (!success || !mounted) {
        return;
      }
    } else if (session.showResult) {
      session.clearActiveSession();
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildResultBody({
    required AppLocalizations l10n,
    required ReactionExperimentSessionProvider session,
    required StudentQuizProvider quizProvider,
    required StudentQuizAttemptDetailModel? attemptResult,
  }) {
    if (quizProvider.loadingAttemptDetail &&
        attemptResult == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (quizProvider.attemptDetailError != null &&
        attemptResult == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          30,
          20,
          24,
        ),
        children: [
          _LoadQuizErrorCard(
            message: quizProvider.attemptDetailError!,
            onRetry: () async {
              await quizProvider.loadCurrentAttemptResult();
            },
          ),
        ],
      );
    }

    if (attemptResult == null) {
      return Center(
        child: Text(
          'Không tìm thấy kết quả bài làm',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    return _ResultPanel(
      l10n: l10n,
      result: attemptResult,
      onBackToList: () {
        session.clearActiveSession();
        Navigator.pop(context);
      },
      onBackToCategories: () {
        session.clearActiveSession();

        Navigator.popUntil(
          context,
          ModalRoute.withName(
            AppRoutes.reactionCategory,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();

    final session =
    context.watch<ReactionExperimentSessionProvider>();

    final quizProvider = context.watch<StudentQuizProvider>();

    final reaction = session.activeReaction;
    final quizContent = quizProvider.quizDetail;
    final attemptResult = quizProvider.attemptDetail;

    if (reaction == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Text(
            l10n.noExperimentData,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        await _leaveHub(abandon: true);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Container(
          decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                ExperimentScreenHeader(
                  title: reaction.reactionName,
                  onBack: () => _leaveHub(abandon: true),
                  trailing: session.isTimerRunning
                      ? ExperimentTimerBadge(
                          timeText: session.formatRemaining(),
                          active: true,
                        )
                      : null,
                ),
                Expanded(
                  child: session.showResult
                      ? _buildResultBody(
                    l10n: l10n,
                    session: session,
                    quizProvider: quizProvider,
                    attemptResult: attemptResult,
                  )
                      : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      24,
                    ),
                    children: [
                      _ArSection(
                        l10n: l10n,
                        equation: reaction.equation,
                        arCompleted: session.arCompleted,
                        canOpenScan: session.canOpenScan,
                        isOpening: _openingAr,
                        onOpenScan: _openExperimentScan,
                        timerText: session.isTimerRunning
                            ? session.formatRemaining()
                            : null,
                      ),

                      if (session.sessionError != null) ...[
                        const SizedBox(height: 14),
                        _InlineErrorCard(
                          message: session.sessionError!,
                        ),
                      ],

                      if (quizProvider.completingAr) ...[
                        const SizedBox(height: 20),
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],

                      if (session.canShowQuizSection) ...[
                        const SizedBox(height: 20),

                        if (quizProvider.loadingQuizContent &&
                            quizContent == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 30,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (quizProvider.quizContentError !=
                            null &&
                            quizContent == null)
                          _LoadQuizErrorCard(
                            message:
                            quizProvider.quizContentError!,
                            onRetry: () async {
                              await quizProvider
                                  .loadQuizContent();
                            },
                          )
                        else if (quizContent != null) ...[
                            _ScriptSection(
                              l10n: l10n,
                              script: quizContent.script ??
                                  'Chưa có nội dung hướng dẫn cho phản ứng này.',
                              equation: quizContent.equation,
                            ),

                            const SizedBox(height: 20),

                            _QuizSection(
                              l10n: l10n,
                              questions: quizContent.questions,
                              session: session,
                              quizProvider: quizProvider,
                            ),

                            if (quizProvider.saveAnswerError !=
                                null) ...[
                              const SizedBox(height: 12),
                              _InlineErrorCard(
                                message:
                                quizProvider
                                    .saveAnswerError!,
                              ),
                            ],

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: quizProvider.submitting
                                    ? null
                                    : session.allQuestionsAnswered
                                    ? _confirmSubmit
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: quizProvider.submitting
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  l10n.submitQuiz,
                                ),
                              ),
                            )
                          ],
                      ] else if (!session.arCompleted) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.scanTwoCardsHint,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                            AppColors.textSecondary,
                            fontFamily: 'Inter',
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArSection extends StatelessWidget {
  final AppLocalizations l10n;
  final String equation;
  final bool arCompleted;
  final bool canOpenScan;
  final bool isOpening;
  final VoidCallback onOpenScan;
  final String? timerText;

  const _ArSection({
    required this.l10n,
    required this.equation,
    required this.arCompleted,
    required this.canOpenScan,
    required this.isOpening,
    required this.onOpenScan,
    this.timerText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.virtualExperimentAr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (arCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        l10n.arStepCompleted,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          if (equation.trim().isNotEmpty) ...[
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.subtitleAccent.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phương trình phản ứng',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    equation,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.subtitleAccent,
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (timerText != null) ...[
            const SizedBox(height: 10),
            ExperimentTimerBadge(timeText: timerText!, active: true),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: canOpenScan && !isOpening ? onOpenScan : null,
              icon: isOpening
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.qr_code_scanner),
              label: Text(l10n.openArScan),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.45)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScriptSection extends StatelessWidget {
  final AppLocalizations l10n;
  final String script;
  final String equation;

  const _ScriptSection({
    required this.l10n,
    required this.script,
    required this.equation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reactionScript,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            equation,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.subtitleAccent,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            script,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizSection extends StatelessWidget {
  final AppLocalizations l10n;
  final List<StudentQuizQuestionModel> questions;
  final ReactionExperimentSessionProvider session;
  final StudentQuizProvider quizProvider;

  const _QuizSection({
    required this.l10n,
    required this.questions,
    required this.session,
    required this.quizProvider,
  });

  @override
  Widget build(BuildContext context) {
    final sortedQuestions = [...questions]
      ..sort(
            (a, b) => a.questionOrder.compareTo(
          b.questionOrder,
        ),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.experimentQuizSection,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0;
        index < sortedQuestions.length;
        index++)
          Padding(
            padding: const EdgeInsets.only(
              bottom: 14,
            ),
            child: _QuestionCard(
              index: index + 1,
              question: sortedQuestions[index],
              selectedOptionKey: session.answerFor(
                sortedQuestions[index].questionId,
              ),
              saving: quizProvider.isSavingAnswer(
                sortedQuestions[index].questionId,
              ),
              onSelect: (optionKey) async {
                await session.selectAnswer(
                  questionId: sortedQuestions[index].questionId,
                  optionKey: optionKey,
                );
              },
              l10n: l10n,
            ),
          ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final StudentQuizQuestionModel question;
  final String? selectedOptionKey;
  final bool saving;
  final Future<void> Function(String optionKey)
  onSelect;
  final AppLocalizations l10n;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedOptionKey,
    required this.saving,
    required this.onSelect,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final options = [...question.options]
      ..sort(
            (a, b) =>
            a.optionOrder.compareTo(
              b.optionOrder,
            ),
      );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
          AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.questionNumber(index),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                    color: AppColors.primary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (saving)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            question.questionText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 10),

          for (final option in options)
            Padding(
              padding:
              const EdgeInsets.only(
                bottom: 7,
              ),
              child: InkWell(
                onTap: saving
                    ? null
                    : () {
                  onSelect(
                    option.optionKey,
                  );
                },
                borderRadius:
                BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                    selectedOptionKey ==
                        option.optionKey
                        ? AppColors.primary
                        .withValues(alpha: 0.15)
                        : AppColors
                        .backgroundDark
                        .withValues(alpha: 0.35),
                    borderRadius:
                    BorderRadius.circular(10),
                    border: Border.all(
                      color:
                      selectedOptionKey ==
                          option.optionKey
                          ? AppColors.primary
                          .withValues(alpha: 0.5)
                          : AppColors
                          .cardBorder
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        alignment:
                        Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                          selectedOptionKey ==
                              option
                                  .optionKey
                              ? AppColors
                              .primary
                              : AppColors
                              .backgroundDark
                              .withValues(alpha: 
                            0.45,
                          ),
                        ),
                        child: Text(
                          option.optionKey,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w700,
                            color:
                            selectedOptionKey ==
                                option
                                    .optionKey
                                ? Colors.white
                                : AppColors
                                .textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option.optionText,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                            AppColors
                                .textPrimary,
                            fontFamily: 'Inter',
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final AppLocalizations l10n;
  final StudentQuizAttemptDetailModel result;
  final VoidCallback onBackToList;
  final VoidCallback onBackToCategories;

  const _ResultPanel({
    required this.l10n,
    required this.result,
    required this.onBackToList,
    required this.onBackToCategories,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        24,
      ),
      children: [
        Text(
          l10n.experimentScoreTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '${result.score}/${result.totalQuestions}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            fontFamily: 'Inter',
          ),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResultBadge(
              icon: Icons.check_circle_outline,
              text: '${result.correctCount} đúng',
              success: true,
            ),
            _ResultBadge(
              icon: Icons.cancel_outlined,
              text:
              '${result.totalQuestions - result.correctCount} sai',
              success: false,
            ),
            _StatusBadge(
              status: result.status,
            ),
          ],
        ),

        const SizedBox(height: 20),

        ...result.answers.map(
              (answer) {
            final answerColor = answer.correct
                ? AppColors.success
                : AppColors.error;

            return Container(
              margin:
              const EdgeInsets.only(
                bottom: 12,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius:
                BorderRadius.circular(14),
                border: Border.all(
                  color:
                  answerColor.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          answer.questionText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w600,
                            color: AppColors
                                .textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Icon(
                        answer.correct
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: answerColor,
                        size: 20,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Đáp án của bạn: '
                        '${answer.studentAnswer ?? "Chưa trả lời"}',
                    style: TextStyle(
                      fontSize: 13,
                      color: answerColor,
                      fontFamily: 'Inter',
                    ),
                  ),

                  if (!answer.correct) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Đáp án đúng: '
                          '${answer.correctAnswer}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.success,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],

                  if (answer.explanation != null &&
                      answer.explanation!
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      '${l10n.explanationLabel}: '
                          '${answer.explanation}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                        AppColors.textSecondary,
                        fontFamily: 'Inter',
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onBackToList,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              AppColors.primary,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
            child: Text(
              l10n.backToReactionList,
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onBackToCategories,
            style: OutlinedButton.styleFrom(
              foregroundColor:
              AppColors.primary,
              side: BorderSide(
                color: AppColors.primary
                    .withValues(alpha: 0.4),
              ),
              padding:
              const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
            child: Text(
              l10n.backToCategories,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool success;

  const _ResultBadge({
    required this.icon,
    required this.text,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    final color = success
        ? AppColors.success
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
          AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  final String message;

  const _InlineErrorCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadQuizErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _LoadQuizErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
