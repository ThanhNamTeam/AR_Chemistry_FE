import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../domain/models/student_quiz_attempt_answer_detail_model.dart';
import '../../../domain/models/student_quiz_attempt_detail_model.dart';
import '../../../domain/models/student_quiz_attempt_history_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../../quiz/providers/student_quiz_provider.dart';
import '../widgets/experiment_screen_header.dart';

class ReactionExperimentHistoryScreen extends StatefulWidget {
  const ReactionExperimentHistoryScreen({
    super.key,
  });

  @override
  State<ReactionExperimentHistoryScreen> createState() =>
      _ReactionExperimentHistoryScreenState();
}

class _ReactionExperimentHistoryScreenState
    extends State<ReactionExperimentHistoryScreen> {
  bool _initialized = false;

  String? _reactionId;
  String? _reactionName;

  String? _selectedAttemptCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;

    _readArguments();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  void _readArguments() {
    final arguments =
        ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      _reactionId =
          arguments['reactionId']?.toString();

      _reactionName =
          arguments['reactionName']?.toString();

      return;
    }

    // Hỗ trợ route cũ trong thời gian chuyển đổi.
    if (arguments is String) {
      _reactionId = arguments;
    }
  }

  Future<void> _loadHistory() async {
    final reactionId = _reactionId;

    if (reactionId == null ||
        reactionId.isEmpty) {
      return;
    }

    await context
        .read<StudentQuizProvider>()
        .loadAttemptHistory(
      reactionId: reactionId,
      page: 0,
      size: 20,
    );
  }

  Future<void> _openAttemptDetail(
      StudentQuizAttemptHistoryModel attempt,
      ) async {
    setState(() {
      _selectedAttemptCode =
          attempt.attemptCode;
    });

    final provider =
    context.read<StudentQuizProvider>();

    await provider.loadAttemptDetail(
      attempt.attemptCode,
    );

    if (!mounted) {
      return;
    }

    if (provider.attemptDetailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.attemptDetailError!,
          ),
        ),
      );
    }
  }

  void _closeAttemptDetail() {
    setState(() {
      _selectedAttemptCode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n =
    AppLocalizations.of(context);

    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();

    final provider =
    context.watch<StudentQuizProvider>();

    final selectedDetail =
        provider.attemptDetail;

    final showingDetail =
        _selectedAttemptCode != null;

    return Scaffold(
      backgroundColor:
      AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient:
          AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              ExperimentScreenHeader(
                title: showingDetail
                    ? 'Chi tiết lần làm'
                    : l10n.viewAttemptHistory,
                onBack: showingDetail
                    ? _closeAttemptDetail
                    : () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: showingDetail
                    ? _buildAttemptDetail(
                  provider: provider,
                  detail: selectedDetail,
                  l10n: l10n,
                )
                    : _buildHistoryList(
                  provider: provider,
                  l10n: l10n,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList({
    required StudentQuizProvider provider,
    required AppLocalizations l10n,
  }) {
    if (_reactionId == null ||
        _reactionId!.isEmpty) {
      return _MessageView(
        icon: Icons.warning_amber_rounded,
        message:
        'Không tìm thấy mã phản ứng.',
      );
    }

    if (provider.loadingAttemptHistory &&
        provider.attemptHistory.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.attemptHistoryError != null &&
        provider.attemptHistory.isEmpty) {
      return _ErrorView(
        message:
        provider.attemptHistoryError!,
        onRetry: _loadHistory,
      );
    }

    if (provider.attemptHistory.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 150),
            Center(
              child: Text(
                l10n.noHistoryYet,
                style: TextStyle(
                  color:
                  AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24,
        ),
        children: [
          if (_reactionName != null &&
              _reactionName!
                  .trim()
                  .isNotEmpty) ...[
            Text(
              _reactionName!,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
                color:
                AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...provider.attemptHistory.map(
                (attempt) {
              return _AttemptHistoryCard(
                attempt: attempt,
                loading:
                provider.loadingAttemptDetail &&
                    _selectedAttemptCode ==
                        attempt.attemptCode,
                onTap: () {
                  _openAttemptDetail(attempt);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptDetail({
    required StudentQuizProvider provider,
    required StudentQuizAttemptDetailModel?
    detail,
    required AppLocalizations l10n,
  }) {
    if (provider.loadingAttemptDetail &&
        detail == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.attemptDetailError != null &&
        detail == null) {
      return _ErrorView(
        message:
        provider.attemptDetailError!,
        onRetry: () async {
          final attemptCode =
              _selectedAttemptCode;

          if (attemptCode == null) {
            return;
          }

          await provider.loadAttemptDetail(
            attemptCode,
          );
        },
      );
    }

    if (detail == null) {
      return const _MessageView(
        icon: Icons.receipt_long_outlined,
        message:
        'Không tìm thấy chi tiết lần làm.',
      );
    }

    final wrongCount =
        detail.totalQuestions -
            detail.correctCount;

    final safeWrongCount =
    wrongCount < 0 ? 0 : wrongCount;

    final answers = [...detail.answers]
      ..sort(
            (a, b) => a.questionOrder
            .compareTo(b.questionOrder),
      );

    return ListView(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        24,
      ),
      children: [
        Text(
          detail.reactionName.isNotEmpty
              ? detail.reactionName
              : _reactionName ??
              detail.quizTitle,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),

        if (detail.equation.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            detail.equation,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
              AppColors.subtitleAccent,
              fontFamily: 'Inter',
            ),
          ),
        ],

        const SizedBox(height: 14),

        _ScoreSummaryCard(
          score: detail.score,
          totalQuestions:
          detail.totalQuestions,
          correctCount:
          detail.correctCount,
          wrongCount: safeWrongCount,
          status: detail.status,
          submittedAt:
          detail.submittedAt,
        ),

        const SizedBox(height: 20),

        Text(
          'Chi tiết câu trả lời',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),

        const SizedBox(height: 12),

        if (answers.isEmpty)
          Text(
            'Không có dữ liệu câu trả lời.',
            style: TextStyle(
              color:
              AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          )
        else
          ...answers.map(
                (answer) =>
                _HistoryQuestionCard(
                  result: answer,
                  l10n: l10n,
                ),
          ),
      ],
    );
  }
}

class _AttemptHistoryCard
    extends StatelessWidget {
  final StudentQuizAttemptHistoryModel attempt;
  final bool loading;
  final VoidCallback onTap;

  const _AttemptHistoryCard({
    required this.attempt,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final wrongCount =
        attempt.totalQuestions -
            attempt.correctCount;

    return Container(
      margin:
      const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary
              .withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Padding(
          padding:
          const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      attempt.quizTitle
                          .isNotEmpty
                          ? attempt.quizTitle
                          : attempt.reactionName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w700,
                        color: AppColors
                            .textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  if (loading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      color:
                      AppColors.primary,
                    ),
                ],
              ),

              if (attempt.equation.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  attempt.equation,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors
                        .subtitleAccent,
                    fontFamily: 'Inter',
                  ),
                ),
              ],

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SmallBadge(
                    icon:
                    Icons.star_outline,
                    text:
                    '${attempt.score}/${attempt.totalQuestions}',
                    color:
                    AppColors.primary,
                  ),
                  _SmallBadge(
                    icon: Icons
                        .check_circle_outline,
                    text:
                    '${attempt.correctCount} đúng',
                    color:
                    AppColors.success,
                  ),
                  _SmallBadge(
                    icon:
                    Icons.cancel_outlined,
                    text:
                    '${wrongCount < 0 ? 0 : wrongCount} sai',
                    color:
                    AppColors.error,
                  ),
                  _SmallBadge(
                    icon:
                    Icons.info_outline,
                    text: attempt.status,
                    color:
                    AppColors.primary,
                  ),
                ],
              ),

              if (attempt.submittedAt !=
                  null) ...[
                const SizedBox(height: 10),
                Text(
                  'Nộp lúc: ${_formatDateTime(attempt.submittedAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors
                        .textSecondary,
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

class _ScoreSummaryCard
    extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final String status;
  final DateTime? submittedAt;

  const _ScoreSummaryCard({
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.status,
    required this.submittedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary
              .withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            '$score/$totalQuestions',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallBadge(
                icon:
                Icons.check_circle_outline,
                text:
                '$correctCount đúng',
                color:
                AppColors.success,
              ),
              _SmallBadge(
                icon:
                Icons.cancel_outlined,
                text: '$wrongCount sai',
                color:
                AppColors.error,
              ),
              _SmallBadge(
                icon: Icons.info_outline,
                text: status,
                color:
                AppColors.primary,
              ),
            ],
          ),
          if (submittedAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Nộp lúc: ${_formatDateTime(submittedAt!)}',
              style: TextStyle(
                fontSize: 12,
                color:
                AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryQuestionCard
    extends StatelessWidget {
  final StudentQuizAttemptAnswerDetailModel
  result;

  final AppLocalizations l10n;

  const _HistoryQuestionCard({
    required this.result,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = result.correct
        ? AppColors.success
        : AppColors.error;

    final studentAnswer =
    result.studentAnswer?.trim();

    final correctAnswer =
    result.correctAnswer?.trim();

    final explanation =
    result.explanation?.trim();

    return Container(
      margin:
      const EdgeInsets.only(bottom: 12),
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color:
          resultColor.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Câu ${result.questionOrder}: '
                      '${result.questionText}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                result.correct
                    ? Icons.check_circle
                    : Icons.cancel,
                size: 20,
                color: resultColor,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            l10n.yourAnswer(
              studentAnswer == null ||
                  studentAnswer.isEmpty
                  ? 'Chưa trả lời'
                  : studentAnswer,
            ),
            style: TextStyle(
              fontSize: 13,
              color: resultColor,
              fontFamily: 'Inter',
            ),
          ),

          if (!result.correct &&
              correctAnswer != null &&
              correctAnswer.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l10n.correctAnswerLabel(
                correctAnswer,
              ),
              style: TextStyle(
                fontSize: 13,
                color:
                AppColors.success,
                fontFamily: 'Inter',
              ),
            ),
          ],

          if (explanation != null &&
              explanation.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              '${l10n.explanationLabel}: '
                  '$explanation',
              style: TextStyle(
                fontSize: 12,
                color:
                AppColors.textSecondary,
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

class _SmallBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SmallBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
              FontWeight.w600,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 44,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon:
              const Icon(Icons.refresh),
              label:
              const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageView({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 44,
              color:
              AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(
    DateTime dateTime,
    ) {
  final local = dateTime.toLocal();

  String twoDigits(int value) {
    return value
        .toString()
        .padLeft(2, '0');
  }

  return '${twoDigits(local.hour)}:'
      '${twoDigits(local.minute)} '
      '${twoDigits(local.day)}/'
      '${twoDigits(local.month)}/'
      '${local.year}';
}