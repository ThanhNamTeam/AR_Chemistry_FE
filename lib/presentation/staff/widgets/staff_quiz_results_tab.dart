import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/staff_quiz_attempt_detail_model.dart';
import '../../../domain/models/staff_quiz_attempt_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/staff_provider.dart';

class StaffQuizResultsTab extends StatefulWidget {
  const StaffQuizResultsTab({super.key});

  @override
  State<StaffQuizResultsTab> createState() => _StaffQuizResultsTabState();
}

class _StaffQuizResultsTabState extends State<StaffQuizResultsTab> {
  StaffQuizAttemptModel? _selectedAttempt;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadQuizAttempts();
    });
  }

  Future<void> _refresh() async {
    final selectedAttempt = _selectedAttempt;

    if (selectedAttempt == null) {
      await context.read<StaffProvider>().loadQuizAttempts();
    } else {
      await context
          .read<StaffProvider>()
          .loadQuizAttemptDetail(selectedAttempt.attemptCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staff = context.watch<StaffProvider>();

    final selectedAttempt = _selectedAttempt;
    final attempts = staff.quizAttempts;
    final detail = staff.selectedQuizAttemptDetail;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          PortalPrimaryButton(
            label: selectedAttempt == null
                ? 'Kết quả làm quiz'
                : 'Chi tiết bài làm',
            icon: selectedAttempt == null
                ? Icons.analytics_outlined
                : Icons.assignment_outlined,
            loading:
            staff.loadingQuizAttempts || staff.loadingQuizAttemptDetail,
            onPressed: _refresh,
          ),
          const SizedBox(height: 8),
          Text(
            selectedAttempt == null
                ? 'Theo dõi điểm và lịch sử làm quiz của học sinh.'
                : 'Xem từng câu trả lời, đáp án đúng và giải thích.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          if (selectedAttempt == null) ...[
            PortalSectionHeader(
              title: 'Quiz Results',
              actionLabel: '${attempts.length}',
            ),
            const SizedBox(height: 10),
            if (staff.loadingQuizAttempts && attempts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (staff.quizAttemptsError != null)
              _ErrorCard(
                message: staff.quizAttemptsError!,
                onRetry: _refresh,
              )
            else if (attempts.isEmpty)
                const _EmptyCard(
                  message: 'Chưa có học sinh nào nộp quiz.',
                )
              else
                ...attempts.map(
                      (attempt) => _AttemptCard(
                    attempt: attempt,
                    onTap: () async {
                      setState(() => _selectedAttempt = attempt);

                      await context
                          .read<StaffProvider>()
                          .loadQuizAttemptDetail(attempt.attemptCode);
                    },
                  ),
                ),
          ] else ...[
            _SelectedAttemptHeader(
              attempt: selectedAttempt,
              onBack: () {
                context.read<StaffProvider>().clearQuizAttemptDetail();
                setState(() => _selectedAttempt = null);
              },
            ),
            const SizedBox(height: 10),
            if (staff.loadingQuizAttemptDetail && detail == null)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (staff.quizAttemptDetailError != null)
              _ErrorCard(
                message: staff.quizAttemptDetailError!,
                onRetry: _refresh,
              )
            else if (detail == null)
                const _EmptyCard(
                  message: 'Không tìm thấy chi tiết bài làm.',
                )
              else ...[
                  _AttemptSummaryCard(detail: detail),
                  const SizedBox(height: 10),
                  ...detail.answers.map(
                        (answer) => _AnswerDetailCard(answer: answer),
                  ),
                ],
          ],
        ],
      ),
    );
  }
}

class _AttemptCard extends StatelessWidget {
  final StaffQuizAttemptModel attempt;
  final VoidCallback onTap;

  const _AttemptCard({
    required this.attempt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = attempt.totalQuestions == 0
        ? 0
        : ((attempt.correctCount / attempt.totalQuestions) * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PortalGlassCard(
        accentBorder: AppColors.subtitleAccent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PortalBadge(
                    text: '${attempt.score}/${attempt.totalQuestions}',
                    color: _scoreColor(percent),
                  ),
                  const SizedBox(width: 8),
                  PortalBadge(
                    text: '$percent%',
                    color: _scoreColor(percent),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                attempt.studentName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              if (attempt.studentEmail != null &&
                  attempt.studentEmail!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  attempt.studentEmail!,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                attempt.quizTitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.subtitleAccent,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                attempt.lessonTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 15,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Đúng ${attempt.correctCount}/${attempt.totalQuestions}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(attempt.submittedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _scoreColor(int percent) {
    if (percent >= 80) return AppColors.success;
    if (percent >= 50) return AppColors.amber;
    return AppColors.error;
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

class _SelectedAttemptHeader extends StatelessWidget {
  final StaffQuizAttemptModel attempt;
  final VoidCallback onBack;

  const _SelectedAttemptHeader({
    required this.attempt,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return PortalGlassCard(
      accentBorder: AppColors.subtitleAccent,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.subtitleAccent,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attempt.studentName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${attempt.quizTitle} • ${attempt.score}/${attempt.totalQuestions}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptSummaryCard extends StatelessWidget {
  final StaffQuizAttemptDetailModel detail;

  const _AttemptSummaryCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final percent = detail.totalQuestions == 0
        ? 0
        : ((detail.correctCount / detail.totalQuestions) * 100).round();

    return PortalGlassCard(
      accentBorder: AppColors.primary,
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            '${detail.correctCount}/${detail.totalQuestions}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percent% • ${detail.status}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            detail.quizTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${detail.lessonTitle} • ${detail.studentName}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerDetailCard extends StatelessWidget {
  final StaffQuizAttemptAnswerModel answer;

  const _AnswerDetailCard({
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final color = answer.correct ? AppColors.success : AppColors.error;
    final label = answer.correct ? 'Đúng' : 'Sai';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PortalGlassCard(
        accentBorder: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PortalBadge(
                  text: 'Câu ${answer.questionOrder ?? '-'}',
                  color: AppColors.subtitleAccent,
                ),
                const SizedBox(width: 8),
                PortalBadge(
                  text: label,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              answer.questionText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            _InfoLine(
              label: 'Học sinh chọn',
              value: answer.studentAnswer ?? '-',
              color: answer.correct ? AppColors.success : AppColors.error,
            ),
            const SizedBox(height: 6),
            _InfoLine(
              label: 'Đáp án đúng',
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
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
            ),
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
    return PortalGlassCard(
      accentBorder: AppColors.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Không tải được dữ liệu',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
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
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return PortalGlassCard(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}