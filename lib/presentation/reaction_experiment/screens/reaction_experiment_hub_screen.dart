import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/ar_access_api.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../domain/models/reaction_experiment/experiment_attempt_record.dart';
import '../../../domain/models/reaction_experiment/experiment_quiz_question.dart';
import '../../ar_view/models/scan_launch_args.dart';
import '../../ar_view/widgets/ar_camera_view.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
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
    final session = context.read<ReactionExperimentSessionProvider>();
    if (!session.canOpenScan || _openingAr) return;

    setState(() => _openingAr = true);
    try {
      final access = await _arAccessApi.getMyArAccess();
      if (!mounted) return;
      if (!access.canScanAR) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(access.message)),
        );
        return;
      }

      session.markEnteringScan();
      ARUnitySession.instance.experimentScanHandler =
          session.handleExperimentReactionCheck;

      await Navigator.pushNamed(
        context,
        AppRoutes.arAssetLoading,
        arguments: ScanLaunchArgs(
          mode: ScanMode.experiment,
          expectedReactionCode: session.activeReaction!.code,
        ),
      );

      if (!mounted) return;
      ARUnitySession.instance.experimentScanHandler = null;
      session.onReturnFromExperimentScan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _openingAr = false);
    }
  }

  Future<void> _confirmSubmit() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text(
          l10n.confirmSubmitTitle,
          style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
        ),
        content: Text(
          l10n.confirmSubmitMessage,
          style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ReactionExperimentSessionProvider>().submit(
            force: false,
            isVi: l10n.isVi,
          );
    }
  }

  void _leaveHub({required bool abandon}) {
    final session = context.read<ReactionExperimentSessionProvider>();
    if (abandon && session.shouldAbandonOnLeave) {
      session.abandonSession();
    } else if (session.showResult) {
      session.clearActiveSession();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();
    final session = context.watch<ReactionExperimentSessionProvider>();
    session.syncSubmitLocale(l10n.isVi);
    final reaction = session.activeReaction;

    if (reaction == null) {
      return Scaffold(
        body: Center(child: Text(l10n.noExperimentData)),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && session.shouldAbandonOnLeave) {
          session.abandonSession();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Container(
          decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                ExperimentScreenHeader(
                  title: reaction.name(l10n.isVi),
                  onBack: () => _leaveHub(abandon: true),
                  trailing: session.isTimerRunning
                      ? ExperimentTimerBadge(
                          timeText: session.formatRemaining(),
                          active: true,
                        )
                      : null,
                ),
                Expanded(
                  child: session.showResult && session.lastSubmitResult != null
                      ? _ResultPanel(
                          l10n: l10n,
                          record: session.lastSubmitResult!,
                          onBackToList: () {
                            session.clearActiveSession();
                            Navigator.pop(context);
                          },
                          onBackToCategories: () {
                            session.clearActiveSession();
                            Navigator.popUntil(
                              context,
                              ModalRoute.withName(AppRoutes.reactionCategory),
                            );
                          },
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          children: [
                            _ArSection(
                              l10n: l10n,
                              arCompleted: session.arCompleted,
                              canOpenScan: session.canOpenScan,
                              isOpening: _openingAr,
                              onOpenScan: _openExperimentScan,
                              timerText: session.isTimerRunning
                                  ? session.formatRemaining()
                                  : null,
                            ),
                            if (session.canShowQuizSection) ...[
                              const SizedBox(height: 20),
                              _ScriptSection(
                                l10n: l10n,
                                script: reaction.script(l10n.isVi),
                                equation: reaction.equation,
                              ),
                              const SizedBox(height: 20),
                              _QuizSection(
                                l10n: l10n,
                                questions: reaction.questions,
                                session: session,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: session.allQuestionsAnswered
                                      ? _confirmSubmit
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Text(l10n.submitQuiz),
                                ),
                              ),
                            ] else if (!session.arCompleted) ...[
                              const SizedBox(height: 16),
                              Text(
                                l10n.scanTwoCardsHint,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
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
  final bool arCompleted;
  final bool canOpenScan;
  final bool isOpening;
  final VoidCallback onOpenScan;
  final String? timerText;

  const _ArSection({
    required this.l10n,
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
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
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
                    color: AppColors.success.withOpacity(0.15),
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
                side: BorderSide(color: AppColors.primary.withOpacity(0.45)),
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
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
  final List<ExperimentQuizQuestion> questions;
  final ReactionExperimentSessionProvider session;

  const _QuizSection({
    required this.l10n,
    required this.questions,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
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
        for (var i = 0; i < questions.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _QuestionCard(
              index: i + 1,
              question: questions[i],
              selected: session.answerFor(questions[i].id),
              onSelect: (idx) => session.selectAnswer(questions[i].id, idx),
              l10n: l10n,
            ),
          ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final ExperimentQuizQuestion question;
  final int? selected;
  final ValueChanged<int> onSelect;
  final AppLocalizations l10n;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selected,
    required this.onSelect,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.questionNumber(index),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.questionText(l10n.isVi),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < question.options(l10n.isVi).length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected == i
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.backgroundDark.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected == i
                          ? AppColors.primary.withOpacity(0.5)
                          : AppColors.cardBorder.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    question.options(l10n.isVi)[i],
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
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
  final ExperimentAttemptRecord record;
  final VoidCallback onBackToList;
  final VoidCallback onBackToCategories;

  const _ResultPanel({
    required this.l10n,
    required this.record,
    required this.onBackToList,
    required this.onBackToCategories,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
          l10n.scoreOutOf(record.score, record.total),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 20),
        ...record.results.map((r) {
          final color = r.isCorrect ? AppColors.success : AppColors.error;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.questionText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                if (r.selectedIndex >= 0 && r.selectedIndex < r.options.length)
                  Text(
                    l10n.yourAnswer(r.options[r.selectedIndex]),
                    style: TextStyle(
                      fontSize: 13,
                      color: r.isCorrect ? AppColors.success : AppColors.error,
                      fontFamily: 'Inter',
                    ),
                  ),
                if (!r.isCorrect && r.correctIndex < r.options.length)
                  Text(
                    l10n.correctAnswerLabel(r.options[r.correctIndex]),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.success,
                      fontFamily: 'Inter',
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.explanationLabel}: ${r.explanation}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onBackToList,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(l10n.backToReactionList),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onBackToCategories,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(l10n.backToCategories),
          ),
        ),
      ],
    );
  }
}
