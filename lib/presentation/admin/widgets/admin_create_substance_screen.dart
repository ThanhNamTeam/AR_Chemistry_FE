import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/api/admin_substance_api.dart';
import '../../../core/models/request/create_substance_request.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/admin_provider.dart';

class AdminCreateSubstanceScreen extends StatefulWidget {
  const AdminCreateSubstanceScreen({super.key});

  @override
  State<AdminCreateSubstanceScreen> createState() =>
      _AdminCreateSubstanceScreenState();
}

class _AdminCreateSubstanceScreenState
    extends State<AdminCreateSubstanceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _formulaController = TextEditingController();
  final _nameController = TextEditingController();
  final _vietnameseNameController = TextEditingController();
  final _molarMassController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _safetyNoteController = TextEditingController();

  String _type = 'COMPOUND';
  String _chemicalGroup = 'ACID';
  String _state = 'SOLID';

  bool _active = true;
  bool _includedInFullKit = true;
  bool _isSubmitting = false;

  final List<String> _types = const ['ELEMENT', 'COMPOUND', 'SIMPLE_MOLECULE'];

  final List<String> _chemicalGroups = const [
    'ACID',
    'BASE',
    'SALT',
    'METAL',
    'NONMETAL',
    'OXIDE',
    'SOLVENT',
    'GAS',
    'INDICATOR',
    'OTHER',
  ];

  final List<String> _states = const [
    'SOLID',
    'LIQUID',
    'GAS',
    'AQUEOUS',
    'UNKNOWN',
  ];

  @override
  void dispose() {
    _formulaController.dispose();
    _nameController.dispose();
    _vietnameseNameController.dispose();
    _molarMassController.dispose();
    _descriptionController.dispose();
    _safetyNoteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final molarMassText = _molarMassController.text.trim();

      final request = CreateSubstanceRequest(
        formula: _formulaController.text.trim(),
        name: _nameController.text.trim(),
        vietnameseName: _emptyToNull(_vietnameseNameController.text),
        type: _type,
        chemicalGroup: _chemicalGroup,
        state: _state,
        molarMass: molarMassText.isEmpty
            ? null
            : double.tryParse(molarMassText),
        active: _active,
        includedInFullKit: _includedInFullKit,
        description: _emptyToNull(_descriptionController.text),
        safetyNote: _emptyToNull(_safetyNoteController.text),
      );

      await AdminSubstanceApi().createSubstance(request);

      if (!mounted) return;

      await context.read<AdminProvider>().loadSubstances(force: true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.isVi ? 'Đã thêm chất mới.' : 'Substance created.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          l10n.isVi ? 'Thêm chất mới' : 'Create substance',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                PortalGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _TextInput(
                        controller: _formulaController,
                        label: l10n.isVi ? 'Công thức hóa học' : 'Formula',
                        hint: 'H2O, NaCl, H2SO4...',
                        required: true,
                      ),
                      const SizedBox(height: 12),

                      _TextInput(
                        controller: _nameController,
                        label: l10n.isVi ? 'Tên tiếng Anh' : 'Name',
                        hint: 'Water, Sodium chloride...',
                        required: true,
                      ),
                      const SizedBox(height: 12),

                      _TextInput(
                        controller: _vietnameseNameController,
                        label: l10n.isVi ? 'Tên tiếng Việt' : 'Vietnamese name',
                        hint: 'Nước, Natri clorua...',
                      ),
                      const SizedBox(height: 12),

                      _DropdownInput(
                        label: l10n.isVi ? 'Loại chất' : 'Type',
                        value: _type,
                        items: _types,
                        onChanged: (value) {
                          setState(() {
                            _type = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      _DropdownInput(
                        label: l10n.isVi ? 'Nhóm chất' : 'Chemical group',
                        value: _chemicalGroup,
                        items: _chemicalGroups,
                        onChanged: (value) {
                          setState(() {
                            _chemicalGroup = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      _DropdownInput(
                        label: l10n.isVi ? 'Trạng thái' : 'State',
                        value: _state,
                        items: _states,
                        onChanged: (value) {
                          setState(() {
                            _state = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      _TextInput(
                        controller: _molarMassController,
                        label: l10n.isVi ? 'Khối lượng mol' : 'Molar mass',
                        hint: '18.015',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';

                          if (text.isEmpty) {
                            return null;
                          }

                          if (double.tryParse(text) == null) {
                            return l10n.isVi
                                ? 'Khối lượng mol không hợp lệ'
                                : 'Invalid molar mass';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                PortalGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _active,
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primary,
                        title: Text(
                          'Active',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                        subtitle: Text(
                          l10n.isVi
                              ? 'Cho phép chất được dùng trong hệ thống'
                              : 'Allow this substance to be used',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _active = value;
                          });
                        },
                      ),

                      SwitchListTile(
                        value: _includedInFullKit,
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primary,
                        title: Text(
                          l10n.isVi
                              ? 'Có trong Full Kit'
                              : 'Included in Full Kit',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                        subtitle: Text(
                          l10n.isVi
                              ? 'Đánh dấu chất này nằm trong bộ kit đầy đủ'
                              : 'Mark this substance as a full-kit item',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _includedInFullKit = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                PortalGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _TextInput(
                        controller: _descriptionController,
                        label: l10n.isVi ? 'Mô tả' : 'Description',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),

                      _TextInput(
                        controller: _safetyNoteController,
                        label: l10n.isVi ? 'Lưu ý an toàn' : 'Safety note',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSubmitting
                        ? (l10n.isVi ? 'Đang lưu...' : 'Saving...')
                        : (l10n.isVi ? 'Lưu chất mới' : 'Create substance'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextInput({
    required this.controller,
    required this.label,
    this.hint,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
      validator:
          validator ??
          (value) {
            if (!required) {
              return null;
            }

            if ((value ?? '').trim().isEmpty) {
              return l10n.isVi ? 'Không được bỏ trống' : 'Required';
            }

            return null;
          },
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          fontFamily: 'Inter',
        ),
        filled: true,
        fillColor: AppColors.cardBg.withValues(alpha: 0.45),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _DropdownInput extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownInput({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: value,
      dropdownColor: AppColors.cardBg,
      style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
      decoration: InputDecoration(
        labelText: '$label *',
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
        filled: true,
        fillColor: AppColors.cardBg.withValues(alpha: 0.45),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}
