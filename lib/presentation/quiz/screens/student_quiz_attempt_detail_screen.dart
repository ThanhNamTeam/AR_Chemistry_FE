import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/friendly_error.dart';
import '../../../domain/models/student_quiz_attempt_answer_detail_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/student_quiz_provider.dart';
import '../../../domain/models/student_quiz_attempt_detail_model.dart';

class StudentQuizAttemptDetailScreen extends StatefulWidget {
  const StudentQuizAttemptDetailScreen({super.key});

  @override
  State<StudentQuizAttemptDetailScreen> createState() =>
      _StudentQuizAttemptDetailScreenState();
}

class _StudentQuizAttemptDetailScreenState
    extends State<StudentQuizAttemptDetailScreen> {
  String? _attemptCode;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _attemptCode = args['attemptCode']?.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final attemptCode = _attemptCode;
      if (attemptCode == null || attemptCode.isEmpty) return;

      context.read<StudentQuizProvider>().loadAttemptDetail(attemptCode);
    });
  }

  Future<void> _refresh() async {
    final attemptCode = _attemptCode;
    if (attemptCode == null || attemptCode.isEmpty) return;

    await context.read<StudentQuizProvider>().loadAttemptDetail(attemptCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<StudentQuizProvider>();
    final detail = provider.attemptDetail;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => Navigator.pop(context)),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                      if (_attemptCode == null || _attemptCode!.isEmpty)
                        _EmptyCard(
                          title: l10n.attemptNotFound,
                          message: l10n.missingAttemptCode,
                        )
                      else if (provider.loadingAttemptDetail && detail == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (provider.attemptDetailError != null)
                          _ErrorCard(
                            message: friendlyError(
                              l10n,
                              provider.attemptDetailError,
                              context: 'attemptDetail',
                            ),
                            onRetry: _refresh,
                          )
                        else if (detail == null)
                            _EmptyCard(
                              title: l10n.noData,
                              message: l10n.attemptDetailNotFound,
                            )
                          else ...[
                              _SummaryCard(detail: detail),
                              const SizedBox(height: 14),
                              ...detail.answers.map(
                                    (answer) => _AnswerDetailCard(answer: answer),
                              ),
                            ],
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
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              l10n.attemptDetailTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final StudentQuizAttemptDetailModel detail;

  const _SummaryCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final percent = detail.totalQuestions == 0
        ? 0
        : ((detail.correctCount / detail.totalQuestions) * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_turned_in_outlined,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            '${detail.correctCount}/${detail.totalQuestions}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percent% • ${detail.status}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            detail.quizTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.quizTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerDetailCard extends StatelessWidget {
  final StudentQuizAttemptAnswerDetailModel answer;

  const _AnswerDetailCard({required this.answer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = answer.correct ? AppColors.success : AppColors.error;
    final label = answer.correct ? l10n.correct : l10n.incorrect;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowCard,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Badge(
                text: l10n.questionNumber(answer.questionOrder ?? 0),
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              // P2-8: đúng/sai không chỉ dựa vào màu — icon + chữ đi kèm
              // (người mù màu vẫn phân biệt được).
              Icon(
                answer.correct ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              _Badge(text: label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer.questionText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          _InfoLine(
            label: l10n.yourChoiceLabel,
            value: answer.studentAnswer ?? '-',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 6),
          _InfoLine(
            label: l10n.correctAnswerShort,
            value: answer.correctAnswer ?? '-',
            color: AppColors.success,
          ),
          if (answer.explanation != null &&
              answer.explanation!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              answer.explanation!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoLine({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.28),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w800,
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
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withOpacity(0.45),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 38),
          const SizedBox(height: 10),
          Text(
            l10n.cannotLoadDetail,
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
            label: Text(l10n.tryAgain),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyCard({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
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
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
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