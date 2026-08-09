import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';
import '../models/game_models.dart';
import 'mini_game_review_screen.dart';

class MiniGamePlayScreen extends StatefulWidget {
  final List<ChemQuestion> questions;
  final GameDifficulty difficulty;

  const MiniGamePlayScreen({
    super.key,
    required this.questions,
    required this.difficulty,
  });

  @override
  State<MiniGamePlayScreen> createState() => _MiniGamePlayScreenState();
}

class _MiniGamePlayScreenState extends State<MiniGamePlayScreen>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  String? _selected;
  bool _answered = false;
  final List<UserAnswer> _answers = [];

  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackAnim;

  ChemQuestion get question => widget.questions[_current];
  bool get isLastQuestion => _current == widget.questions.length - 1;

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _feedbackAnim = CurvedAnimation(
      parent: _feedbackCtrl,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _selectAnswer(String choice) {
    if (_answered) return;
    setState(() {
      _selected = choice;
      _answered = true;
    });
    _feedbackCtrl.forward(from: 0);
  }

  void _nextQuestion() {
    _answers.add(UserAnswer(question: question, selectedAnswer: _selected));

    if (isLastQuestion) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MiniGameReviewScreen(
            answers: _answers,
            difficulty: widget.difficulty,
          ),
        ),
      );
      return;
    }

    setState(() {
      _current++;
      _selected = null;
      _answered = false;
    });
    _feedbackCtrl.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = widget.questions.length;
    final progress = (_current + 1) / total;

    return Scaffold(
      key: const Key('mini_game_play_screen'),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(progress, total),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildQuestionCard(l10n),
                      const SizedBox(height: 24),
                      _buildChoices(),
                      const SizedBox(height: 24),
                      if (_answered) _buildFeedbackBanner(l10n),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(double progress, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                key: const Key('minigame_exit_button'),
                onTap: () => _showExitDialog(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.close,
                      color: AppColors.textSecondary, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_current + 1}/$total',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: _QuestionTypeBadge(type: question.type),
          ),
        ],
      ),
    );
  }

  /// True when the question text IS a poem excerpt (blank inside the line).
  bool get _isPoemFill =>
      question.type == QuestionType.a || question.type == QuestionType.g;

  Widget _buildQuestionCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPoemFill
              ? AppColors.accent.withOpacity(0.35)
              : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: câu số + loại
          Row(
            children: [
              Text(
                l10n.questionNumber(_current + 1),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              if (_isPoemFill) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories_outlined,
                          size: 11, color: AppColors.amberLight),
                      const SizedBox(width: 4),
                      Text(
                        l10n.fillInPoem,
                        style: TextStyle(
                          color: AppColors.amberLight,
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Poem excerpt box (only for poem-fill types)
          if (_isPoemFill) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.accent.withOpacity(0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left accent bar
                  Container(
                    width: 3,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HighlightedPoemText(text: question.questionText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.fillBlankInstruction,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ] else ...[
            // Normal question text
            Text(
              question.questionText,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChoices() {
    final isTrueFalse = question.choices.length == 2;
    if (isTrueFalse) return _buildTrueFalseChoices();
    return _buildMcqChoices();
  }

  Widget _buildTrueFalseChoices() {
    return Row(
      children: question.choices.map((c) {
        final isSelected = _selected == c;
        final isCorrect = c == question.correctAnswer;
        Color borderColor = AppColors.primary.withOpacity(0.2);
        Color bgColor = AppColors.cardBg.withOpacity(0.5);
        Color textColor = AppColors.textPrimary;
        IconData? trailingIcon;

        if (_answered) {
          if (isCorrect) {
            borderColor = AppColors.success;
            bgColor = AppColors.success.withOpacity(0.12);
            textColor = AppColors.success;
            trailingIcon = Icons.check_circle_outline;
          } else if (isSelected && !isCorrect) {
            borderColor = AppColors.error;
            bgColor = AppColors.error.withOpacity(0.12);
            textColor = AppColors.error;
            trailingIcon = Icons.cancel_outlined;
          }
        } else if (isSelected) {
          borderColor = AppColors.primary;
          bgColor = AppColors.primary.withOpacity(0.15);
          textColor = AppColors.primary;
        }

        return Expanded(
          child: GestureDetector(
            key: ValueKey('minigame_choice_${question.choices.indexOf(c)}'),
            onTap: () => _selectAnswer(c),
            child: Container(
              margin: EdgeInsets.only(
                  right: c == question.choices.first ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailingIcon != null)
                    Icon(trailingIcon, color: textColor, size: 20),
                  if (trailingIcon != null) const SizedBox(height: 4),
                  Text(
                    c,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMcqChoices() {
    return Column(
      children: question.choices.map((c) {
        final isSelected = _selected == c;
        final isCorrect = c == question.correctAnswer;
        Color borderColor = AppColors.primary.withOpacity(0.15);
        Color bgColor = AppColors.cardBg.withOpacity(0.5);
        Color textColor = AppColors.textPrimary;
        IconData? icon;

        if (_answered) {
          if (isCorrect) {
            borderColor = AppColors.success;
            bgColor = AppColors.success.withOpacity(0.1);
            textColor = AppColors.success;
            icon = Icons.check_circle_outline;
          } else if (isSelected) {
            borderColor = AppColors.error;
            bgColor = AppColors.error.withOpacity(0.1);
            textColor = AppColors.error;
            icon = Icons.cancel_outlined;
          }
        } else if (isSelected) {
          borderColor = AppColors.primary;
          bgColor = AppColors.primary.withOpacity(0.12);
          textColor = AppColors.primary;
          icon = Icons.radio_button_checked;
        }

        return GestureDetector(
          key: ValueKey('minigame_choice_${question.choices.indexOf(c)}'),
          onTap: () => _selectAnswer(c),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    c,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                if (icon != null) Icon(icon, color: textColor, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackBanner(AppLocalizations l10n) {
    final correct = _selected == question.correctAnswer;
    final color = correct ? AppColors.success : AppColors.error;
    final icon = correct ? Icons.check_circle : Icons.cancel;
    final title = correct ? l10n.exactAnswer : l10n.wrongAnswer;

    return FadeTransition(
      key: const Key('minigame_feedback'),
      opacity: _feedbackAnim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            if (!correct) ...[
              const SizedBox(height: 6),
              Text(
                l10n.correctAnswerLabel(question.correctAnswer),
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              '📖 ${question.poemLine}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'Inter',
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primary.withOpacity(0.15)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          key: const Key('minigame_next_button'),
          onPressed: _answered ? _nextQuestion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            isLastQuestion && _answered ? l10n.viewResults : '${l10n.next} →',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.exitQuizTitle,
          style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
        ),
        content: Text(
          l10n.exitQuizMessage,
          style:
              TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(
                    color: AppColors.textSecondary, fontFamily: 'Inter')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(l10n.exit,
                style:
                    TextStyle(color: AppColors.error, fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }
}

// ── Highlighted poem text ────────────────────────────────────────────────────

/// Renders poem text with "___" shown as a styled blank box.
class _HighlightedPoemText extends StatelessWidget {
  final String text;
  const _HighlightedPoemText({required this.text});

  @override
  Widget build(BuildContext context) {
    const blank = '___';
    final parts = text.split(blank);

    if (parts.length <= 1) {
      // No blank found – just render normally
      return Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          fontStyle: FontStyle.italic,
          height: 1.6,
        ),
      );
    }

    // Build inline spans: text … [___] … text
    final spans = <InlineSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            fontStyle: FontStyle.italic,
          ),
        ));
      }
      if (i < parts.length - 1) {
        // The blank widget as WidgetSpan
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.amber.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Text(
              '?',
              style: TextStyle(
                color: AppColors.amberLight,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

// ── Question type badge ────────────────────────────────────────────────────

class _QuestionTypeBadge extends StatelessWidget {
  final QuestionType type;

  const _QuestionTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = _label(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.accentLight,
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _label(QuestionType t) {
    switch (t) {
      case QuestionType.a:
        return 'Điền khối lượng';
      case QuestionType.b:
        return 'Điền tên nguyên tố';
      case QuestionType.c:
        return 'Nhận biết ký hiệu';
      case QuestionType.d:
        return 'Khối lượng nguyên tử';
      case QuestionType.e:
        return 'Hóa trị';
      case QuestionType.f:
        return 'Đa hóa trị';
      case QuestionType.g:
        return 'Hoàn thành bài thơ';
      case QuestionType.h:
        return 'Đúng / Sai';
      case QuestionType.i:
        return 'Ghép ký hiệu – khối lượng';
      case QuestionType.j:
        return 'Ghép ký hiệu – hóa trị';
    }
  }
}
