import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/student_quiz_provider.dart';
import '../../../domain/models/student_quiz_attempt_history_model.dart';

class StudentQuizHistoryScreen extends StatefulWidget {
  const StudentQuizHistoryScreen({super.key});

  @override
  State<StudentQuizHistoryScreen> createState() =>
      _StudentQuizHistoryScreenState();
}

class _StudentQuizHistoryScreenState extends State<StudentQuizHistoryScreen> {
  String? _quizCode;
  String? _quizTitle;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _quizCode = args['quizCode']?.toString();
      _quizTitle = args['quizTitle']?.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentQuizProvider>().loadAttemptHistory(
        quizCode: _quizCode,
      );
    });
  }

  Future<void> _refresh() async {
    await context.read<StudentQuizProvider>().loadAttemptHistory(
      quizCode: _quizCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentQuizProvider>();
    final attempts = provider.attemptHistory;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _Header(
                title: _quizTitle ?? 'Lịch sử làm quiz',
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                      Text(
                        'Lịch sử làm bài',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _quizTitle == null
                            ? 'Các lần làm quiz gần đây của bạn.'
                            : 'Các lần làm quiz: $_quizTitle',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),

                      if (provider.loadingAttemptHistory && attempts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (provider.attemptHistoryError != null)
                        _ErrorCard(
                          message: provider.attemptHistoryError!,
                          onRetry: _refresh,
                        )
                      else if (attempts.isEmpty)
                          const _EmptyCard()
                        else
                          ...attempts.map(
                                (attempt) => _AttemptHistoryCard(
                              attempt: attempt,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.quizAttemptDetail,
                                  arguments: {
                                    'attemptCode': attempt.attemptCode,
                                  },
                                );
                              },
                            ),
                          ),
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
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({
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
                fontSize: 20,
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

class _AttemptHistoryCard extends StatelessWidget {
  final StudentQuizAttemptHistoryModel attempt;
  final VoidCallback onTap;

  const _AttemptHistoryCard({
    required this.attempt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = attempt.totalQuestions == 0
        ? 0.0
        : attempt.correctCount / attempt.totalQuestions;

    final percentText = '${(percent * 100).round()}%';
    final submittedText = _formatDateTime(attempt.submittedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowCard,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Badge(text: attempt.status),
                const SizedBox(width: 8),
                _Badge(text: percentText),
                const Spacer(),
                Icon(
                  Icons.history,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              attempt.quizTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              attempt.lessonTitle,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.subtitleAccent,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ScoreBox(
                  label: 'Điểm',
                  value: '${attempt.score}/${attempt.totalQuestions}',
                ),
                const SizedBox(width: 10),
                _ScoreBox(
                  label: 'Đúng',
                  value: '${attempt.correctCount}',
                ),
                const SizedBox(width: 10),
                _ScoreBox(
                  label: 'Thời gian',
                  value: submittedText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day/$month $hour:$minute';
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.16),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.22),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.accentText,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.error.withOpacity(0.45),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 38),
          const SizedBox(height: 10),
          Text(
            'Không tải được lịch sử',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.45),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 52,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có lịch sử',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bạn chưa làm quiz này lần nào.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}