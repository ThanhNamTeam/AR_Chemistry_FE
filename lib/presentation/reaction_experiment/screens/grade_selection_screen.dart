import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../providers/reaction_experiment_session_provider.dart';
import '../widgets/experiment_screen_header.dart';

class GradeSelectionScreen extends StatefulWidget {
  const GradeSelectionScreen({super.key});

  @override
  State<GradeSelectionScreen> createState() => _GradeSelectionScreenState();
}

class _GradeSelectionScreenState extends State<GradeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReactionExperimentSessionProvider>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();
    final session = context.watch<ReactionExperimentSessionProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExperimentScreenHeader(
                title: l10n.navQuiz,
                onBack: () => Navigator.pop(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  l10n.selectYourGrade,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    for (final grade in [8, 9, 10, 11, 12])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GradeTile(
                          grade: grade,
                          selected: session.selectedGrade == grade,
                          onTap: () async {
                            await session.selectGrade(grade);
                            if (!context.mounted) return;
                            unawaited(Navigator.pushNamed(
                              context,
                              AppRoutes.reactionCategory,
                            ));
                          },
                        ),
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

class _GradeTile extends StatelessWidget {
  final int grade;
  final bool selected;
  final VoidCallback onTap;

  const _GradeTile({
    required this.grade,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.school_outlined,
              color: selected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                l10n.gradeLabel(grade),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: selected ? Colors.white70 : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
