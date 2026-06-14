import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/activation_code_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';

class AdminActivationCodesTab extends StatefulWidget {
  const AdminActivationCodesTab({super.key});

  @override
  State<AdminActivationCodesTab> createState() =>
      _AdminActivationCodesTabState();
}

class _AdminActivationCodesTabState extends State<AdminActivationCodesTab> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadActivationCodes();
    });

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;

      if (position.pixels >= position.maxScrollExtent - 240) {
        context.read<AdminProvider>().loadMoreActivationCodes();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return RefreshIndicator(
      onRefresh: () =>
          context.read<AdminProvider>().loadActivationCodes(force: true),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text(
            'Quản lý mã kích hoạt',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),

          PortalGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm chính xác theo activation code...',
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
                suffixIcon: _searchController.text.trim().isEmpty
                    ? null
                    : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                    context
                        .read<AdminProvider>()
                        .loadActivationCodes(force: true);
                  },
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {});
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 450), () {
                  final keyword = value.trim();

                  if (keyword.isEmpty) {
                    context
                        .read<AdminProvider>()
                        .loadActivationCodes(force: true);
                  } else {
                    context
                        .read<AdminProvider>()
                        .searchActivationCodeByCode(keyword);
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          _ActivationCodeFilterBar(
            selected: admin.activationCodeStatusFilter,
            onChanged: (value) {
              _searchController.clear();
              setState(() {});
              context
                  .read<AdminProvider>()
                  .changeActivationCodeStatusFilter(value);
            },
          ),

          const SizedBox(height: 12),

          if (admin.isLoadingActivationCodes)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (admin.activationCodes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  'Chưa có mã kích hoạt nào.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            )
          else ...[
              ...admin.activationCodes.map(
                    (code) => _ActivationCodeTile(
                  code: code,
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: code.code));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã copy mã')),
                    );
                  },
                      onChangeStatus: (status) async {
                        try {
                          await context
                              .read<AdminProvider>()
                              .updateActivationCodeStatus(code.id, status);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã đổi trạng thái thành $status')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Không thể đổi trạng thái: $e')),
                          );
                        }
                      },
                ),
              ),

              if (admin.isLoadingMoreActivationCodes)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!admin.hasMoreActivationCodes &&
                  admin.activationCodes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: Text(
                      'Đã tải hết danh sách mã',
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
}

class _ActivationCodeFilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _ActivationCodeFilterBar({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('ALL', 'Tất cả'),
      ('UNUSED', 'Chưa dùng'),
      ('USED', 'Đã dùng'),
      ('EXPIRED', 'Hết hạn'),
      ('LOCKED', 'Đã khóa'),
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

class _ActivationCodeTile extends StatelessWidget {
  final ActivationCodeModel code;
  final VoidCallback onCopy;
  final ValueChanged<String> onChangeStatus;

  const _ActivationCodeTile({
    required this.code,
    required this.onCopy,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(code.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PortalGlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vpn_key_outlined,
                  color: AppColors.accentText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    code.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onCopy,
                  icon: Icon(
                    Icons.copy_outlined,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MiniBadge(
                  text: code.status,
                  color: statusColor,
                ),
                _MiniBadge(
                  text: code.active ? 'Active' : 'Inactive',
                  color: code.active ? AppColors.success : AppColors.error,
                ),
                if (code.kitCode != null)
                  _MiniBadge(
                    text: code.kitCode!,
                    color: AppColors.primary,
                  ),
              ],
            ),

            if (code.kitName != null && code.kitName!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  code.kitName!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ),

            if (code.usedByUserId != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Used by: ${code.usedByUserId}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ),

            if (code.expiresAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Hết hạn: ${_formatDateTime(code.expiresAt!)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ),

            if (code.note != null && code.note!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  code.note!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ),

            const SizedBox(height: 10),

            if (code.status == 'USED')
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Đã được sử dụng',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    fontSize: 12,
                  ),
                ),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  color: AppColors.cardBg,
                  onSelected: onChangeStatus,
                  itemBuilder: (context) => _buildStatusMenuItems(code.status),
                  child: Text(
                    'Đổi trạng thái',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildStatusMenuItems(String currentStatus) {
    final items = <PopupMenuEntry<String>>[];

    void addItem(String status, String label) {
      if (currentStatus == status) return;

      items.add(
        PopupMenuItem(
          value: status,
          child: Text(label),
        ),
      );
    }

    // Không bao giờ cho admin set USED.
    // USED chỉ được set bởi flow user redeem code.
    addItem('UNUSED', 'Đặt thành UNUSED');
    addItem('EXPIRED', 'Đặt thành EXPIRED');
    addItem('LOCKED', 'Đặt thành LOCKED');

    if (items.isEmpty) {
      items.add(
        const PopupMenuItem(
          enabled: false,
          child: Text('Không có trạng thái khả dụng'),
        ),
      );
    }

    return items;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'UNUSED':
        return AppColors.success;
      case 'USED':
        return AppColors.primary;
      case 'EXPIRED':
        return AppColors.error;
      case 'LOCKED':
        return AppColors.navMuted;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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