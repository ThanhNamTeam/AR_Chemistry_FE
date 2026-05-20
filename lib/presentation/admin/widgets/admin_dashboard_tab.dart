import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  String _vnd(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M ₫';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K ₫';
    return '${v.toStringAsFixed(0)} ₫';
  }

  List<String> _periodLabels(AppLocalizations l10n) => [
        l10n.periodDay,
        l10n.periodWeek,
        l10n.periodMonth,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final admin = context.watch<AdminProvider>();
    final periodIndex = admin.period.index;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: PortalStatCard(
                icon: Icons.people_outline,
                label: l10n.users,
                value: '${admin.totalUsers}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PortalStatCard(
                icon: Icons.online_prediction_outlined,
                label: l10n.activeToday,
                value: '${admin.activeToday}',
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
                icon: Icons.payments_outlined,
                label: l10n.revenueDay,
                value: _vnd(admin.revenueDay),
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PortalStatCard(
                icon: Icons.calendar_month_outlined,
                label: l10n.revenueMonth,
                value: _vnd(admin.revenueMonth),
                color: AppColors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        PortalSectionHeader(title: l10n.revenue),
        PortalPeriodChips(
          labels: _periodLabels(l10n),
          selectedIndex: periodIndex,
          onSelected: (i) => admin.setPeriod(StatsPeriod.values[i]),
        ),
        const SizedBox(height: 12),
        Text(
          _vnd(admin.currentRevenue),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.emphasisPositive,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        PortalBarChartCard(
          title: l10n.revenue,
          data: admin.revenueChartData
              .map((e) => (label: e.label, value: e.amount))
              .toList(),
          height: 220,
        ),
      ],
    );
  }
}
