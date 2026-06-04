import 'package:flutter/material.dart';

import '../../../../shared/styles/app_colors.dart';
import '../models/game_models.dart';
import '../data/question_generator.dart';
import 'mini_game_play_screen.dart';
import 'mini_game_learning_screen.dart';

class MiniGameScreen extends StatelessWidget {
  const MiniGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildHeroSection(),
                      const SizedBox(height: 32),
                      _buildSectionLabel('Chế độ chơi'),
                      const SizedBox(height: 12),
                      _buildPlayCard(context),
                      const SizedBox(height: 16),
                      _buildLearnCard(context),
                      const SizedBox(height: 32),
                      _buildStatsRow(),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: AppColors.primary, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Mini Game Hóa Học',
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
            child: const Icon(Icons.science_outlined,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kiểm tra kiến thức\nHóa học của bạn!',
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
                  '300+ câu hỏi • 10 loại câu hỏi\nKhối lượng nguyên tử & Hóa trị',
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
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.play_circle_outline,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chơi Quiz',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trả lời câu hỏi trắc nghiệm về bảng tuần hoàn',
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
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu_book_outlined,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Học Bài Thơ',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đọc bài thơ hóa học và khám phá bảng nguyên tố',
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

  Widget _buildStatsRow() {
    final total = QuestionGenerator.getAllQuestions().length;
    return Row(
      children: [
        _StatTile(
          icon: Icons.quiz_outlined,
          value: '$total+',
          label: 'Câu hỏi',
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        _StatTile(
          icon: Icons.category_outlined,
          value: '10',
          label: 'Loại câu hỏi',
          color: AppColors.accent,
        ),
        const SizedBox(width: 12),
        _StatTile(
          icon: Icons.science_outlined,
          value: '35',
          label: 'Nguyên tố',
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
          final questions =
              QuestionGenerator.getQuestionsForDifficulty(difficulty);
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
          borderRadius: BorderRadius.circular(14),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            'Chọn độ khó',
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
    final c = difficulty.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_diffIcon(difficulty), color: c, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  difficulty.label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  difficulty.description,
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
