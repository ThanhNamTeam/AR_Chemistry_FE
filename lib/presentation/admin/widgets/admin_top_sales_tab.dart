import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';

class AdminTopSalesTab extends StatelessWidget {
  const AdminTopSalesTab({super.key});

  List<String> _periodLabels(AppLocalizations l10n) => [
        l10n.periodDay,
        l10n.periodWeek,
        l10n.periodMonth,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final admin = context.watch<AdminProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        PortalSectionHeader(title: l10n.topChemicalsPurchased),
        PortalPeriodChips(
          labels: _periodLabels(l10n),
          selectedIndex: admin.period.index,
          onSelected: (i) => admin.setPeriod(StatsPeriod.values[i]),
        ),
        const SizedBox(height: 16),
        ...admin.topSales.asMap().entries.map((e) {
          final rank = e.key + 1;
          final item = e.value;
          final medalColor = rank == 1
              ? AppColors.amber
              : rank == 2
                  ? AppColors.textSecondary
                  : rank == 3
                      ? AppColors.amberDark
                      : AppColors.primary.withOpacity(0.5);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PortalGlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: medalColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: medalColor.withOpacity(0.4)),
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          color: medalColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.symbol} — ${item.name}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          item.cardId,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  PortalBadge(
                    text: l10n.purchases(item.purchases),
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
