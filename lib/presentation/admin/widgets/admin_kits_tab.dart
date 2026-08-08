import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/models/request/create_kit_request.dart';
import '../../../core/models/request/generate_activation_codes_request.dart';
import '../../../domain/models/activation_code_model.dart';
import '../../../domain/models/kit_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';
import 'admin_activation_codes_tab.dart';

class AdminKitsTab extends StatefulWidget {
  const AdminKitsTab({super.key});

  @override
  State<AdminKitsTab> createState() => _AdminKitsTabState();
}

class _AdminKitsTabState extends State<AdminKitsTab> {
  String _section = 'KITS';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadKits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: _KitSectionSwitcher(
            selected: _section,
            onChanged: (value) {
              setState(() {
                _section = value;
              });

              if (value == 'KITS') {
                context.read<AdminProvider>().loadKits();
              } else {
                context.read<AdminProvider>().loadActivationCodes();
              }
            },
          ),
        ),

        Expanded(
          child: _section == 'KITS'
              ? const _KitsManagementSection()
              : const AdminActivationCodesTab(),
        ),
      ],
    );
  }
}

class _KitsManagementSection extends StatelessWidget {
  const _KitsManagementSection();

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().loadKits(force: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quản lý hộp kit',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: admin.isCreatingKit
                    ? null
                    : () => _showCreateKitDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tạo kit'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (admin.isLoadingKits)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (admin.kits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  'Chưa có hộp kit nào.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            )
          else
            ...admin.kits.map(
                  (kit) => _KitTile(
                kit: kit,
                onViewDetail: () => _showKitDetailSheet(context, kit),
                onGenerateCodes: () => _showGenerateCodesDialog(context, kit),
              ),
            ),
        ],
      ),
    );
  }

  void _showCreateKitDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _CreateKitSheet(),
    );
  }

  Future<void> _showKitDetailSheet(BuildContext context, KitModel kit) async {
    unawaited(showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _LoadingKitDetailSheet(),
    ));

    try {
      final detail = await context.read<AdminProvider>().getKitByCode(kit.code);

      if (!context.mounted) return;

      Navigator.pop(context);

      unawaited(showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.cardBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => _KitDetailSheet(kit: detail),
      ));
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải chi tiết kit: $e')),
      );
    }
  }

  void _showGenerateCodesDialog(BuildContext context, KitModel kit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _GenerateCodesSheet(kit: kit),
    );
  }
}

class _KitSectionSwitcher extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _KitSectionSwitcher({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            selected: selected == 'KITS',
            label: const Center(child: Text('Hộp kit')),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.cardBg,
            side: BorderSide(
              color: selected == 'KITS'
                  ? AppColors.primary
                  : AppColors.cardBorder.withValues(alpha: 0.4),
            ),
            labelStyle: TextStyle(
              color: selected == 'KITS'
                  ? Colors.white
                  : AppColors.textSecondary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
            onSelected: (_) => onChanged('KITS'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            selected: selected == 'CODES',
            label: const Center(child: Text('Mã kích hoạt')),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.cardBg,
            side: BorderSide(
              color: selected == 'CODES'
                  ? AppColors.primary
                  : AppColors.cardBorder.withValues(alpha: 0.4),
            ),
            labelStyle: TextStyle(
              color: selected == 'CODES'
                  ? Colors.white
                  : AppColors.textSecondary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
            onSelected: (_) => onChanged('CODES'),
          ),
        ),
      ],
    );
  }
}

class _CreateKitSheet extends StatefulWidget {
  const _CreateKitSheet();

  @override
  State<_CreateKitSheet> createState() => _CreateKitSheetState();
}

class _CreateKitSheetState extends State<_CreateKitSheet> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _formulasController = TextEditingController();

  bool _active = true;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _formulasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tạo hộp kit',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),

              _KitTextField(
                controller: _codeController,
                label: 'Mã kit',
                hint: 'VD: FULL_KIT',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mã kit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              _KitTextField(
                controller: _nameController,
                label: 'Tên kit',
                hint: 'VD: Full Chemistry Kit',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên kit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              _KitTextField(
                controller: _descriptionController,
                label: 'Mô tả',
                hint: 'Mô tả ngắn về hộp kit',
                maxLines: 3,
              ),
              const SizedBox(height: 10),

              _KitTextField(
                controller: _priceController,
                label: 'Giá',
                hint: 'VD: 299000',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

              _KitTextField(
                controller: _formulasController,
                label: 'Công thức chất trong kit',
                hint: 'VD: Zn, HCl, NaOH',
                maxLines: 2,
              ),
              const SizedBox(height: 10),

              SwitchListTile(
                value: _active,
                onChanged: (value) {
                  setState(() {
                    _active = value;
                  });
                },
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Active',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'Kit active mới được dùng để generate activation code.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: admin.isCreatingKit ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: admin.isCreatingKit
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Tạo kit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final priceText = _priceController.text.trim();
    final price = priceText.isEmpty ? null : double.tryParse(priceText);

    final formulas = _formulasController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final request = CreateKitRequest(
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      active: _active,
      substanceFormulas: formulas,
    );

    try {
      await context.read<AdminProvider>().createKit(request);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo hộp kit')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo kit thất bại: $e')),
      );
    }
  }
}

class _KitTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _KitTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return PortalGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: AppColors.accentText,
            fontFamily: 'Inter',
          ),
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
            fontSize: 13,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _KitTile extends StatelessWidget {
  final KitModel kit;
  final VoidCallback onViewDetail;
  final VoidCallback onGenerateCodes;

  const _KitTile({
    required this.kit,
    required this.onViewDetail,
    required this.onGenerateCodes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PortalGlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${kit.code}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),

                _StatusBadge(active: kit.active),
              ],
            ),

            if (kit.description != null && kit.description!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  kit.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoBadge(
                  text: '${kit.items.length} chất',
                  icon: Icons.science_outlined,
                ),
                _InfoBadge(
                  text: kit.price == null
                      ? 'Chưa có giá'
                      : '${kit.price!.toStringAsFixed(0)}đ',
                  icon: Icons.payments_outlined,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewDetail,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Chi tiết'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: kit.active ? onGenerateCodes : null,
                    icon: const Icon(Icons.vpn_key_outlined, size: 18),
                    label: const Text('Tạo mã'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
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

class _StatusBadge extends StatelessWidget {
  final bool active;

  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
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

class _InfoBadge extends StatelessWidget {
  final String text;
  final IconData icon;

  const _InfoBadge({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentText),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateCodesSheet extends StatefulWidget {
  final KitModel kit;

  const _GenerateCodesSheet({
    required this.kit,
  });

  @override
  State<_GenerateCodesSheet> createState() => _GenerateCodesSheetState();
}

class _GenerateCodesSheetState extends State<_GenerateCodesSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '10');
  final _noteController = TextEditingController();
  DateTime? _expiresAt;

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tạo mã kích hoạt',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.kit.name} · ${widget.kit.code}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),

              _KitTextField(
                controller: _quantityController,
                label: 'Số lượng mã',
                hint: 'VD: 100',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final quantity = int.tryParse(value?.trim() ?? '');

                  if (quantity == null || quantity <= 0) {
                    return 'Số lượng phải lớn hơn 0';
                  }

                  if (quantity > 1000) {
                    return 'Không nên tạo quá 1000 mã một lần';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),

              _KitTextField(
                controller: _noteController,
                label: 'Ghi chú',
                hint: 'VD: Batch tháng 01/2026',
                maxLines: 2,
              ),
              const SizedBox(height: 10),

              PortalGlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      color: AppColors.accentText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _expiresAt == null
                            ? 'Không đặt ngày hết hạn'
                            : 'Hết hạn: ${_formatDate(_expiresAt!)}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _pickExpiresAt,
                      child: const Text('Chọn ngày'),
                    ),
                    if (_expiresAt != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _expiresAt = null;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: admin.isGeneratingActivationCodes
                      ? null
                      : _submit,
                  icon: const Icon(Icons.vpn_key_outlined, size: 18),
                  label: admin.isGeneratingActivationCodes
                      ? const Text('Đang tạo...')
                      : const Text('Tạo mã'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickExpiresAt() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null) return;

    setState(() {
      _expiresAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        23,
        59,
        59,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = GenerateActivationCodesRequest(
      kitCode: widget.kit.code,
      quantity: int.parse(_quantityController.text.trim()),
      expiresAt: _expiresAt,
      note: _noteController.text.trim(),
    );

    try {
      final codes = await context
          .read<AdminProvider>()
          .generateActivationCodes(request);

      if (!mounted) return;

      Navigator.pop(context);

      _showGeneratedCodesResult(context, codes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tạo ${codes.length} mã kích hoạt')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo mã thất bại: $e')),
      );
    }
  }

  void _showGeneratedCodesResult(
      BuildContext context,
      List<ActivationCodeModel> codes,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _GeneratedCodesSheet(codes: codes),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _GeneratedCodesSheet extends StatelessWidget {
  final List<ActivationCodeModel> codes;

  const _GeneratedCodesSheet({
    required this.codes,
  });

  @override
  Widget build(BuildContext context) {
    final allCodesText = codes.map((e) => e.code).join('\n');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mã vừa tạo',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${codes.length} mã kích hoạt',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 14),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: codes.length,
              itemBuilder: (context, index) {
                final code = codes[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PortalGlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.vpn_key_outlined,
                          color: AppColors.accentText,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            code.code,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          code.status,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: allCodesText));

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã copy danh sách mã')),
                );
              },
              icon: const Icon(Icons.copy_outlined, size: 18),
              label: const Text('Copy tất cả'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingKitDetailSheet extends StatelessWidget {
  const _LoadingKitDetailSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Đang tải chi tiết hộp kit...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _KitDetailSheet extends StatelessWidget {
  final KitModel kit;

  const _KitDetailSheet({
    required this.kit,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      kit.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoBadge(
                    text: kit.code,
                    icon: Icons.qr_code_2_outlined,
                  ),
                  _InfoBadge(
                    text: kit.active ? 'Active' : 'Inactive',
                    icon: Icons.power_settings_new,
                  ),
                  _InfoBadge(
                    text: kit.price == null
                        ? 'Chưa có giá'
                        : '${kit.price!.toStringAsFixed(0)}đ',
                    icon: Icons.payments_outlined,
                  ),
                  _InfoBadge(
                    text: '${kit.items.length} chất',
                    icon: Icons.science_outlined,
                  ),
                ],
              ),

              if (kit.description != null &&
                  kit.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Mô tả',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  kit.description!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Danh sách chất trong kit',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  Text(
                    '${kit.items.length} chất',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (kit.items.isEmpty)
                PortalGlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Kit này chưa có chất nào.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                )
              else
                ...kit.items.map(
                      (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PortalGlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                item.formula,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          _StatusBadge(active: item.active),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}