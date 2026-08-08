import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/cognito_password_policy.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/gradient_primary_button.dart';

/// Đăng ký Cognito — email + password, sau đó xác thực OTP.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _loading = true);
    try {
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email,
          },
        ),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (result.isSignUpComplete) {
        unawaited(Navigator.pushReplacementNamed(context, AppRoutes.login));
      } else {
        unawaited(Navigator.pushReplacementNamed(
          context,
          AppRoutes.verifyOtp,
          arguments: email,
        ));
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(_mapAuthError(e, l10n));
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(l10n.errorGeneric);
    }
  }

  String _mapAuthError(AuthException e, AppLocalizations l10n) {
    final msg = e.message.toLowerCase();
    if (msg.contains('usernameexists') || msg.contains('already exists')) {
      return l10n.isVi ? 'Email đã được đăng ký' : 'Email already registered';
    }
    if (msg.contains('invalidpassword')) {
      return l10n.passwordPolicyHint;
    }
    return e.message;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.registerTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.registerSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                _label(l10n.emailLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.requiredField;
                    if (!v.contains('@')) return l10n.invalidEmail;
                    return null;
                  },
                  style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
                  decoration: _inputDecoration(l10n.emailHint),
                ),
                const SizedBox(height: 16),
                _label(l10n.passwordLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.requiredField;
                    final code = CognitoPasswordPolicy.validate(v);
                    if (code != null) return l10n.passwordPolicyError(code);
                    return null;
                  },
                  style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
                  decoration: _inputDecoration(l10n.passwordHint).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.passwordPolicyHint,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                _label(l10n.confirmPasswordLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.requiredField;
                    if (v != _passwordController.text) return l10n.passwordMismatch;
                    return null;
                  },
                  style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
                  decoration: _inputDecoration(l10n.confirmPasswordHint).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GradientPrimaryButton(
                  label: l10n.signUp,
                  loading: _loading,
                  onTap: _signUp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7)),
        filled: true,
        fillColor: AppColors.cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}
