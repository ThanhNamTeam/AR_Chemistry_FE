import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';

class AdminCardsTab extends StatefulWidget {
  const AdminCardsTab({super.key});

  @override
  State<AdminCardsTab> createState() => _AdminCardsTabState();
}

class _AdminCardsTabState extends State<AdminCardsTab> {
  String _searchText = '';

  @override
  void initState() {
    super.initState();

    final adminProvider = context.read<AdminProvider>();
    Future.microtask(() {
      adminProvider.loadChemicalCards();
    });
  }

  Future<void> _showUploadImagesSheet(BuildContext context, dynamic card) async {
    XFile? frontFile;
    XFile? backFile;
    bool isUploading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> pickFront() async {
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 95,
              );

              if (picked != null) {
                setSheetState(() => frontFile = picked);
              }
            }

            Future<void> pickBack() async {
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 95,
              );

              if (picked != null) {
                setSheetState(() => backFile = picked);
              }
            }

            Future<void> upload() async {
              if (frontFile == null || backFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng chọn đủ ảnh mặt trước và mặt sau.'),
                  ),
                );
                return;
              }

              setSheetState(() => isUploading = true);

              try {
                final frontBytes = await frontFile!.readAsBytes();
                final backBytes = await backFile!.readAsBytes();

                await context.read<AdminProvider>().uploadChemicalCardImages( // ignore: use_build_context_synchronously
                  cardId: card.id,
                  frontBytes: frontBytes,
                  frontSize: frontBytes.length,
                  backBytes: backBytes,
                  backSize: backBytes.length,
                );

                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upload ảnh thẻ thành công.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Upload thất bại: $e')),
                  );
                }
              } finally {
                setSheetState(() => isUploading = false);
              }
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Upload ảnh 2 mặt',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.displayName ?? card.cardCode ?? 'Thẻ AR',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 18),

                  _PickImageRow(
                    title: 'Ảnh mặt trước',
                    fileName: frontFile?.name,
                    onPick: pickFront,
                  ),

                  const SizedBox(height: 10),

                  _PickImageRow(
                    title: 'Ảnh mặt sau',
                    fileName: backFile?.name,
                    onPick: pickBack,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isUploading ? null : upload,
                      icon: isUploading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(isUploading ? 'Đang upload...' : 'Upload ảnh'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final cards = _applySearch(admin.chemicalCards);

    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().loadChemicalCards(force: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quản lý thẻ AR',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  context.read<AdminProvider>().loadChemicalCards(force: true);
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tải lại'),
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

          if (admin.isLoadingChemicalCards)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (cards.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  'Chưa có thẻ AR nào.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            )
          else
            ...cards.map(
                  (card) => _ChemicalCardTile(
                card: card,
                onManage: () {
                  _showCardActionSheet(context, card);
                },
              ),
            ),
        ],
      ),
    );
  }

  List<dynamic> _applySearch(List<dynamic> cards) {
    final keyword = _searchText.trim().toLowerCase();

    if (keyword.isEmpty) return cards;

    return cards.where((card) {
      final cardCode = (card.cardCode ?? '').toString().toLowerCase();
      final displayName = (card.displayName ?? '').toString().toLowerCase();
      final qrPayload = (card.qrPayload ?? '').toString().toLowerCase();
      final substanceName = (card.substanceName ?? '').toString().toLowerCase();
      final formula = (card.formula ?? '').toString().toLowerCase();

      return cardCode.contains(keyword) ||
          displayName.contains(keyword) ||
          qrPayload.contains(keyword) ||
          substanceName.contains(keyword) ||
          formula.contains(keyword);
    }).toList();
  }

  void _showCardActionSheet(BuildContext context, dynamic card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                card.displayName ?? card.cardCode ?? 'Thẻ AR',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),

              _ActionRow(
                icon: Icons.image_outlined,
                title: 'Upload / đổi ảnh 2 mặt',
                subtitle: 'Cập nhật ảnh mặt trước và mặt sau của thẻ thật.',
                onTap: () {
                  Navigator.pop(ctx);
                  _showUploadImagesSheet(context, card);
                },
              ),

              const SizedBox(height: 10),

              _ActionRow(
                icon: Icons.qr_code_2,
                title: 'Xem QR Payload',
                subtitle: card.qrPayload ?? 'Chưa có QR payload',
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),

              const SizedBox(height: 10),

              _ActionRow(
                icon: Icons.power_settings_new,
                title: card.active == true ? 'Tắt thẻ này' : 'Bật thẻ này',
                subtitle: card.active == true
                    ? 'Thẻ sẽ không hiển thị trong hệ thống.'
                    : 'Thẻ sẽ được bật lại.',
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: gọi API update active
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChemicalCardTile extends StatelessWidget {
  final dynamic card;
  final VoidCallback onManage;

  const _ChemicalCardTile({
    required this.card,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final hasFront = card.frontImageUrl != null &&
        card.frontImageUrl.toString().trim().isNotEmpty;
    final hasBack = card.backImageUrl != null &&
        card.backImageUrl.toString().trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PortalGlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardPreview(
              imageUrl: hasFront ? card.frontImageUrl : null,
              fallbackText: card.formula ?? 'AR',
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.displayName ?? card.cardCode ?? 'Thẻ AR',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      fontFamily: 'Inter',
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Code: ${card.cardCode ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'QR: ${card.qrPayload ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MiniBadge(
                        text: hasFront ? 'Có mặt trước' : 'Thiếu mặt trước',
                        color: hasFront ? AppColors.success : AppColors.error,
                      ),
                      _MiniBadge(
                        text: hasBack ? 'Có mặt sau' : 'Thiếu mặt sau',
                        color: hasBack ? AppColors.success : AppColors.error,
                      ),
                      _MiniBadge(
                        text: card.active == true ? 'Active' : 'Inactive',
                        color: card.active == true
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: onManage,
              icon: Icon(
                Icons.more_vert,
                color: AppColors.accentText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;

  const _CardPreview({
    required this.imageUrl,
    required this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 82,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? Center(
        child: Text(
          fallbackText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.accentText,
            fontWeight: FontWeight.w900,
            fontFamily: 'Inter',
          ),
        ),
      )
          : Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.textSecondary,
            ),
          );
        },
      ),
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
          hintText: 'Tìm theo mã card, tên chất, QR payload...',
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
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
        borderRadius: BorderRadius.circular(16),
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

class _PickImageRow extends StatelessWidget {
  final String title;
  final String? fileName;
  final VoidCallback onPick;

  const _PickImageRow({
    required this.title,
    required this.fileName,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return PortalGlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            Icons.image_outlined,
            color: AppColors.accentText,
          ),
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
                  fileName ?? 'Chưa chọn ảnh',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onPick,
            child: const Text('Chọn'),
          ),
        ],
      ),
    );
  }
}