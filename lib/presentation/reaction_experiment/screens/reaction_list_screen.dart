import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../data/reaction_experiment/student_experiment_catalog.dart';
import '../../../domain/models/reaction_experiment/reaction_category.dart';
import '../../../domain/models/reaction_experiment/student_experiment_reaction.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../providers/reaction_experiment_session_provider.dart';
import '../widgets/experiment_screen_header.dart';

class ReactionListScreen extends StatefulWidget {
  const ReactionListScreen({super.key});

  @override
  State<ReactionListScreen> createState() => _ReactionListScreenState();
}

class _ReactionListScreenState extends State<ReactionListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _categoryTitle(AppLocalizations l10n, ReactionCategory c) {
    switch (c) {
      case ReactionCategory.metal:
        return l10n.reactionCategoryMetal;
      case ReactionCategory.acid:
        return l10n.reactionCategoryAcid;
      case ReactionCategory.base:
        return l10n.reactionCategoryBase;
      case ReactionCategory.salt:
        return l10n.reactionCategorySalt;
    }
  }

  List<StudentExperimentReaction> _filtered(
    ReactionExperimentSessionProvider session,
  ) {
    final grade = session.selectedGrade;
    final category = session.selectedCategory;
    if (grade == null || category == null) return [];

    var list = StudentExperimentCatalog.forGradeAndCategory(
      grade: grade,
      category: category,
    );

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      list = list
          .where(
            (r) =>
                r.nameVi.toLowerCase().contains(q) ||
                r.nameEn.toLowerCase().contains(q) ||
                r.equation.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();
    final session = context.watch<ReactionExperimentSessionProvider>();
    final reactions = _filtered(session);
    final category = session.selectedCategory;
    final grade = session.selectedGrade;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExperimentScreenHeader(
                title: category != null
                    ? _categoryTitle(l10n, category)
                    : l10n.backToReactionList,
                onBack: () => Navigator.pop(context),
                trailing: grade != null
                    ? Text(
                        l10n.gradeLabel(grade),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        ),
                      )
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchReactionsHint,
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.cardSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: reactions.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noReactionsFound,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: reactions.length,
                        itemBuilder: (context, index) {
                          final reaction = reactions[index];
                          final completed =
                              session.isReactionCompleted(reaction.code);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ReactionListTile(
                              reaction: reaction,
                              completed: completed,
                              l10n: l10n,
                              onStart: () {
                                session.beginReaction(reaction);
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.reactionExperimentHub,
                                );
                              },
                              onHistory: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.reactionExperimentHistory,
                                  arguments: reaction.code,
                                );
                              },
                              onRetry: () {
                                session.beginReaction(reaction);
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.reactionExperimentHub,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionListTile extends StatelessWidget {
  final StudentExperimentReaction reaction;
  final bool completed;
  final AppLocalizations l10n;
  final VoidCallback onStart;
  final VoidCallback onHistory;
  final VoidCallback onRetry;

  const _ReactionListTile({
    required this.reaction,
    required this.completed,
    required this.l10n,
    required this.onStart,
    required this.onHistory,
    required this.onRetry,
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
            reaction.name(l10n.isVi),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reaction.equation,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.subtitleAccent,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.reactantsLabel(reaction.reactantLabels.join(', ')),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 14),
          if (completed)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onHistory,
                    icon: const Icon(Icons.history, size: 18),
                    label: Text(l10n.viewAttemptHistory),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.retryExperiment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.startExperiment),
              ),
            ),
        ],
      ),
    );
  }
}
