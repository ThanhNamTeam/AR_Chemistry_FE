import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../data/reaction_experiment/student_experiment_catalog.dart';
import '../../../domain/models/reaction_experiment/experiment_attempt_record.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../providers/reaction_experiment_session_provider.dart';
import '../widgets/experiment_screen_header.dart';

class ReactionExperimentHistoryScreen extends StatelessWidget {
  const ReactionExperimentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();
    final session = context.watch<ReactionExperimentSessionProvider>();

    final code = ModalRoute.of(context)?.settings.arguments as String?;
    final reaction = code != null
        ? StudentExperimentCatalog.byCode(code)
        : session.activeReaction;
    final record =
        code != null ? session.attemptFor(code) : session.lastSubmitResult;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              ExperimentScreenHeader(
                title: l10n.viewAttemptHistory,
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: record == null || reaction == null
                    ? Center(
                        child: Text(
                          l10n.noHistoryYet,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        children: [
                          Text(
                            reaction.name(l10n.isVi),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.scoreOutOf(record.score, record.total),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...record.results.map(
                            (r) => _HistoryQuestionCard(result: r, l10n: l10n),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryQuestionCard extends StatelessWidget {
  final ExperimentQuestionResult result;
  final AppLocalizations l10n;

  const _HistoryQuestionCard({
    required this.result,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final correctColor = AppColors.success;
    final wrongColor = AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (result.isCorrect ? correctColor : wrongColor)
              .withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.questionText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          if (result.selectedIndex >= 0 &&
              result.selectedIndex < result.options.length)
            Text(
              l10n.yourAnswer(result.options[result.selectedIndex]),
              style: TextStyle(
                fontSize: 13,
                color: result.isCorrect ? correctColor : wrongColor,
                fontFamily: 'Inter',
              ),
            ),
          if (!result.isCorrect &&
              result.correctIndex < result.options.length)
            Text(
              l10n.correctAnswerLabel(
                result.options[result.correctIndex],
              ),
              style: TextStyle(
                fontSize: 13,
                color: correctColor,
                fontFamily: 'Inter',
              ),
            ),
          const SizedBox(height: 6),
          Text(
            '${l10n.explanationLabel}: ${result.explanation}',
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
  }
}
