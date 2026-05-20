import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/portal/portal_scope.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../domain/models/app_portal.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/pressable_scale.dart';
import '../../home/providers/theme_provider.dart';
import '../widgets/auth_appearance_sheet.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _current = 0;
  final PageController _pageCtrl = PageController();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  final _storage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await activatePortal(context, AppPortal.auth);
    if (!mounted) return;
    final done = await _storage.isOnboardingCompleted();
    if (done && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await _storage.setOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _next(AppLocalizations l10n) {
    if (_current < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  List<({IconData icon, String title, String desc, Color color})> _slides(
    AppLocalizations l10n,
  ) =>
      [
        (
          icon: Icons.qr_code_scanner,
          title: l10n.onboardingTitle1,
          desc: l10n.onboardingDesc1,
          color: AppColors.primary,
        ),
        (
          icon: Icons.shopping_cart_outlined,
          title: l10n.onboardingTitle2,
          desc: l10n.onboardingDesc2,
          color: AppColors.secondary,
        ),
        (
          icon: Icons.science_outlined,
          title: l10n.onboardingTitle3,
          desc: l10n.onboardingDesc3,
          color: AppColors.accent,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final slides = _slides(l10n);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 40,
                left: -30,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.07),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: -40,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withOpacity(0.07),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            l10n.skip,
                            style: TextStyle(
                              color: AppColors.accentText,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const AuthSettingsButton(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageCtrl,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemCount: slides.length,
                      itemBuilder: (ctx, i) {
                        final s = slides[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ScaleTransition(
                                scale: _pulse,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        s.color.withOpacity(0.2),
                                        s.color.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: s.color.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: s.color.withOpacity(0.25),
                                        blurRadius: 30,
                                      ),
                                    ],
                                  ),
                                  child: Icon(s.icon, size: 56, color: s.color),
                                ),
                              ),
                              const SizedBox(height: 48),
                              Text(
                                s.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter',
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                s.desc,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Inter',
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(slides.length, (i) {
                            return GestureDetector(
                              onTap: () => _pageCtrl.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: i == _current ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: i == _current
                                      ? AppColors.cyanEmeraldGradient
                                      : null,
                                  color: i != _current
                                      ? AppColors.textSecondary
                                          .withOpacity(0.35)
                                      : null,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),
                        PressableScale(
                          onTap: () => _next(l10n),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: AppColors.cyanEmeraldGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _current < slides.length - 1
                                      ? l10n.next
                                      : l10n.getStarted,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
