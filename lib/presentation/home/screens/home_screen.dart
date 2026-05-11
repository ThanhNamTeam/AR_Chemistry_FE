import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulse1;
  late AnimationController _pulse2;

  @override
  void initState() {
    super.initState();
    _pulse1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse1.dispose();
    _pulse2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Bg blobs
            _buildBlobs(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(state),
                  Expanded(child: _buildBody()),
                  _buildBottomNav(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.userName ?? 'Student',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          KnowledgePointsBadge(points: state.knowledgePoints),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Test tube visual
        _buildLabVisual(),
        const SizedBox(height: 48),

        // AR button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.scan),
            child: AnimatedBuilder(
              animation: _pulse1,
              builder: (_, child) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(
                        0.3 + 0.2 * _pulse1.value,
                      ),
                      blurRadius: 24 + 12 * _pulse1.value,
                    ),
                  ],
                ),
                child: child,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: AppColors.cyanEmeraldGradient,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.view_in_ar, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Start AR Experiment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Scan chemical flashcards to witness amazing reactions in augmented reality',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabVisual() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Glow under tubes
          Positioned(
            bottom: 0,
            child: AnimatedBuilder(
              animation: _pulse1,
              builder: (_, __) => Container(
                width: 220,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(
                        0.15 + 0.1 * _pulse1.value,
                      ),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTube(60, 110, AppColors.primary, 0.0),
              const SizedBox(width: 20),
              _buildTube(72, 148, AppColors.accent, 0.5),
              const SizedBox(width: 20),
              _buildTube(60, 96, AppColors.secondary, 1.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTube(double w, double h, Color color, double delay) {
    return AnimatedBuilder(
      animation: _pulse2,
      builder: (_, __) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Mouth ring
            Container(
              width: w * 0.55,
              height: w * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.6), width: 2),
                color: AppColors.backgroundDark,
              ),
            ),
            // Tube body
            Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(999),
                  bottomRight: Radius.circular(999),
                ),
                border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1 + 0.1 * _pulse2.value),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: h * 0.6,
                    child: AnimatedBuilder(
                      animation: _pulse2,
                      builder: (_, __) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.4 + 0.3 * _pulse2.value),
                              color,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(999),
                            bottomRight: Radius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Shine
                  Positioned(
                    top: 10,
                    left: 6,
                    child: Container(
                      width: 6,
                      height: h * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.menu_book_outlined, 'Library', AppRoutes.library),
      (Icons.store_outlined, 'Shop', AppRoutes.shop),
      (Icons.shopping_cart_outlined, 'Cart', AppRoutes.cart),
      (Icons.shopping_bag_outlined, 'My Bag', AppRoutes.myBag),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, item.$3),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.$1, color: AppColors.primary, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBlobs() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 80,
            left: 10,
            child: AnimatedBuilder(
              animation: _pulse1,
              builder: (_, __) => Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(
                    0.04 + 0.03 * _pulse1.value,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 10,
            child: AnimatedBuilder(
              animation: _pulse2,
              builder: (_, __) => Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(
                    0.04 + 0.03 * _pulse2.value,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
