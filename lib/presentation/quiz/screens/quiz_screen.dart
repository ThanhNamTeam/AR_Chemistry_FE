import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../providers/student_quiz_provider.dart';
import '../../../domain/models/student_quiz_question_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? _lessonCode;
  String? _lessonTitle;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _lessonCode = args['lessonCode']?.toString();
      _lessonTitle = args['lessonTitle']?.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lessonCode = _lessonCode;

      if (lessonCode == null || lessonCode.isEmpty) return;

      context.read<StudentQuizProvider>().loadPublishedQuizByLesson(lessonCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final quizProvider = context.watch<StudentQuizProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _QuizHeader(
                title: _lessonTitle ?? 'Quiz',
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: _buildBody(context, quizProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, StudentQuizProvider provider) {
    if (_lessonCode == null || _lessonCode!.isEmpty) {
      return _EmptyState(
        icon: Icons.error_outline,
        title: 'Không tìm thấy bài học',
        message: 'Màn hình quiz cần lessonCode để tải quiz.',
        actionLabel: 'Về Home',
        onAction: () => _goHome(context),
      );
    }

    if (provider.loadingSummary) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.summaryError != null) {
      return _EmptyState(
        icon: Icons.error_outline,
        title: 'Không tải được quiz',
        message: provider.summaryError!,
        actionLabel: 'Thử lại',
        onAction: () {
          context
              .read<StudentQuizProvider>()
              .loadPublishedQuizByLesson(_lessonCode!);
        },
      );
    }

    if (!provider.hasQuiz) {
      return _EmptyState(
        icon: Icons.quiz_outlined,
        title: 'Chưa có quiz',
        message: 'Bài học này hiện chưa có quiz đã publish.',
        actionLabel: 'Về Home',
        onAction: () => _goHome(context),
      );
    }

    if (!provider.hasLoadedQuestions) {
      return _QuizIntro(provider: provider);
    }

    if (provider.submitResult != null) {
      return _QuizResultView(provider: provider);
    }

    return _QuizQuestionList(provider: provider);
  }

  void _goHome(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
            (_) => false,
      );
    }
  }
}

class _QuizHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _QuizHeader({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizIntro extends StatelessWidget {
  final StudentQuizProvider provider;

  const _QuizIntro({required this.provider});

  @override
  Widget build(BuildContext context) {
    final quiz = provider.quizSummary!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  size: 44,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                quiz.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${quiz.questionCount} câu hỏi',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.loadingQuestions
                      ? null
                      : () {
                    context
                        .read<StudentQuizProvider>()
                        .loadQuizQuestions(quiz.quizCode);
                  },
                  icon: provider.loadingQuestions
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    provider.loadingQuestions
                        ? 'Đang tải...'
                        : 'Bắt đầu làm quiz',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (provider.questionsError != null) ...[
                const SizedBox(height: 12),
                Text(
                  provider.questionsError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizQuestionList extends StatelessWidget {
  final StudentQuizProvider provider;

  const _QuizQuestionList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final quiz = provider.quizDetail!;
    final questions = quiz.questions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          quiz.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Đã trả lời ${provider.answeredCount}/${provider.totalQuestions}',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 14),
        ...questions.map(
              (question) => _QuestionCard(
            question: question,
            selectedAnswer: provider.answers[question.id],
            onSelectAnswer: (answer) {
              context.read<StudentQuizProvider>().selectAnswer(
                questionId: question.id,
                answer: answer,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.canSubmit && !provider.submitting
                ? () {
              context.read<StudentQuizProvider>().submitCurrentQuiz();
            }
                : null,
            icon: provider.submitting
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.check_circle_outline),
            label: Text(provider.submitting ? 'Đang nộp...' : 'Nộp bài'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (provider.submitError != null) ...[
          const SizedBox(height: 10),
          Text(
            provider.submitError!,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final StudentQuizQuestionModel question;
  final String? selectedAnswer;
  final ValueChanged<String> onSelectAnswer;

  const _QuestionCard({
    required this.question,
    required this.selectedAnswer,
    required this.onSelectAnswer,
  });

  List<String> _parseOptions(String? optionsJson) {
    if (optionsJson == null || optionsJson.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(optionsJson);
      if (decoded is List) {
        return decoded.map((item) => item.toString()).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final options = _parseOptions(question.optionsJson);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Badge(text: 'Câu ${question.questionOrder ?? '-'}'),
              const SizedBox(width: 8),
              _Badge(text: question.type),
              const Spacer(),
              Text(
                question.difficulty ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.questionText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          if (question.type == 'true_false')
            ...['TRUE', 'FALSE'].map(
                  (answer) => _AnswerOption(
                label: answer,
                text: answer == 'TRUE' ? 'Đúng' : 'Sai',
                selected: selectedAnswer == answer,
                onTap: () => onSelectAnswer(answer),
              ),
            )
          else if (options.isNotEmpty)
            ...options.asMap().entries.map(
                  (entry) {
                final label = String.fromCharCode(65 + entry.key);
                return _AnswerOption(
                  label: label,
                  text: entry.value,
                  selected: selectedAnswer == label,
                  onTap: () => onSelectAnswer(label),
                );
              },
            )
          else
            TextField(
              onChanged: onSelectAnswer,
              decoration: InputDecoration(
                hintText: 'Nhập đáp án của bạn',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(0.7)
                : AppColors.textSecondary.withOpacity(0.22),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label. ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontFamily: 'Inter',
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  final StudentQuizProvider provider;

  const _QuizResultView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final result = provider.submitResult!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                color: Colors.white,
                size: 46,
              ),
              const SizedBox(height: 12),
              Text(
                '${result.correctCount}/${result.total}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kết quả bài làm',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...result.results.map(
              (r) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: r.correct
                    ? AppColors.success.withOpacity(0.5)
                    : AppColors.error.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.correct ? 'Đúng' : 'Sai',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: r.correct ? AppColors.success : AppColors.error,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bạn chọn: ${r.studentAnswer ?? '-'}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'Đáp án đúng: ${r.correctAnswer ?? '-'}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                if (r.explanation != null && r.explanation!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    r.explanation!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: AppColors.primary),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}