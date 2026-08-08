import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';
import 'admin_create_reaction_page.dart';

class AdminReactionsTab extends StatefulWidget {
  const AdminReactionsTab({super.key});

  @override
  State<AdminReactionsTab> createState() => _AdminReactionsTabState();
}

class _AdminReactionsTabState extends State<AdminReactionsTab> {
  bool? _activeFilter;

  @override
  void initState() {
    super.initState();

    final adminProvider = context.read<AdminProvider>();
    Future.microtask(() {
      adminProvider.loadReactionsForAdmin(
          active: _activeFilter);
    });
  }


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
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminCreateReactionPage(),
                ),
              );

              if (created == true && context.mounted) {
                unawaited(context.read<AdminProvider>().loadReactionsForAdmin(
                  active: _activeFilter,
                  force: true,
                ));
              }
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addReaction),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            _FilterChip(
              label: l10n.isVi ? 'Tất cả' : 'All',
              selected: _activeFilter == null,
              onTap: () => _changeFilter(context, null),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: l10n.isVi ? 'Đang bật' : 'Active',
              selected: _activeFilter == true,
              onTap: () => _changeFilter(context, true),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: l10n.isVi ? 'Đã tắt' : 'Inactive',
              selected: _activeFilter == false,
              onTap: () => _changeFilter(context, false),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (admin.isLoadingReactions)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else
          if (admin.reactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l10n.isVi ? 'Chưa có phản ứng nào' : 'No reactions found',
                  style: TextStyle(
                    color: AppColors.subtitleAccent,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            )
          else
            ...admin.reactions.map(
                  (r) {
                final bool active = r.active;
                final bool updating = admin.isUpdatingReactionStatus(r.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PortalGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
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
                                r.equation,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                r.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.subtitleAccent,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              if (r.reactionType != null &&
                                  r.reactionType!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  r.reactionType!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.subtitleAccent.withValues(alpha: 
                                        0.8),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              active
                                  ? (l10n.isVi ? 'Bật' : 'Active')
                                  : (l10n.isVi ? 'Tắt' : 'Inactive'),
                              style: TextStyle(
                                fontSize: 11,
                                color: active ? Colors.greenAccent : Colors.redAccent,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                            updating
                                ? const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                                : Switch(
                              value: active,
                              activeThumbColor: AppColors.primary,
                              onChanged: (value) async {
                                try {
                                  await context.read<AdminProvider>().updateReactionActive(
                                    id: r.id,
                                    active: value,
                                  );

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        value
                                            ? (l10n.isVi
                                            ? 'Đã bật phản ứng'
                                            : 'Reaction activated')
                                            : (l10n.isVi
                                            ? 'Đã tắt phản ứng'
                                            : 'Reaction deactivated'),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceFirst('Exception: ', ''),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }

  void _changeFilter(BuildContext context, bool? active) {
    setState(() {
      _activeFilter = active;
    });

    context.read<AdminProvider>().loadReactionsForAdmin(active: active);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.22)
              : AppColors.cardBg.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.accent.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.subtitleAccent,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}