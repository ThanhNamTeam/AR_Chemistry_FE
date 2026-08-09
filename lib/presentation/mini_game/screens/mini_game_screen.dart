import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';
import '../models/game_models.dart';
import '../data/question_generator.dart';
import 'mini_game_play_screen.dart';
import 'mini_game_learning_screen.dart';

class MiniGameScreen extends StatelessWidget {
  const MiniGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('mini_game_screen'),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildHeroSection(l10n),
                      const SizedBox(height: 32),
                      _buildSectionLabel(l10n.gameMode),
                      const SizedBox(height: 12),
                      _buildPlayCard(context),
                      const SizedBox(height: 16),
                      _buildLearnCard(context),
                      const SizedBox(height: 32),
                      _buildStatsRow(l10n),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Không có nút quay lại: Mini Game là một đích của thanh nav dưới.
          // Back cứng Android / vuốt mép iOS vẫn dùng được.
          Text(
            l10n.miniGameChemistryTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.science_outlined,
              color: AppColors.onGradient,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.accent.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.testYourKnowledge,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.miniGameHeroSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _AtomAnimation(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPlayCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => _showDifficultyDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.25),
              AppColors.accent.withOpacity(0.2),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.play_circle_outline,
                color: AppColors.onGradient,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.playQuiz,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.playQuizDesc,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MiniGameLearningScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withOpacity(0.2),
              AppColors.accent.withOpacity(0.15),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.cyanEmeraldGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.learnPoem,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.learnPoemDesc,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n) {
    final total = QuestionGenerator.getAllQuestions().length;
    return Row(
      children: [
        _StatTile(
          icon: Icons.quiz_outlined,
          value: '$total+',
          label: l10n.questionsLabel,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        _StatTile(
          icon: Icons.category_outlined,
          value: '10',
          label: l10n.questionTypesLabel,
          color: AppColors.accent,
        ),
        const SizedBox(width: 12),
        _StatTile(
          icon: Icons.science_outlined,
          value: '35',
          label: l10n.elementsLabel,
          color: AppColors.secondary,
        ),
      ],
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DifficultySheet(
        onSelected: (difficulty) {
          Navigator.pop(context);
          final questions = QuestionGenerator.getQuestionsForDifficulty(
            difficulty,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MiniGamePlayScreen(
                questions: questions,
                difficulty: difficulty,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Subwidgets ─────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultySheet extends StatelessWidget {
  final ValueChanged<GameDifficulty> onSelected;

  const _DifficultySheet({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.chooseDifficulty,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          for (final d in GameDifficulty.values) ...[
            _DifficultyTile(difficulty: d, onTap: () => onSelected(d)),
            if (d != GameDifficulty.hard) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final GameDifficulty difficulty;
  final VoidCallback onTap;

  const _DifficultyTile({required this.difficulty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = difficulty.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_diffIcon(difficulty), color: c, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _difficultyLabel(l10n),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  _difficultyDescription(l10n),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: c, size: 16),
          ],
        ),
      ),
    );
  }

  IconData _diffIcon(GameDifficulty d) {
    switch (d) {
      case GameDifficulty.easy:
        return Icons.sentiment_satisfied_outlined;
      case GameDifficulty.medium:
        return Icons.sentiment_neutral_outlined;
      case GameDifficulty.hard:
        return Icons.whatshot_outlined;
    }
  }

  String _difficultyLabel(AppLocalizations l10n) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return l10n.difficultyEasy;
      case GameDifficulty.medium:
        return l10n.difficultyMedium;
      case GameDifficulty.hard:
        return l10n.difficultyHard;
    }
  }

  String _difficultyDescription(AppLocalizations l10n) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return l10n.difficultyEasyDesc;
      case GameDifficulty.medium:
        return l10n.difficultyMediumDesc;
      case GameDifficulty.hard:
        return l10n.difficultyHardDesc;
    }
  }
}

class _AtomAnimation extends StatefulWidget {
  @override
  State<_AtomAnimation> createState() => _AtomAnimationState();
}

class _AtomAnimationState extends State<_AtomAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _rotate = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotate,
      builder: (_, __) => Transform.rotate(
        angle: _rotate.value * 2 * 3.14159,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.6),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
