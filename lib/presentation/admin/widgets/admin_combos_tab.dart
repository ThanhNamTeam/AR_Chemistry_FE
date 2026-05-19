import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';

class AdminCombosTab extends StatelessWidget {
  const AdminCombosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final admin = context.watch<AdminProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.isVi
                        ? 'Tạo combo sale — mock UI'
                        : 'Create combo sale — mock UI',
                    style: const TextStyle(fontFamily: 'Inter'),
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.local_offer_outlined, size: 18),
            label: Text(l10n.createCombo),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.amber,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...admin.bundles.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PortalGlassCard(
              accentBorder: AppColors.amber,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_offer, color: AppColors.amber, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          b.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${b.cardIds.length} ${l10n.isVi ? "thẻ" : "cards"} · ${b.originalPrice} KP',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: b.cardIds
                        .map(
                          (id) => PortalBadge(
                            text: id,
                            color: AppColors.primary,
                          ),
                        )
                        .toList(),
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
