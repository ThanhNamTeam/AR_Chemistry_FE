import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/chemical_substance_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';
import 'admin_create_substance_screen.dart';

class AdminChemicalsTab extends StatefulWidget {
  const AdminChemicalsTab({super.key});

  @override
  State<AdminChemicalsTab> createState() => _AdminChemicalsTabState();
}

class _AdminChemicalsTabState extends State<AdminChemicalsTab> {
  String _searchText = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;

      if (position.pixels >= position.maxScrollExtent - 240) {
        context.read<AdminProvider>().loadMoreSubstances();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final admin = context.watch<AdminProvider>();

    final substances = _applySearch(admin.substances);

    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().loadSubstances(force: true),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.isVi ? 'Quản lý chất' : 'Chemical substances',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () async {
                  final created = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminCreateSubstanceScreen(),
                    ),
                  );

                  if (created == true && context.mounted) {
                    context.read<AdminProvider>().loadSubstances(force: true);
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addChemical),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _SearchBox(
            value: _searchText,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),

          const SizedBox(height: 12),

          _FilterBar(
            selected: admin.substanceFilter,
            onChanged: (value) {
              context.read<AdminProvider>().changeSubstanceFilter(value);
            },
          ),

          const SizedBox(height: 12),

          if (admin.isLoadingSubstances)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (substances.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  l10n.isVi ? 'Chưa có chất nào.' : 'No substances found.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            )
          else ...[
              ...substances.map(
                    (substance) => _ChemicalTile(
                  substance: substance,
                  onEdit: () => _showEditDialog(context, substance, l10n),
                  onToggleActive: () {
                    context.read<AdminProvider>().updateSubstanceActive(
                      substance.id,
                      !substance.active,
                    );
                  },
                  onToggleFullKit: () {
                    context.read<AdminProvider>().updateSubstanceIncludedInFullKit(
                      substance.id,
                      !substance.includedInFullKit,
                    );
                  },
                ),
              ),

              if (admin.isLoadingMoreSubstances)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!admin.hasMoreSubstances && substances.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: Text(
                      l10n.isVi ? 'Đã tải hết danh sách chất' : 'All substances loaded',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
        ],
      ),
    );
  }

  List<ChemicalSubstanceModel> _applySearch(
      List<ChemicalSubstanceModel> substances,
      ) {
    final keyword = _searchText.trim().toLowerCase();

    if (keyword.isEmpty) {
      return substances;
    }

    return substances.where((e) {
      final formula = e.formula.toLowerCase();
      final name = e.name.toLowerCase();
      final vietnameseName = e.vietnameseName?.toLowerCase() ?? '';
      final type = e.type.toLowerCase();
      final group = e.chemicalGroup.toLowerCase();
      final state = e.state.toLowerCase();

      return formula.contains(keyword) ||
          name.contains(keyword) ||
          vietnameseName.contains(keyword) ||
          type.contains(keyword) ||
          group.contains(keyword) ||
          state.contains(keyword);
    }).toList();
  }

  void _showAddDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.addChemical,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        content: Text(
          l10n.isVi
              ? 'Form thêm chất sẽ làm sau. Trước mắt data đang seed từ backend.'
              : 'Create form will be added later. For now data is seeded from backend.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.isVi ? 'Đóng' : 'Close',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context,
      ChemicalSubstanceModel substance,
      AppLocalizations l10n,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${substance.formula} - ${substance.displayName}',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),

              _ActionRow(
                icon: Icons.power_settings_new,
                title: substance.active
                    ? (l10n.isVi ? 'Tắt chất này' : 'Deactivate substance')
                    : (l10n.isVi ? 'Bật chất này' : 'Activate substance'),
                subtitle: substance.active
                    ? (l10n.isVi
                    ? 'Chất sẽ không được dùng trong hệ thống.'
                    : 'This substance will be disabled.')
                    : (l10n.isVi
                    ? 'Chất sẽ được dùng lại trong hệ thống.'
                    : 'This substance will be enabled again.'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<AdminProvider>().updateSubstanceActive(
                    substance.id,
                    !substance.active,
                  );
                },
              ),

              const SizedBox(height: 10),

              _ActionRow(
                icon: Icons.inventory_2_outlined,
                title: substance.includedInFullKit
                    ? (l10n.isVi
                    ? 'Bỏ khỏi Full Kit'
                    : 'Remove from Full Kit')
                    : (l10n.isVi ? 'Thêm vào Full Kit' : 'Add to Full Kit'),
                subtitle: substance.includedInFullKit
                    ? (l10n.isVi
                    ? 'Chất sẽ không còn nằm trong hộp kit.'
                    : 'This substance will be removed from kit.')
                    : (l10n.isVi
                    ? 'Chất sẽ được đánh dấu nằm trong hộp kit.'
                    : 'This substance will be marked as kit item.'),
                onTap: () {
                  Navigator.pop(ctx);
                  context
                      .read<AdminProvider>()
                      .updateSubstanceIncludedInFullKit(
                    substance.id,
                    !substance.includedInFullKit,
                  );
                },
              ),

              const SizedBox(height: 10),

              _ActionRow(
                icon: Icons.qr_code_2,
                title: substance.hasCard
                    ? (l10n.isVi ? 'Xem QR/Card' : 'View QR/Card')
                    : (l10n.isVi ? 'Tạo QR/Card' : 'Create QR/Card'),
                subtitle: l10n.isVi
                    ? 'Phần này mình làm sau khi xong màn chất.'
                    : 'This will be implemented after the substance screen.',
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchBox extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchBox({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _SearchBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PortalGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm theo công thức, tên chất, nhóm chất...',
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.accentText,
            size: 20,
          ),
          suffixIcon: widget.value.trim().isEmpty
              ? null
              : IconButton(
            onPressed: () {
              _controller.clear();
              widget.onChanged('');
            },
            icon: Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterBar({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('ALL', 'Tất cả'),
      ('FULL_KIT', 'Trong kit'),
      ('NOT_FULL_KIT', 'Ngoài kit'),
      ('ELEMENT', 'Nguyên tố'),
      ('COMPOUND', 'Hợp chất'),
      ('INACTIVE', 'Đã tắt'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((item) {
          final isSelected = selected == item.$1;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(
                item.$2,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.cardBg,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.cardBorder.withOpacity(0.4),
              ),
              onSelected: (_) => onChanged(item.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChemicalTile extends StatelessWidget {
  final ChemicalSubstanceModel substance;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleFullKit;

  const _ChemicalTile({
    required this.substance,
    required this.onEdit,
    required this.onToggleActive,
    required this.onToggleFullKit,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.substanceStateColor(substance.state);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PortalGlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.substanceStateSurface(substance.state),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.substanceStateBorder(substance.state),
                ),
              ),
              child: Center(
                child: Text(
                  substance.formula,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: substance.formula.length <= 3 ? 16 : 13,
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
                    substance.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${substance.type} · ${substance.chemicalGroup} · ${substance.state}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MiniBadge(
                        text: substance.includedInFullKit
                            ? 'Full Kit'
                            : 'Ngoài kit',
                        color: substance.includedInFullKit
                            ? AppColors.primary
                            : AppColors.navMuted,
                      ),
                      _MiniBadge(
                        text: substance.active ? 'Active' : 'Inactive',
                        color: substance.active
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      _MiniBadge(
                        text: substance.hasCard ? 'Có QR' : 'Chưa QR',
                        color: substance.hasCard
                            ? AppColors.accentText
                            : AppColors.navMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.accentText,
              ),
              color: AppColors.cardBg,
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'active') {
                  onToggleActive();
                } else if (value == 'kit') {
                  onToggleFullKit();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Quản lý'),
                ),
                PopupMenuItem(
                  value: 'active',
                  child: Text(substance.active ? 'Tắt active' : 'Bật active'),
                ),
                PopupMenuItem(
                  value: 'kit',
                  child: Text(
                    substance.includedInFullKit
                        ? 'Bỏ khỏi Full Kit'
                        : 'Thêm vào Full Kit',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PortalGlassCard(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentText),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}