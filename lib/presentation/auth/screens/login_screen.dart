import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/portal/portal_scope.dart';
import '../../../domain/models/app_portal.dart';
import '../../../domain/models/login_route_args.dart';
import '../../../domain/models/user_role.dart';
import '../../home/providers/theme_provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/role_session_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../widgets/auth_appearance_sheet.dart';
import '../../../core/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _loginKey = GlobalKey<FormState>();

  late AnimationController _bgCtrl;
  late Animation<double> _bgPulse;
  bool _registrationMessageShown = false;
  bool _googleLoading = false;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _bgPulse = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await activatePortal(context, AppPortal.auth);
      if (!mounted) return;
      await _restoreSession();
      _showRegistrationSuccessMessage();
    });
  }

  void _showRegistrationSuccessMessage() {
    if (_registrationMessageShown || !mounted) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! LoginRouteArgs || !args.registrationSuccess) return;
    _registrationMessageShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).registrationSuccessLogin,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _restoreSession() async {
    final roleSession = context.read<RoleSessionProvider>();
    await roleSession.loadSession();
    if (!mounted) return;
    if (roleSession.isStaff) {
      await activatePortal(context, AppPortal.staff);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.staffHome);
      return;
    }
    if (roleSession.isAdmin) {
      await activatePortal(context, AppPortal.admin);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
      return;
    }
    final state = context.read<AppState>();
    if (!state.initialized) await state.initialize();
    if (mounted && state.isLoggedIn) {
      await activatePortal(context, AppPortal.user);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {

    if (!_loginKey.currentState!.validate()) {
      return;
    }

    try {

      try {
        await Amplify.Auth.signOut();
      } catch (_) {}

      final result = await Amplify.Auth.signIn(
        username: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!result.isSignedIn) {
        return;
      }

      final session =
      await Amplify.Auth.fetchAuthSession()
      as CognitoAuthSession;

      final idToken =
          session.userPoolTokensResult
              .value
              .idToken
              .raw;

// decode JWT
      final parts = idToken.split('.');

      final payload = utf8.decode(
        base64Url.decode(
          base64Url.normalize(parts[1]),
        ),
      );

      final claims =
      jsonDecode(payload) as Map<String, dynamic>;

      debugPrint('CLAIMS: $claims');

      final groups =
          (claims['cognito:groups'] as List?)
              ?.map((e) => e.toString())
              .toList() ?? [];

      debugPrint('GROUPS: $groups');

      final roleSession =
      context.read<RoleSessionProvider>();

      UserRole role = UserRole.student;

      if (groups.contains('ROLE_ADMIN')) {
        role = UserRole.admin;
      } else if (groups.contains('ROLE_STAFF')) {
        role = UserRole.staff;
      }

      await roleSession.saveSession(
        role: role,
        email: _emailCtrl.text.trim(),
      );

      if (!mounted) return;

      await _restoreSession();

    } on AuthException catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );

    } catch (e) {

      debugPrint('LOGIN_ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _loginGoogle() async {
    if (_googleLoading) return;

    setState(() => _googleLoading = true);

    try {
      final result = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
      );

      if (!result.isSignedIn) return;

      final session =
      await Amplify.Auth.fetchAuthSession()
      as CognitoAuthSession;

      final idToken =
          session.userPoolTokensResult
              .value
              .idToken
              .raw;

      await AuthApi().syncGoogleUser(
        idToken,
      );

      debugPrint(idToken);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
            (_) => false,
      );

    } on Exception catch (e) {

      debugPrint(
        'Google sign in failed: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đăng nhập Google thất bại',
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() => _googleLoading = false);
      }
    }
  }

  void _openRegistration() {
    Navigator.pushNamed(context, AppRoutes.completeProfile);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            _buildBgBlobs(),
            SafeArea(child: _buildLogin()),
          ],
        ),
      ),
    );
  }

  Widget _buildBgBlobs() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _bgPulse,
        builder: (_, __) => Stack(
          children: [
            Positioned(
              top: 60,
              left: -50,
              child: Transform.scale(
                scale: _bgPulse.value,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.05),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              right: -60,
              child: Transform.scale(
                scale: 1.1 - 0.1 * _bgPulse.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.05),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogin() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: const AuthSettingsButton(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.5), width: 1.5),
              gradient: LinearGradient(colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.accent.withOpacity(0.2),
              ]),
            ),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Center(
                child: Icon(Icons.science, size: 32, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.appName,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Text(l10n.appTagline,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.subtitleAccent,
                  fontFamily: 'Inter')),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
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
              key: _loginKey,
              child: Column(
                children: [
                  CustomTextField(
                    label: l10n.emailLabel,
                    hint: l10n.emailHint,
                    controller: _emailCtrl,
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.isEmpty
                        ? l10n.emailRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: l10n.passwordLabel,
                    hint: l10n.passwordHint,
                    controller: _passCtrl,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) => v == null || v.isEmpty
                        ? l10n.passwordRequired
                        : null,
                  ),
                  const SizedBox(height: 24),
                  _gradientButton(l10n.loginButton, _login,
                      gradient: AppColors.primaryGradient),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: Divider(
                    color: AppColors.textSecondary.withOpacity(0.3))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(l10n.orContinueWith,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ),
            Expanded(
                child: Divider(
                    color: AppColors.textSecondary.withOpacity(0.3))),
          ]),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _googleLoading ? null : _loginGoogle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _googleLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('G',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4285F4))),
                        SizedBox(width: 10),
                        Text(l10n.continueWithGoogle,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                fontFamily: 'Inter')),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(l10n.noAccount,
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter')),
            GestureDetector(
              onTap: _openRegistration,
              child: Text(l10n.signUp,
                  style: TextStyle(
                      color: AppColors.accentText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Inter')),
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _gradientButton(String label, VoidCallback onTap,
      {required Gradient gradient}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter')),
      ),
    );
  }
}
