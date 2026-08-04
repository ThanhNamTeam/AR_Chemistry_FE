import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() =>
      _VerifyOtpScreenState();
}

class _VerifyOtpScreenState
    extends State<VerifyOtpScreen>
    with TickerProviderStateMixin {

  static const int _otpLength = 6;
  static const int _resendCooldownSeconds = 60;

  final _otpCtrl = TextEditingController();

  bool _loading = false;
  int _resendRemaining = 0;
  Timer? _resendTimer;

  late AnimationController _bgCtrl;
  late Animation<double> _bgPulse;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _bgPulse = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _bgCtrl,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  /// Chặn bấm "Gửi lại mã" liên tục — Cognito sẽ rate-limit và trả lỗi khó
  /// hiểu. Đếm ngược hiển thị ngay trên nút.
  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendRemaining = _resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendRemaining--;
        if (_resendRemaining <= 0) t.cancel();
      });
    });
  }

  Future<void> _verify() async {

    final email =
    ModalRoute.of(context)!
        .settings
        .arguments as String;

    if (_otpCtrl.text.trim().isEmpty) {
      return;
    }

    setState(() => _loading = true);

    try {

      await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode:
        _otpCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'Xác thực thành công!',
          ),
          backgroundColor:
          AppColors.success,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
            (_) => false,
      );

    } on AuthException catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor:
          AppColors.error,
        ),
      );

    } finally {

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    if (_resendRemaining > 0) return;

    final email =
    ModalRoute.of(context)!
        .settings
        .arguments as String;

    _startResendCooldown();

    try {

      await Amplify.Auth.resendSignUpCode(
        username: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'Đã gửi lại mã OTP',
          ),
          backgroundColor:
          AppColors.success,
        ),
      );

    } on AuthException catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor:
          AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      AppColors.backgroundDark,

      body: Container(
        decoration: BoxDecoration(
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

        child: Stack(
          children: [

            _buildBgBlobs(),

            SafeArea(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.all(24),

                child: Column(
                  children: [

                    const SizedBox(height: 50),

                    Container(
                      padding:
                      const EdgeInsets.all(4),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary
                              .withOpacity(0.5),
                          width: 1.5,
                        ),
                        gradient:
                        LinearGradient(
                          colors: [
                            AppColors.primary
                                .withOpacity(0.2),
                            AppColors.accent
                                .withOpacity(0.2),
                          ],
                        ),
                      ),

                      child: Container(
                        width: 72,
                        height: 72,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                          AppColors.primaryGradient,
                        ),

                        child: const Center(
                          child: Icon(
                            Icons.verified_user,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Xác thực OTP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Nhập mã xác thực được gửi qua email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                        AppColors.textCyan,
                        fontFamily: 'Inter',
                      ),
                    ),

                    const SizedBox(height: 36),

                    Container(
                      padding:
                      const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        color: AppColors.cardBg
                            .withOpacity(0.5),

                        borderRadius:
                        BorderRadius.circular(16),

                        border: Border.all(
                          color: AppColors.primary
                              .withOpacity(0.3),
                          width: 1.5,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                            AppColors.primary
                                .withOpacity(
                                0.1),
                            blurRadius: 30,
                          ),
                        ],
                      ),

                      child: Column(
                        children: [

                          CustomTextField(
                            label: 'Mã OTP',
                            hint: 'Nhập mã 6 số',
                            controller: _otpCtrl,
                            prefixIcon:
                            Icons.lock_clock,
                            keyboardType:
                            TextInputType.number,
                            maxLength: _otpLength,
                            autofillHints: const [
                              AutofillHints.oneTimeCode,
                            ],
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly,
                            ],
                            // Tự gửi khi nhập đủ 6 số — người dùng không phải
                            // tìm nút Verify sau khi bàn phím tự điền mã.
                            onChanged: (value) {
                              if (value.length == _otpLength &&
                                  !_loading) {
                                _verify();
                              }
                            },
                          ),

                          const SizedBox(height: 24),

                          GestureDetector(
                            onTap:
                            _loading
                                ? null
                                : _verify,

                            child: Container(
                              width:
                              double.infinity,

                              padding:
                              const EdgeInsets
                                  .symmetric(
                                vertical: 16,
                              ),

                              decoration:
                              BoxDecoration(
                                gradient:
                                AppColors
                                    .primaryGradient,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                    12),

                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    AppColors
                                        .primary
                                        .withOpacity(
                                        0.35),

                                    blurRadius:
                                    16,

                                    offset:
                                    const Offset(
                                        0,
                                        4),
                                  )
                                ],
                              ),

                              child: Center(
                                child:
                                _loading
                                    ? const SizedBox(
                                  width:
                                  22,
                                  height:
                                  22,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth:
                                    2,
                                    color:
                                    Colors.white,
                                  ),
                                )
                                    : const Text(
                                  'Xác thực',
                                  style:
                                  TextStyle(
                                    color:
                                    Colors.white,
                                    fontSize:
                                    16,
                                    fontWeight:
                                    FontWeight.w600,
                                    fontFamily:
                                    'Inter',
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed:
                            _resendRemaining > 0
                                ? null
                                : _resendCode,
                            child: Text(
                              _resendRemaining > 0
                                  ? 'Gửi lại mã sau ${_resendRemaining}s'
                                  : 'Gửi lại mã',
                              style: TextStyle(
                                color: _resendRemaining > 0
                                    ? AppColors.textSecondary
                                    : AppColors.primaryLight,
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 13,
                                fontFamily:
                                'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

                    color: AppColors.primary
                        .withOpacity(0.05),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 60,
              right: -60,

              child: Transform.scale(
                scale:
                1.1 -
                    0.1 *
                        _bgPulse.value,

                child: Container(
                  width: 300,
                  height: 300,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: AppColors.accent
                        .withOpacity(0.05),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}