import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../domain/models/reaction_experiment/reaction_category.dart';
import '../../../domain/models/student_reaction_model.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../../quiz/providers/student_quiz_provider.dart';
import '../providers/reaction_experiment_session_provider.dart';
import '../widgets/experiment_screen_header.dart';

class ReactionListScreen extends StatefulWidget {
  const ReactionListScreen({super.key});

  @override
  State<ReactionListScreen> createState() =>
      _ReactionListScreenState();
}

class _ReactionListScreenState
    extends State<ReactionListScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  bool _initialized = false;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReactions() async {
    final session =
    context.read<ReactionExperimentSessionProvider>();

    final grade = session.selectedGrade;
    final category = session.selectedCategory;

    if (grade == null || category == null) {
      return;
    }

    await context.read<StudentQuizProvider>().loadReactions(
      grade: grade,
      reactionCategory: _categoryApiValue(category),
      keyword: _query.trim(),
      page: 0,
      size: 20,
    );
  }

  Future<void> _startReaction(
      StudentReactionModel reaction,
      ) async {

    final session =
    context.read<ReactionExperimentSessionProvider>();

    final started = await session.beginReaction(reaction);

    if (!mounted) {
      return;
    }

    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            session.sessionError ??
                'Không thể bắt đầu phản ứng',
          ),
        ),
      );

      return;
    }

    await Navigator.pushNamed(
      context,
      AppRoutes.reactionExperimentHub,
    );

    if (!mounted) {
      return;
    }

    await _loadReactions();
  }

  void _openHistory(
      StudentReactionModel reaction,
      ) {
    Navigator.pushNamed(
      context,
      AppRoutes.reactionExperimentHistory,
      arguments: {
        'reactionId': reaction.reactionId,
        'reactionName': reaction.reactionName,
      },
    );
  }

  String _categoryApiValue(
      ReactionCategory category,
      ) {
    switch (category) {
      case ReactionCategory.metal:
        return 'METAL';

      case ReactionCategory.acid:
        return 'ACID';

      case ReactionCategory.base:
        return 'BASE';

      case ReactionCategory.salt:
        return 'SALT';
    }
  }

  String _categoryTitle(
      AppLocalizations l10n,
      ReactionCategory category,
      ) {
    switch (category) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();

    final session =
    context.watch<ReactionExperimentSessionProvider>();

    final quizProvider =
    context.watch<StudentQuizProvider>();

    final reactions = quizProvider.reactions;
    final category = session.selectedCategory;
    final grade = session.selectedGrade;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              ExperimentScreenHeader(
                title: category != null
                    ? _categoryTitle(
                  l10n,
                  category,
                )
                    : l10n.backToReactionList,
                onBack: () {
                  Navigator.pop(context);
                },
                trailing: grade != null
                    ? Text(
                  l10n.gradeLabel(grade),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
                    color: AppColors.primary,
                    fontFamily: 'Inter',
                  ),
                )
                    : null,
              ),

              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  12,
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction:
                  TextInputAction.search,
                  onChanged: (value) {
                    _query = value;
                  },
                  onSubmitted: (_) {
                    _loadReactions();
                  },
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                  decoration: InputDecoration(
                    hintText:
                    l10n.searchReactionsHint,
                    hintStyle: TextStyle(
                      color:
                      AppColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _loadReactions,
                      icon: const Icon(
                        Icons.arrow_forward,
                      ),
                    ),
                    filled: true,
                    fillColor:
                    AppColors.cardSurface,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary
                            .withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadReactions,
                  child: _buildBody(
                    context,
                    l10n,
                    quizProvider,
                    reactions,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      AppLocalizations l10n,
      StudentQuizProvider quizProvider,
      List<StudentReactionModel> reactions,
      ) {
    if (quizProvider.loadingReactions &&
        reactions.isEmpty) {
      return ListView(
        physics:
        AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 140),
          Center(
            child:
            CircularProgressIndicator(),
          ),
        ],
      );
    }

    if (quizProvider.reactionsError != null &&
        reactions.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.fromLTRB(
          20,
          30,
          20,
          24,
        ),
        children: [
          _ErrorCard(
            message:
            quizProvider.reactionsError!,
            onRetry: _loadReactions,
          ),
        ],
      );
    }

    if (reactions.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 140),
          Center(
            child: Text(
              l10n.noReactionsFound,
              style: TextStyle(
                color:
                AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24,
      ),
      itemCount: reactions.length,
      itemBuilder: (context, index) {
        final reaction = reactions[index];

        final loading =
            context
                .watch<
                ReactionExperimentSessionProvider>()
                .activeReaction
                ?.reactionId ==
                reaction.reactionId &&
                context
                    .watch<
                    ReactionExperimentSessionProvider>()
                    .quizProvider
                    .startingAttempt;

        return Padding(
          padding:
          const EdgeInsets.only(bottom: 12),
          child: _ReactionListTile(
            reaction: reaction,
            loading: loading,
            l10n: l10n,
            onStart: () {
              _startReaction(reaction);
            },
            onHistory: () {
              _openHistory(reaction);
            },
          ),
        );
      },
    );
  }
}

class _ReactionListTile
    extends StatelessWidget {
  final StudentReactionModel reaction;
  final bool loading;
  final AppLocalizations l10n;
  final VoidCallback onStart;
  final VoidCallback onHistory;

  const _ReactionListTile({
    required this.reaction,
    required this.loading,
    required this.l10n,
    required this.onStart,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary
              .withValues(alpha: 0.2),
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
                  reaction.reactionName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (reaction.completed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 17,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đã hoàn thành',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                )
              else if (reaction.hasPublishedQuiz)
                Icon(
                  Icons.quiz_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            reaction.equation,
            style: TextStyle(
              fontSize: 13,
              color:
              AppColors.subtitleAccent,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),

          if (reaction.description != null &&
              reaction.description!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              reaction.description!,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color:
                AppColors.textSecondary,
                fontFamily: 'Inter',
                height: 1.35,
              ),
            ),
          ],

          const SizedBox(height: 10),

          Row(
            children: [
              _InfoItem(
                icon: Icons.help_outline,
                text: '${reaction.questionCount} câu',
              ),
              const SizedBox(width: 14),
              _InfoItem(
                icon: Icons.timer_outlined,
                text: '${reaction.durationSeconds ~/ 60} phút',
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onHistory,
                  icon: const Icon(
                    Icons.history,
                    size: 18,
                  ),
                  label: Text(
                    l10n.viewAttemptHistory,
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                  loading ? null : onStart,
                  icon: loading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.play_arrow,
                    size: 18,
                  ),
                  label: Text(
                    loading
                        ? 'Đang tải'
                        : l10n.startExperiment,
                  ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.primary,
                    foregroundColor:
                    Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color:
          AppColors.error.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
              AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon:
            const Icon(Icons.refresh),
            label:
            const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}