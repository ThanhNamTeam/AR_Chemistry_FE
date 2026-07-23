import 'dart:async';
import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/portal/portal_scope.dart';
import '../../../domain/models/app_portal.dart';
import '../../../domain/models/login_route_args.dart';
import '../../../domain/models/user_role.dart';
import '../../../services/notification_service.dart';
import '../../home/providers/theme_provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/role_session_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/gradient_primary_button.dart';
import '../../../shared/widgets/pressable_scale.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../widgets/auth_appearance_sheet.dart';
import '../widgets/auth_app_logo_badge.dart';
import '../widgets/cyber_beam_border.dart';
import '../widgets/cyber_login_frame.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/api/notification_token_api.dart';

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
  bool _loginMessageShown = false;
  bool _googleLoading = false;
  bool _loggingIn = false;

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
      _showLoginSuccessMessage();
    });
  }

  void _showLoginSuccessMessage() {
    if (_loginMessageShown || !mounted) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! LoginRouteArgs) return;

    final l10n = AppLocalizations.of(context);
    String? message;
    if (args.registrationSuccess) {
      message = l10n.registrationSuccessLogin;
    } else if (args.passwordResetSuccess) {
      message = l10n.passwordResetSuccessLogin;
    }
    if (message == null) return;

    _loginMessageShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Inter')),
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

    // Student session chỉ lưu trong AppState, không qua RoleSessionProvider.
    if (roleSession.role == UserRole.student) {
      await roleSession.clearLocalSessionOnly();
    }

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

    if (!state.initialized) {
      await state.initialize();
    }

    if (mounted && state.isLoggedIn) {
      await activatePortal(context, AppPortal.user);
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.home);

      // Đợi Home dựng xong rồi mới xử lý notification pending
      Future.delayed(const Duration(milliseconds: 500), () {
        NotificationService.instance.handlePendingNavigationAfterLoginReady();
      });
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _goHome(String welcome) async {

    await AppNavigator.pushNamedAndRemoveAll(
      AppRoutes.home,
      arguments: HomeRouteArgs(welcomeMessage: welcome),
    );

    NotificationService.instance.handlePendingNavigationAfterLoginReady();
  }

  Future<void> _registerFcmTokenAfterLogin() async {
    try {
      final fcmToken = await NotificationService.instance.getFcmToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      await NotificationTokenApi().registerFcmToken(
        fcmToken: fcmToken,
        deviceName: 'Android Device',
      );

    } catch (e) {
      debugPrint('Register FCM token failed: $e');
    }
  }

  Future<void> _setupNotificationAfterLogin() async {
    await _registerFcmTokenAfterLogin();

    NotificationService.instance.startTokenRefreshListener(
      onRefresh: (newToken) async {
        await NotificationTokenApi().registerFcmToken(
          fcmToken: newToken,
          deviceName: 'Android Device',
        );

      },
    );
  }

  Future<void> _navigateAfterLogin({
    required UserRole role,
    required String email,
    required String idToken,
  }) async {

    unawaited(_setupNotificationAfterLogin());

    final roleSession = context.read<RoleSessionProvider>();
    final appState = context.read<AppState>();

    if (role == UserRole.admin) {
      await roleSession.saveSession(role: role, email: email);
      await activatePortal(context, AppPortal.admin);
      await AppNavigator.pushNamedAndRemoveAll(AppRoutes.adminHome);
      return;
    }

    if (role == UserRole.staff) {
      await roleSession.saveSession(role: role, email: email);
      await activatePortal(context, AppPortal.staff);
      await AppNavigator.pushNamedAndRemoveAll(AppRoutes.staffHome);
      return;
    }

    await roleSession.clearLocalSessionOnly();
    if (!appState.initialized) {
      await appState.initialize();
    }

    final result = await appState.establishCognitoSession(
      email: email,
      idToken: idToken,
    );


    await activatePortal(context, AppPortal.user);

    final welcome = result.isFirstLogin
        ? 'Đăng nhập thành công! Chào mừng ${result.displayName}!'
        : 'Chào mừng bạn trở lại, ${result.displayName}!';

    await _goHome(welcome);

    unawaited(
      AuthApi().syncUser(idToken).catchError((Object e) {
      }),
    );
  }

  void _unfocusKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Map<String, dynamic> _decodeJwtClaims(String idToken) {
    final parts = idToken.split('.');
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    return jsonDecode(payload) as Map<String, dynamic>;
  }

  UserRole _roleFromClaims(Map<String, dynamic> claims) {
    final groups = (claims['cognito:groups'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    if (groups.contains('ROLE_ADMIN')) return UserRole.admin;
    if (groups.contains('ROLE_STAFF')) return UserRole.staff;
    return UserRole.student;
  }

  String _emailFromClaims(Map<String, dynamic> claims, {String? fallback}) {
    return (claims['email'] as String?)?.trim() ??
        (claims['username'] as String?)?.trim() ??
        fallback ??
        '';
  }

  Future<CognitoAuthSession> _requireSignedInSession() async {
    final session =
        await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    if (!session.isSignedIn) {
      throw StateError('Not signed in');
    }
    return session;
  }

  Future<void> _finishLoginWithSession({
    required CognitoAuthSession session,
    required String requestedEmail,
  }) async {
    final idToken = session.userPoolTokensResult.value.idToken.raw;
    final claims = _decodeJwtClaims(idToken);

    final groups = (claims['cognito:groups'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final email = _emailFromClaims(claims, fallback: requestedEmail);
    await _navigateAfterLogin(
      role: _roleFromClaims(claims),
      email: email.isNotEmpty ? email : requestedEmail,
      idToken: idToken,
    );
  }

  Future<void> _login() async {
    if (_loggingIn) return;
    _unfocusKeyboard();

    if (!_loginKey.currentState!.validate()) {
      return;
    }

    setState(() => _loggingIn = true);

    try {
      final requestedEmail = _emailCtrl.text.trim();
      final password = _passCtrl.text;

      var session =
      await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

      if (session.isSignedIn) {
        final idToken = session.userPoolTokensResult.value.idToken.raw;
        final sessionEmail =
        _emailFromClaims(_decodeJwtClaims(idToken)).toLowerCase();

        if (sessionEmail == requestedEmail.toLowerCase()) {
          await AuthApi().syncUser(idToken);

          await _finishLoginWithSession(
            session: session,
            requestedEmail: requestedEmail,
          );
          return;
        }

        await Amplify.Auth.signOut();
        session =
        await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      }

      if (!session.isSignedIn) {
        final result = await Amplify.Auth.signIn(
          username: requestedEmail,
          password: password,
        );

        if (!result.isSignedIn) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Đăng nhập chưa hoàn tất. Kiểm tra OTP hoặc mật khẩu.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      session = await _requireSignedInSession();

      final idToken = session.userPoolTokensResult.value.idToken.raw;

      await AuthApi().syncUser(idToken);

      await _finishLoginWithSession(
        session: session,
        requestedEmail: requestedEmail,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      final msg = e.message.toLowerCase();

      if (msg.contains('already signed in')) {
        try {
          final session = await _requireSignedInSession();
          final idToken = session.userPoolTokensResult.value.idToken.raw;

          await AuthApi().syncUser(idToken);

          await _finishLoginWithSession(
            session: session,
            requestedEmail: _emailCtrl.text.trim(),
          );
          return;
        } catch (_) {
          // fall through to show original error
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loggingIn = false);
    }
  }

  Future<void> _loginGoogle() async {
    if (_googleLoading) return;

    setState(() => _googleLoading = true);

    try {
      // Login Google bằng Cognito Hosted UI
      final result = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
      );

      if (!result.isSignedIn) return;

      // Lấy session Cognito
      final session =
      await Amplify.Auth.fetchAuthSession()
      as CognitoAuthSession;

      // Lấy JWT token
      final idToken =
          session.userPoolTokensResult
              .value
              .idToken
              .raw;

      // Decode token để lấy email
      final parts = idToken.split('.');

      final payload = utf8.decode(
        base64Url.decode(
          base64Url.normalize(parts[1]),
        ),
      );

      final claims =
      jsonDecode(payload)
      as Map<String, dynamic>;

      final email =
          claims['email'] as String? ?? '';

      if (email.isEmpty) {
        throw Exception(
          'Google account has no email',
        );
      }

      // Sync user từ Cognito -> Backend
      try {
        await AuthApi().syncUser(idToken);
      } catch (e) {
        debugPrint('SYNC USER FAILED, CONTINUE LOGIN: $e');
      }

      if (!mounted) return;

      // Navigate sau login
      await _navigateAfterLogin(
        role: UserRole.student,
        email: email,
        idToken: idToken,
      );

    } on Exception catch (e) {

      debugPrint(
        'Google sign in failed: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Đăng nhập Google thất bại',
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(
              () => _googleLoading = false,
        );
      }
    }
  }

  void _openRegistration() {
    Navigator.pushNamed(context, AppRoutes.completeProfile);
  }

  void _openForgotPassword() {
    _unfocusKeyboard();
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
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
          const AuthAppLogoBadge(),
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
          CyberLoginFrame(
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
                    textInputAction: TextInputAction.next,
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
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_loggingIn) _login();
                    },
                    validator: (v) => v == null || v.isEmpty
                        ? l10n.passwordRequired
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PressableScale(
                      onTap: _openForgotPassword,
                      child: Text(
                        l10n.forgotPassword,
                        style: TextStyle(
                          color: AppColors.accentText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CyberBeamBorder(
                    child: GradientPrimaryButton(
                      label: _loggingIn ? l10n.loggingIn : l10n.loginButton,
                      loading: _loggingIn,
                      onTap: _loggingIn ? null : _login,
                    ),
                  ),
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
          CyberBeamBorder(
            child: PressableScale(
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
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(l10n.noAccount,
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter')),
            PressableScale(
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
}
