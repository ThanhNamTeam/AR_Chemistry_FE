import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';

class AdminReactionsTab extends StatelessWidget {
  const AdminReactionsTab({super.key});

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
            onPressed: () => _showAddDialog(context, admin, l10n),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addReaction),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...admin.reactions.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PortalGlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.biotech_outlined,
                      color: AppColors.accentLight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['name']!,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          r['topic']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subtitleAccent,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(
    BuildContext context,
    AdminProvider admin,
    AppLocalizations l10n,
  ) {
    final nameCtrl = TextEditingController();
    final topicCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.addReaction,
          style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.isVi ? 'Phương trình' : 'Equation',
              ),
            ),
            TextField(
              controller: topicCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.isVi ? 'Chủ đề' : 'Topic',
              ),
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
            child: Text(
              l10n.isVi ? 'Lưu' : 'Save',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
