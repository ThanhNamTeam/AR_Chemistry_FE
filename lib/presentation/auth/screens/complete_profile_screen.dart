import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/account_setup_model.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../home/providers/app_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  final AccountSetupRouteArgs args;

  const CompleteProfileScreen({super.key, required this.args});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  UserRole _role = UserRole.student;

  @override
  void initState() {
    super.initState();
    if (widget.args.prefilledFullName != null) {
      _nameCtrl.text = widget.args.prefilledFullName!;
    }
    if (widget.args.prefilledEmail != null) {
      _emailCtrl.text = widget.args.prefilledEmail!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_role == UserRole.teacher) {
      final teacher = await _showTeacherProfileDialog();
      if (!mounted || teacher == null) return;
      context.read<AppState>().completeAccountSetup(AccountSetupData(
            fullName: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            role: _role,
            schoolName: teacher.schoolName,
            certificateUrl: teacher.certificateUrl,
            experience: teacher.experience,
          ));
    } else {
      context.read<AppState>().completeAccountSetup(AccountSetupData(
            fullName: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            role: _role,
          ));
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  Future<_TeacherFormResult?> _showTeacherProfileDialog() async {
    final schoolCtrl = TextEditingController();
    final certCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    final result = await showDialog<_TeacherFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.primary.withOpacity(0.35)),
          ),
          title: const Text(
            'Teacher profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    label: 'School name',
                    hint: 'Your school or institution',
                    controller: schoolCtrl,
                    prefixIcon: Icons.school_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Certificate (URL)',
                    hint: 'Link to your teaching certificate',
                    controller: certCtrl,
                    prefixIcon: Icons.description_outlined,
                    keyboardType: TextInputType.url,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Teaching experience',
                    hint: 'Years of experience (e.g. 5)',
                    controller: expCtrl,
                    prefixIcon: Icons.work_outline,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                if (!dialogFormKey.currentState!.validate()) return;
                Navigator.pop(
                  ctx,
                  _TeacherFormResult(
                    schoolName: schoolCtrl.text.trim(),
                    certificateUrl: certCtrl.text.trim(),
                    experience: expCtrl.text.trim(),
                  ),
                );
              },
              child: const Text('Save',
                  style: TextStyle(color: AppColors.primaryLight)),
            ),
          ],
        );
      },
    );

    schoolCtrl.dispose();
    certCtrl.dispose();
    expCtrl.dispose();

    return result;
  }

  Widget _roleChip({
    required UserRole value,
    required String label,
    required IconData icon,
  }) {
    final selected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : AppColors.cardBg.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : AppColors.primary.withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20,
                  color: selected ? Colors.white : AppColors.textCyan),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGoogle = widget.args.source == AccountSetupSource.google;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundBlue,
              AppColors.backgroundDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.5)),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: AppColors.primary, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isGoogle ? 'Complete your account' : 'Create your account',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isGoogle
                      ? 'Your Google email is confirmed. Set a password and choose your role.'
                      : 'Enter your details, set a password, and choose your role.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textCyan,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 30),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          label: 'Full name',
                          hint: 'Your full name',
                          controller: _nameCtrl,
                          prefixIcon: Icons.person_outline,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Email',
                          hint: 'Your email address',
                          controller: _emailCtrl,
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: widget.args.lockEmail,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Password',
                          hint: 'Choose a password',
                          controller: _passCtrl,
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (v) => v == null || v.length < 6
                              ? 'Min 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Confirm password',
                          hint: 'Re-enter password',
                          controller: _confirmCtrl,
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Role',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textCyan,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _roleChip(
                              value: UserRole.student,
                              label: 'Student',
                              icon: Icons.school_outlined,
                            ),
                            const SizedBox(width: 12),
                            _roleChip(
                              value: UserRole.teacher,
                              label: 'Teacher',
                              icon: Icons.person_pin_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _role == UserRole.teacher
                              ? 'Teachers will be asked for school, certificate link, and experience.'
                              : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.9),
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _submit,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Text(
                              isGoogle ? 'Save & continue' : 'Sign up',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _TeacherFormResult {
  final String schoolName;
  final String certificateUrl;
  final String experience;

  _TeacherFormResult({
    required this.schoolName,
    required this.certificateUrl,
    required this.experience,
  });
}
