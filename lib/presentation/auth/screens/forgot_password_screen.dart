import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/cognito_password_policy.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/login_route_args.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/gradient_primary_button.dart';
import '../../../shared/widgets/pressable_scale.dart';
import '../../../core/l10n/locale_provider.dart';

enum _ForgotStep { email, otp, newPassword }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _ForgotStep _step = _ForgotStep.email;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _unfocusKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _sendOtp() async {
    _unfocusKeyboard();
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError(l10n.invalidEmail);
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await Amplify.Auth.resetPassword(username: email);
      if (!mounted) return;

      if (result.nextStep.updateStep ==
          AuthResetPasswordStep.confirmResetPasswordWithCode) {
        setState(() {
          _step = _ForgotStep.otp;
          _loading = false;
        });
        _showSuccess(l10n.otpSent);
      } else {
        setState(() => _loading = false);
        _showError(l10n.errorGeneric);
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

  void _goToNewPassword() {
    final l10n = AppLocalizations.of(context);
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      _showError(l10n.otpHint);
      return;
    }
    setState(() => _step = _ForgotStep.newPassword);
  }

  Future<void> _confirmReset() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password != confirm) {
      _showError(l10n.passwordMismatch);
      return;
    }

    final policyCode = CognitoPasswordPolicy.validate(password);
    if (policyCode != null) {
      _showError(l10n.passwordPolicyError(policyCode));
      return;
    }

    setState(() => _loading = true);
    try {
      await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: password,
        confirmationCode: otp,
      );
      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
        arguments: const LoginRouteArgs(passwordResetSuccess: true),
      );
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
    if (msg.contains('usernotfound') || msg.contains('user not found')) {
      return l10n.isVi ? 'Email chưa được đăng ký' : 'Email is not registered';
    }
    if (msg.contains('codemismatch') || msg.contains('invalid code')) {
      return l10n.isVi ? 'Mã OTP không đúng' : 'Invalid OTP code';
    }
    if (msg.contains('expired')) {
      return l10n.isVi ? 'Mã OTP đã hết hạn' : 'OTP code expired';
    }
    if (msg.contains('invalidpassword') || msg.contains('password')) {
      return l10n.passwordPolicyHint;
    }
    return e.message;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
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
        leading: PressableScale(
          onTap: () {
            if (_step == _ForgotStep.email) {
              Navigator.pop(context);
            } else if (_step == _ForgotStep.otp) {
              setState(() => _step = _ForgotStep.email);
            } else {
              setState(() => _step = _ForgotStep.otp);
            }
          },
          child: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
        ),
        title: Text(
          l10n.forgotPasswordTitle,
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_step == _ForgotStep.email) ..._buildEmailStep(l10n),
              if (_step == _ForgotStep.otp) ..._buildOtpStep(l10n),
              if (_step == _ForgotStep.newPassword) ..._buildNewPasswordStep(l10n),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEmailStep(AppLocalizations l10n) {
    return [
      Text(
        l10n.forgotPasswordEmailHint,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
      const SizedBox(height: 24),
      _label(l10n.emailLabel),
      const SizedBox(height: 8),
      _textField(
        controller: _emailController,
        hint: l10n.emailHint,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 32),
      GradientPrimaryButton(
        label: l10n.sendOtpButton,
        loading: _loading,
        onTap: _sendOtp,
      ),
    ];
  }

  List<Widget> _buildOtpStep(AppLocalizations l10n) {
    return [
      Text(
        l10n.verifyOtpSubtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
      const SizedBox(height: 8),
      Text(
        _emailController.text.trim(),
        style: TextStyle(
          color: AppColors.accentText,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      const SizedBox(height: 24),
      _label(l10n.otpLabel),
      const SizedBox(height: 8),
      _textField(
        controller: _otpController,
        hint: l10n.otpHint,
        keyboardType: TextInputType.number,
        maxLength: 6,
      ),
      const SizedBox(height: 16),
      PressableScale(
        onTap: _loading ? null : _sendOtp,
        child: Text(
          l10n.resendOtp,
          style: TextStyle(
            color: AppColors.accentText,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      const SizedBox(height: 32),
      GradientPrimaryButton(
        label: l10n.nextStep,
        onTap: _goToNewPassword,
      ),
    ];
  }

  List<Widget> _buildNewPasswordStep(AppLocalizations l10n) {
    return [
      Text(
        l10n.passwordPolicyHint,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontFamily: 'Inter',
        ),
      ),
      const SizedBox(height: 24),
      _label(l10n.newPasswordLabel),
      const SizedBox(height: 8),
      _textField(
        controller: _passwordController,
        hint: l10n.passwordHint,
        obscure: _obscurePassword,
        suffix: _visibilityToggle(
          _obscurePassword,
          () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      const SizedBox(height: 16),
      _label(l10n.confirmNewPasswordLabel),
      const SizedBox(height: 8),
      _textField(
        controller: _confirmPasswordController,
        hint: l10n.confirmPasswordHint,
        obscure: _obscureConfirm,
        suffix: _visibilityToggle(
          _obscureConfirm,
          () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      const SizedBox(height: 32),
      GradientPrimaryButton(
        label: l10n.confirmChangePassword,
        loading: _loading,
        onTap: _confirmReset,
      ),
    ];
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

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLength: maxLength,
      style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7)),
        filled: true,
        fillColor: AppColors.cardBg,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _visibilityToggle(bool obscure, VoidCallback onTap) {
    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
