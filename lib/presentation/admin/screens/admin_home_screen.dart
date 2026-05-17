import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/chemical_card_model.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../auth/providers/role_session_provider.dart';
import '../../home/providers/theme_provider.dart';
import '../providers/admin_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().initialize();
    });
  }

  Future<void> _logout() async {
    await context.read<RoleSessionProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final admin = context.watch<AdminProvider>();
    final email = context.watch<RoleSessionProvider>().email ?? 'admin';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Portal',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textCyan,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.portalProfile,
                      ),
                      icon: Icon(Icons.person_outline,
                          color: AppColors.primary),
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: Icon(Icons.logout, color: AppColors.error),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _index,
                  children: [
                    _DashboardTab(admin: admin),
                    _ChemicalsTab(admin: admin),
                    _ReactionsTab(admin: admin),
                    _TopSalesTab(admin: admin),
                    _CombosTab(admin: admin),
                  ],
                ),
              ),
              NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                backgroundColor: AppColors.cardBg.withOpacity(0.9),
                indicatorColor: AppColors.primary.withOpacity(0.2),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    label: 'Tổng quan',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.science_outlined),
                    label: 'Chất',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.biotech_outlined),
                    label: 'PTHH',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.trending_up),
                    label: 'Top',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.local_offer_outlined),
                    label: 'Combo',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final AdminProvider admin;
  const _DashboardTab({required this.admin});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            _statCard('Users', '${admin.totalUsers}', AppColors.primary),
            const SizedBox(width: 10),
            _statCard('Active today', '${admin.activeToday}', AppColors.secondary),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard('Doanh thu ngày', _vnd(admin.revenueDay), AppColors.accent),
            const SizedBox(width: 10),
            _statCard('Tháng', _vnd(admin.revenueMonth), AppColors.amber),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Doanh thu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: StatsPeriod.values.map((p) {
            final selected = admin.period == p;
            final label = switch (p) {
              StatsPeriod.day => 'Ngày',
              StatsPeriod.week => 'Tuần',
              StatsPeriod.month => 'Tháng',
            };
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => admin.setPeriod(p),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.primaryGradient : null,
                    color: selected ? null : AppColors.cardBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          selected ? Colors.white : AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          _vnd(admin.currentRevenue),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryLight,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: _RevenueChart(data: admin.revenueChartData),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _vnd(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M ₫';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K ₫';
    return '${v.toStringAsFixed(0)} ₫';
  }
}

class _RevenueChart extends StatelessWidget {
  final List<RevenuePoint> data;
  const _RevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: AppColors.primary.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[i].label,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].amount,
                  gradient: AppColors.primaryGradient,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ChemicalsTab extends StatelessWidget {
  final AdminProvider admin;
  const _ChemicalsTab({required this.admin});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _showAddChemicalDialog(context),
            icon: Icon(Icons.add, color: AppColors.primary),
            label: Text(
              'Thêm chất mới',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ),
        ...admin.catalogCards.map((c) => _chemicalRow(c)),
      ],
    );
  }

  Widget _chemicalRow(ChemicalCardModel c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: c.color.withOpacity(0.2),
            child: Text(c.symbol,
                style: TextStyle(
                    color: c.color, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter')),
                Text('${c.price} KP · Shop',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          Icon(Icons.edit_outlined,
              color: AppColors.textSecondary, size: 18),
        ],
      ),
    );
  }

  void _showAddChemicalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('Thêm chất (mock)',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Form chi tiết sẽ kết nối BE sau.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Đóng', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _ReactionsTab extends StatelessWidget {
  final AdminProvider admin;
  const _ReactionsTab({required this.admin});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _showAddReaction(context, admin),
            icon: Icon(Icons.add, color: AppColors.primary),
            label: Text('Thêm phản ứng',
                style: TextStyle(color: AppColors.primaryLight)),
          ),
        ),
        ...admin.reactions.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['name']!,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter')),
                  Text(r['topic']!,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textCyan,
                          fontFamily: 'Inter')),
                ],
              ),
            )),
      ],
    );
  }

  void _showAddReaction(BuildContext context, AdminProvider admin) {
    final nameCtrl = TextEditingController();
    final topicCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('Phản ứng mới',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Phương trình'),
            ),
            TextField(
              controller: topicCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Chủ đề'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                admin.addReaction(nameCtrl.text, topicCtrl.text);
              }
              Navigator.pop(ctx);
            },
            child: Text('Lưu', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _TopSalesTab extends StatelessWidget {
  final AdminProvider admin;
  const _TopSalesTab({required this.admin});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Top chất được mua',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: StatsPeriod.values.map((p) {
            final selected = admin.period == p;
            final label = switch (p) {
              StatsPeriod.day => 'Ngày',
              StatsPeriod.week => 'Tuần',
              StatsPeriod.month => 'Tháng',
            };
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => admin.setPeriod(p),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.cardBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? AppColors.primaryLight
                              : AppColors.textSecondary)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ...admin.topSales.asMap().entries.map((e) {
          final rank = e.key + 1;
          final item = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text('#$rank',
                    style: TextStyle(
                        color: AppColors.amber,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${item.symbol} — ${item.name}',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter'),
                  ),
                ),
                Text(
                  '${item.purchases} lượt',
                  style: TextStyle(
                      color: AppColors.secondaryLight,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _CombosTab extends StatelessWidget {
  final AdminProvider admin;
  const _CombosTab({required this.admin});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tạo combo sale — mock UI'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: Icon(Icons.add, color: AppColors.primary),
            label: Text('Tạo combo sale',
                style: TextStyle(color: AppColors.primaryLight)),
          ),
        ),
        ...admin.bundles.map((b) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.name,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter')),
                  Text(
                    '${b.cardIds.length} thẻ · ${b.originalPrice} KP',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'IDs: ${b.cardIds.join(", ")}',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textCyan,
                        fontFamily: 'Inter'),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
