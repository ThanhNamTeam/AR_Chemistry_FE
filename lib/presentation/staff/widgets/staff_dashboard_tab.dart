import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/staff_provider.dart';

class StaffDashboardTab extends StatelessWidget {
  final VoidCallback onOpenFeedback;
  final VoidCallback onOpenQuiz;

  const StaffDashboardTab({
    super.key,
    required this.onOpenFeedback,
    required this.onOpenQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final staff = context.watch<StaffProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: PortalStatCard(
                icon: Icons.feedback_outlined,
                label: l10n.feedback,
                value: '${staff.totalFeedbacks}',
                color: AppColors.amber,
                trend: '${staff.awaitingResponseCount} ${l10n.awaitingResponse}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PortalStatCard(
                icon: Icons.quiz_outlined,
                label: l10n.pendingQuizzes,
                value: '${staff.pendingQuizzes.length}',
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: PortalStatCard(
                icon: Icons.mark_chat_read_outlined,
                label: l10n.responded,
                value: '${staff.respondedCount}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PortalStatCard(
                icon: Icons.check_circle_outline,
                label: l10n.approvedQuizzes,
                value: '${staff.approvedQuizzesCount}',
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        PortalBarChartCard(
          title: l10n.feedbackTrend,
          data: staff.feedbackTrendWeek,
        ),
        const SizedBox(height: 20),
        PortalSectionHeader(title: l10n.quickActions),
        PortalGlassCard(
          child: Column(
            children: [
              _QuickActionTile(
                icon: Icons.inbox_outlined,
                label: l10n.goToFeedback,
                subtitle:
                    '${staff.awaitingResponseCount} ${l10n.awaitingResponse}',
                color: AppColors.amber,
                onTap: onOpenFeedback,
              ),
              Divider(
                color: AppColors.primary.withOpacity(0.12),
                height: 20,
              ),
              _QuickActionTile(
                icon: Icons.fact_check_outlined,
                label: l10n.goToQuiz,
                subtitle:
                    '${staff.pendingQuizzes.length} ${l10n.pendingQuizzes}',
                color: AppColors.secondary,
                onTap: onOpenQuiz,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PortalSectionHeader(
          title: l10n.recentFeedback,
          actionLabel: l10n.goToFeedback,
          onAction: onOpenFeedback,
        ),
        if (staff.recentFeedbacks.isEmpty)
          PortalEmptyState(
            icon: Icons.inbox_outlined,
            title: l10n.noFeedbackYet,
            subtitle: l10n.noFeedbackSubtitle,
          )
        else
          ...staff.recentFeedbacks.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PortalGlassCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            f.staffResponse != null
                                ? l10n.respondedBadge
                                : l10n.awaitingResponse,
                            style: TextStyle(
                              fontSize: 11,
                              color: f.staffResponse != null
                                  ? AppColors.success
                                  : AppColors.amber,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
