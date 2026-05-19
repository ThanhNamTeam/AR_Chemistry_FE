import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/quiz_draft_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/staff_provider.dart';

class StaffQuizTab extends StatefulWidget {
  const StaffQuizTab({super.key});

  @override
  State<StaffQuizTab> createState() => _StaffQuizTabState();
}

class _StaffQuizTabState extends State<StaffQuizTab> {
  bool _uploading = false;

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;
    final name = result.files.single.name;
    setState(() => _uploading = true);
    await context.read<StaffProvider>().simulateDocumentUpload(name);
    if (mounted) {
      setState(() => _uploading = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isVi
                ? 'Đã gửi "$name". Hệ thống đang tạo quiz (mock).'
                : 'Sent "$name". Generating quiz (mock).',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final staff = context.watch<StaffProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        PortalPrimaryButton(
          label: _uploading ? l10n.processingDocument : l10n.uploadDocument,
          icon: Icons.cloud_upload_outlined,
          loading: _uploading,
          onPressed: _uploading ? null : _pickDocument,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.uploadDocumentHint,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.quizPipelineHint,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.subtitleAccent,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 20),
        PortalSectionHeader(
          title: l10n.quizPipeline,
          actionLabel: '${staff.quizDrafts.length}',
        ),
        ...staff.quizDrafts.map((q) => _QuizCard(quiz: q, l10n: l10n)),
      ],
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizDraftModel quiz;
  final AppLocalizations l10n;

  const _QuizCard({required this.quiz, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final q = quiz;
    final statusColor = switch (q.status) {
      QuizDraftStatus.pendingReview => AppColors.amber,
      QuizDraftStatus.approved => AppColors.success,
      QuizDraftStatus.rejected => AppColors.error,
    };
    final statusLabel = switch (q.status) {
      QuizDraftStatus.pendingReview => l10n.statusPending,
      QuizDraftStatus.approved => l10n.statusApproved,
      QuizDraftStatus.rejected => l10n.statusRejected,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PortalGlassCard(
        accentBorder: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PortalBadge(text: statusLabel, color: statusColor),
                const Spacer(),
                Icon(
                  Icons.description_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    q.sourceDocument,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              q.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.topicLabel(q.topic),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.subtitleAccent,
                fontFamily: 'Inter',
              ),
            ),
            if (q.status == QuizDraftStatus.pendingReview) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .read<StaffProvider>()
                          .rejectQuiz(q.id, note: 'Needs revision'),
                      icon: Icon(Icons.close, size: 18, color: AppColors.error),
                      label: Text(l10n.reject),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withOpacity(0.45),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<StaffProvider>().approveQuiz(q.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.isVi
                                  ? 'Đã duyệt quiz (mock)'
                                  : 'Quiz approved (mock)',
                              style: const TextStyle(fontFamily: 'Inter'),
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l10n.approve),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
