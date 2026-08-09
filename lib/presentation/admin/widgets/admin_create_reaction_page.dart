import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/request/create_reaction_definition_request.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/admin_provider.dart';

class AdminCreateReactionPage extends StatefulWidget {
  const AdminCreateReactionPage({super.key});

  @override
  State<AdminCreateReactionPage> createState() =>
      _AdminCreateReactionPageState();
}

class _AdminCreateReactionPageState extends State<AdminCreateReactionPage> {
  final _formKey = GlobalKey<FormState>();

  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _equationCtrl = TextEditingController();

  final _descriptionCtrl = TextEditingController();
  final _scriptCtrl = TextEditingController();

  // ignore: prefer_final_fields
  String? _selectedReactionCategory = 'SALT';

  String? _selectedArSceneKey = 'COMBUSTION_GAS';
  String? _selectedReactionType = 'COMBUSTION';

  // ignore: unused_field
  final List<String> _reactionCategories = const [
    'METAL',
    'ACID',
    'BASE',
    'SALT',
  ];

  final List<String> _arSceneKeys = const [
    'METAL_ACID_GAS',
    'METAL_WATER_GAS',
    'PRECIPITATION',
    'THERMAL_DECOMPOSITION_GAS',
    'NEUTRALIZATION',
    'COMBUSTION',
    'COMBUSTION_GAS',
    'GAS_EVOLUTION',
    'REDOX_GAS',
    'NO_REACTION',
    'DEFAULT',
  ];

  final List<String> _reactionTypes = const [
    'METAL_ACID',
    'METAL_WATER',
    'PRECIPITATION',
    'NEUTRALIZATION',
    'THERMAL_DECOMPOSITION',
    'COMBUSTION',
    'GAS_EVOLUTION',
    'REDOX',
    'NO_REACTION',
    'OTHER',
  ];

  String? _selectedGrade = '8';

  final List<String> _grades = const [
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

  final List<_ReactionSubstanceInput> _reactants = [
    _ReactionSubstanceInput(),
  ];

  final List<_ReactionSubstanceInput> _products = [
    _ReactionSubstanceInput(),
  ];

  bool _active = true;
  bool _submitting = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _equationCtrl.dispose();
    _descriptionCtrl.dispose();
    _scriptCtrl.dispose();

    for (final item in _reactants) {
      item.dispose();
    }

    for (final item in _products) {
      item.dispose();
    }

    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      filled: true,
      fillColor: AppColors.cardBg.withValues(alpha: 0.65),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      labelStyle: TextStyle(
        color: AppColors.subtitleAccent,
        fontFamily: 'Inter',
      ),
      hintStyle: TextStyle(
        color: AppColors.subtitleAccent.withValues(alpha: 0.55),
        fontFamily: 'Inter',
      ),
    );
  }

  String _formatEquationSide(List<_ReactionSubstanceInput> rows) {
    return rows
        .map((row) {
      final formula = row.formulaCtrl.text.trim();
      final coefficient = int.tryParse(row.coefficientCtrl.text.trim()) ?? 1;

      if (formula.isEmpty) return '';

      return coefficient == 1 ? formula : '$coefficient$formula';
    })
        .where((e) => e.isNotEmpty)
        .join(' + ');
  }

  void _refreshEquation() {
    final left = _formatEquationSide(_reactants);
    final right = _formatEquationSide(_products);

    final equation = left.isNotEmpty && right.isNotEmpty
        ? '$left -> $right'
        : '';

    if (_equationCtrl.text != equation) {
      _equationCtrl.text = equation;
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Không được để trống';
        }
        return null;
      },
      dropdownColor: AppColors.cardBg,
      iconEnabledColor: AppColors.textPrimary,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
      ),
      decoration: _inputDecoration(
        label: label,
        icon: icon,
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
          value: e,
          child: Text(
            e,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _substanceRows({
    required String title,
    required List<_ReactionSubstanceInput> items,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        ...List.generate(items.length, (index) {
          final item = items[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: item.formulaCtrl,
                    validator: _required,
                    onChanged: (_) => _refreshEquation(),
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration(
                      label: 'Formula',
                      hint: 'KMnO4',
                      icon: Icons.science_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 92,
                  child: TextFormField(
                    controller: item.coefficientCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _refreshEquation(),
                    validator: (value) {
                      final number = int.tryParse(value ?? '');
                      if (number == null || number <= 0) {
                        return 'Sai';
                      }
                      return null;
                    },
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration(
                      label: 'Hệ số',
                      hint: '1',
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: items.length == 1
                      ? null
                      : () {
                    setState(() {
                      items[index].dispose();
                      items.removeAt(index);
                    });
                    _refreshEquation();
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: items.length == 1
                        ? AppColors.subtitleAccent.withValues(alpha: 0.35)
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Thêm dòng'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  List<ReactionSubstanceRequest> _buildSubstances(
      List<_ReactionSubstanceInput> rows,
      ) {
    return rows
        .map(
          (row) => ReactionSubstanceRequest(
        formula: row.formulaCtrl.text.trim(),
        coefficient: int.tryParse(row.coefficientCtrl.text.trim()) ?? 1,
      ),
    )
        .where((item) => item.formula.isNotEmpty)
        .toList();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Không được để trống';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _refreshEquation();

    final reactants = _buildSubstances(_reactants);
    final products = _buildSubstances(_products);

    if (reactants.isEmpty || products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chất tham gia và sản phẩm không được để trống'),
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final request = CreateReactionDefinitionRequest(
        code: _codeCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        equation: _equationCtrl.text.trim(),
        reactionCategory: _selectedReactionCategory!,
        reactionType: _selectedReactionType!,
        arSceneKey: _selectedArSceneKey!,
        description: _descriptionCtrl.text.trim(),
        script: _scriptCtrl.text.trim().isEmpty
            ? null
            : _scriptCtrl.text.trim(),
        grade: int.parse(_selectedGrade!),
        active: _active,
        reactants: reactants,
        products: products,
      );
      await context.read<AdminProvider>().addReaction(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo phản ứng thành công')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      String cleanError(Object error) {
        return error.toString().replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo phản ứng thất bại: ${cleanError(e)}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          l10n.addReaction,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
          ),
          child: FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.save_outlined),
            label: Text(_submitting ? 'Đang lưu...' : 'Lưu phản ứng'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [

            _sectionTitle('Thông tin phản ứng'),

            TextFormField(
              controller: _codeCtrl,
              validator: _required,
              style: TextStyle(color: AppColors.textPrimary),
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Code',
                hint: 'KMNO4_THERMAL_DECOMPOSITION',
                icon: Icons.tag_outlined,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameCtrl,
              validator: _required,
              style: TextStyle(color: AppColors.textPrimary),
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Tên phản ứng',
                hint: 'Nhiệt phân kali pemanganat',
                icon: Icons.title_outlined,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _equationCtrl,
              readOnly: true,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration(
                label: 'Phương trình tự sinh',
                hint: 'Tự tạo từ chất tham gia và sản phẩm',
                icon: Icons.functions,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nếu phương trình sai, hãy chỉnh lại công thức hoặc hệ số ở phần chất tham gia/sản phẩm.',
              style: TextStyle(
                color: AppColors.subtitleAccent.withValues(alpha: 0.75),
                fontSize: 11,
                fontFamily: 'Inter',
              ),
            ),

            _sectionTitle('Loại phản ứng & AR'),

            _dropdownField(
              label: 'Reaction type',
              value: _selectedReactionType,
              items: _reactionTypes,
              icon: Icons.category_outlined,
              onChanged: (value) {
                setState(() {
                  _selectedReactionType = value;
                });
              },
            ),
            const SizedBox(height: 12),

            _dropdownField(
              label: 'AR scene key',
              value: _selectedArSceneKey,
              items: _arSceneKeys,
              icon: Icons.view_in_ar_outlined,
              onChanged: (value) {
                setState(() {
                  _selectedArSceneKey = value;
                });
              },
            ),

            const SizedBox(height: 12),

            _dropdownField(
              label: 'Lớp áp dụng',
              value: _selectedGrade,
              items: _grades,
              icon: Icons.school_outlined,
              onChanged: (value) {
                setState(() {
                  _selectedGrade = value;
                });
              },
            ),

            _sectionTitle('Chất tham gia & sản phẩm'),

            _substanceRows(
              title: 'Chất tham gia',
              items: _reactants,
              onAdd: () {
                setState(() {
                  _reactants.add(_ReactionSubstanceInput());
                });
                _refreshEquation();
              },
            ),

            _substanceRows(
              title: 'Sản phẩm',
              items: _products,
              onAdd: () {
                setState(() {
                  _products.add(_ReactionSubstanceInput());
                });
                _refreshEquation();
              },
            ),

            _sectionTitle('Mô tả & trạng thái'),

            TextFormField(
              controller: _descriptionCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              minLines: 3,
              maxLines: 5,
              decoration: _inputDecoration(
                label: 'Mô tả',
                hint: 'Kali pemanganat bị nhiệt phân tạo khí oxi...',
                icon: Icons.notes_outlined,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBg.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.power_settings_new_outlined,
                    color: _active ? Colors.greenAccent : AppColors.subtitleAccent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _active ? 'Đang bật' : 'Đang tắt',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  Switch(
                    value: _active,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _active = value;
                      });
                    },
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

class _ReactionSubstanceInput {
  final TextEditingController formulaCtrl = TextEditingController();
  final TextEditingController coefficientCtrl = TextEditingController(text: '1');

  void dispose() {
    formulaCtrl.dispose();
    coefficientCtrl.dispose();
  }
}