import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/feedback_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/staff_provider.dart';
import '../screens/staff_feedback_detail_screen.dart';

class StaffFeedbackTab extends StatelessWidget {
  const StaffFeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final staff = context.watch<StaffProvider>();

    if (staff.feedbacks.isEmpty) {
      return PortalEmptyState(
        icon: Icons.inbox_outlined,
        title: l10n.noFeedbackYet,
        subtitle: l10n.noFeedbackSubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: staff.feedbacks.length,
      itemBuilder: (context, i) {
        final f = staff.feedbacks[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _FeedbackCard(feedback: f, l10n: l10n),
        );
      },
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final StaffFeedbackItem feedback;
  final AppLocalizations l10n;

  const _FeedbackCard({required this.feedback, required this.l10n});

  Color _typeColor(FeedbackType type) => switch (type) {
    FeedbackType.bug => AppColors.error,
    FeedbackType.uiUx => AppColors.amber,
    FeedbackType.featureRequest => AppColors.secondary,
    FeedbackType.performance => throw UnimplementedError(),
    FeedbackType.contentError => throw UnimplementedError(),
    FeedbackType.question => throw UnimplementedError(),
    FeedbackType.other => throw UnimplementedError(),
  };

  @override
  Widget build(BuildContext context) {
    final f = feedback;
    final hasResponse = f.staffResponse != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StaffFeedbackDetailScreen(feedbackId: f.id),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: PortalGlassCard(
          padding: const EdgeInsets.all(16),
          accentBorder: _typeColor(f.type),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PortalBadge(text: f.type.label, color: _typeColor(f.type)),
                  const Spacer(),
                  if (hasResponse)
                    PortalBadge(
                      text: l10n.respondedBadge,
                      color: AppColors.success,
                    )
                  else
                    PortalBadge(
                      text: l10n.awaitingResponse,
                      color: AppColors.amber,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                f.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                f.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      f.anonymous
                          ? l10n.anonymous
                          : '${f.reporterName ?? "User"} · ${f.reporterEmail ?? ""}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.subtitleAccent,
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
