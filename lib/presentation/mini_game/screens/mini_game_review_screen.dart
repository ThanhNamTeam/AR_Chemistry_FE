import 'package:flutter/material.dart';

import '../../../../shared/styles/app_colors.dart';
import '../models/game_models.dart';
import 'mini_game_screen.dart';

class MiniGameReviewScreen extends StatelessWidget {
  final List<UserAnswer> answers;
  final GameDifficulty difficulty;

  const MiniGameReviewScreen({
    super.key,
    required this.answers,
    required this.difficulty,
  });

  int get _correct => answers.where((a) => a.isCorrect).length;
  double get _percent => _correct / answers.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildScoreBanner(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: answers.length,
                  itemBuilder: (_, i) => _ReviewItem(
                    answer: answers[i],
                    index: i + 1,
                  ),
                ),
              ),
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MiniGameScreen()),
                (r) => r.settings.name != null,
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.home_outlined,
                  color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Kết quả',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: difficulty.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: difficulty.color.withOpacity(0.3)),
            ),
            child: Text(
              difficulty.label,
              style: TextStyle(
                color: difficulty.color,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBanner() {
    final pct = (_percent * 100).round();
    Color scoreColor;
    String message;
    if (pct >= 80) {
      scoreColor = AppColors.success;
      message = 'Xuất sắc! 🎉';
    } else if (pct >= 60) {
      scoreColor = AppColors.warning;
      message = 'Khá tốt! Cố gắng hơn nhé.';
    } else {
      scoreColor = AppColors.error;
      message = 'Cần ôn tập thêm!';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withOpacity(0.15),
            scoreColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _CircleScore(correct: _correct, total: answers.length, color: scoreColor),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 6),
                _ScoreRow(
                  icon: Icons.check_circle_outline,
                  label: 'Đúng',
                  value: '$_correct câu',
                  color: AppColors.success,
                ),
                const SizedBox(height: 4),
                _ScoreRow(
                  icon: Icons.cancel_outlined,
                  label: 'Sai',
                  value: '${answers.length - _correct} câu',
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primary.withOpacity(0.15)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MiniGameScreen()),
                (r) => r.settings.name != null,
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Về menu',
                style: TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MiniGameScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text(
                'Chơi lại',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _CircleScore extends StatelessWidget {
  final int correct;
  final int total;
  final Color color;

  const _CircleScore(
      {required this.correct, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: correct / total,
            strokeWidth: 6,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$correct',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '/$total',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ScoreRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _ReviewItem extends StatefulWidget {
  final UserAnswer answer;
  final int index;

  const _ReviewItem({required this.answer, required this.index});

  @override
  State<_ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<_ReviewItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.answer;
    final correct = a.isCorrect;
    final borderColor = correct
        ? AppColors.success.withOpacity(0.3)
        : AppColors.error.withOpacity(0.3);
    final iconColor = correct ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index}',
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.question.questionText,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                          maxLines: _expanded ? null : 2,
                          overflow: _expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              correct
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: iconColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Bạn chọn: ${a.selectedAnswer ?? "Bỏ qua"}',
                                style: TextStyle(
                                  color: iconColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!correct) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Đáp án đúng: ${a.question.correctAnswer}',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(
                height: 1,
                color: AppColors.primary.withOpacity(0.1)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.auto_stories_outlined,
                    label: 'Bài thơ:',
                    value: a.question.poemLine,
                    valueColor: AppColors.textCyan,
                    italic: true,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.lightbulb_outline,
                    label: 'Giải thích:',
                    value: a.question.explanation,
                    valueColor: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool italic;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
