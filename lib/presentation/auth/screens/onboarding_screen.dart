import 'package:flutter/material.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../routes/app_routes.dart';

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

  static const _slides = [
    (Icons.qr_code_scanner, 'Scan Chemical Cards',
        'Use AR technology to scan physical chemistry cards and bring molecules to life in 3D',
        AppColors.primary),
    (Icons.shopping_cart_outlined, 'Build Your Collection',
        'Purchase chemical cards from our store. Unlock new elements and compounds for your experiments',
        AppColors.secondary),
    (Icons.science_outlined, 'Run Virtual Experiments',
        'Combine chemicals in AR to trigger reactions, earn knowledge points, and learn chemistry',
        AppColors.accent),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _slides.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // bg blobs
              Positioned(
                top: 40, left: -30,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 220, height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.07),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 100, right: -40,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 260, height: 260,
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
                  // Skip
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.login),
                      child: const Text('Skip',
                          style: TextStyle(
                              color: AppColors.primaryLight,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500)),
                    ),
                  ),

                  // Pages
                  Expanded(
                    child: PageView.builder(
                      controller: _pageCtrl,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemCount: _slides.length,
                      itemBuilder: (ctx, i) {
                        final s = _slides[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ScaleTransition(
                                scale: _pulse,
                                child: Container(
                                  width: 120, height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      s.$4.withOpacity(0.2),
                                      s.$4.withOpacity(0.05),
                                    ]),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                        color: s.$4.withOpacity(0.4), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: s.$4.withOpacity(0.25),
                                          blurRadius: 30)
                                    ],
                                  ),
                                  child: Icon(s.$1, size: 56, color: s.$4),
                                ),
                              ),
                              const SizedBox(height: 48),
                              ShaderMask(
                                shaderCallback: (b) =>
                                    AppColors.cyanEmeraldGradient.createShader(b),
                                child: Text(s.$2,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                        height: 1.25)),
                              ),
                              const SizedBox(height: 20),
                              Text(s.$3,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondary,
                                      fontFamily: 'Inter',
                                      height: 1.6)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Dots + button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_slides.length, (i) {
                            return GestureDetector(
                              onTap: () => _pageCtrl.animateToPage(i,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: i == _current ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: i == _current
                                      ? AppColors.cyanEmeraldGradient
                                      : null,
                                  color: i != _current
                                      ? AppColors.textSecondary.withOpacity(0.3)
                                      : null,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: _next,
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
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _current < _slides.length - 1
                                      ? 'Next'
                                      : 'Get Started',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter'),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right,
                                    color: Colors.white, size: 20),
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
