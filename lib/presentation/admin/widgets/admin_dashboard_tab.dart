import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../data/admin/transfer_bills_catalog.dart';
import '../../../domain/models/transfer_bill_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  RevenueFilterPeriod _revenuePeriod = RevenueFilterPeriod.day;

  String _vnd(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M ₫';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K ₫';
    return '${v.toStringAsFixed(0)} ₫';
  }

  List<String> _revenuePeriodLabels(AppLocalizations l10n) => [
        l10n.periodDay,
        l10n.periodMonth,
        l10n.periodYear,
      ];

  double get _chartTotal {
    final data = TransferBillsCatalog.chartData(_revenuePeriod);
    if (data.isEmpty) return 0;
    return data.fold<double>(0, (s, e) => s + e.value);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final admin = context.watch<AdminProvider>();
    final chartData = TransferBillsCatalog.chartData(
      _revenuePeriod,
      monthLabel: l10n.revenueMonthAxisLabel,
    );

    // Tổng theo ngày mới nhất có data + cả tháng 8/2026 từ mock.
    final latestDay = TransferBillsCatalog.sortedNewestFirst.isEmpty
        ? DateTime.now()
        : TransferBillsCatalog.sortedNewestFirst.first.transferredAt;
    final dayRevenue =
        TransferBillsCatalog.amountOnDate(latestDay).toDouble();
    final monthRevenue =
        TransferBillsCatalog.amountInMonth(latestDay.year, latestDay.month)
            .toDouble();

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
                value: _vnd(dayRevenue),
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PortalStatCard(
                icon: Icons.calendar_month_outlined,
                label: l10n.revenueMonth,
                value: _vnd(monthRevenue),
                color: AppColors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        PortalSectionHeader(title: l10n.revenue),
        PortalPeriodChips(
          labels: _revenuePeriodLabels(l10n),
          selectedIndex: _revenuePeriod.index,
          onSelected: (i) => setState(
            () => _revenuePeriod = RevenueFilterPeriod.values[i],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _vnd(_chartTotal),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.emphasisPositive,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.revenueChartHint,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        PortalBarChartCard(
          title: l10n.revenue,
          data: chartData,
          height: 220,
        ),
      ],
    );
  }
}
