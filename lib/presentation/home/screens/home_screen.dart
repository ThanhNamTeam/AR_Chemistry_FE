import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/ar_access_api.dart';
import '../../../core/storage/avatar_storage_service.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../../domain/models/app_portal.dart';
import '../../../domain/models/login_route_args.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import '../../../core/portal/portal_scope.dart';
import '../../home/providers/theme_provider.dart';
import '../widgets/themed_home_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulse1;
  final ArAccessApi _arAccessApi = ArAccessApi();
  bool _checkingArAccess = false;
  late AnimationController _pulse2;

  Future<void> _openARScanner() async {
    Navigator.pushNamed(context, AppRoutes.scan);
  }



  @override
  void initState() {
    super.initState();
    _pulse1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      activatePortal(context, AppPortal.user);
      _showWelcomeMessage();
    });
  }

  void _showWelcomeMessage() {
    if (!mounted) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! HomeRouteArgs || args.welcomeMessage == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          args.welcomeMessage!,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _pulse1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ThemedHomeBackground(),
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
    );
  }

  Widget _buildHeader(AppState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildProfileAvatar(state),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              KnowledgePointsBadge(
                points: state.knowledgePoints,
                compact: true,
              ),
              const SizedBox(width: 8),
              _buildUpgradeButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.packages),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: AppColors.amberGradient,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.amberLight.withOpacity(0.7),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.amberLight.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 5),
            Text(
              'Upgrade',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(AppState state) {
    final avatar = state.userAvatar;

    final isNetworkAvatar = avatar != null &&
        (avatar.startsWith('http://') || avatar.startsWith('https://'));

    final hasLocalAvatar = avatar != null &&
        !isNetworkAvatar &&
        AvatarStorageService.avatarFileExists(avatar);

    final hasAvatar = isNetworkAvatar || hasLocalAvatar;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasAvatar ? null : AppColors.cyanEmeraldGradient,
          image: hasAvatar
              ? DecorationImage(
            image: isNetworkAvatar
                ? NetworkImage(avatar)
                : FileImage(File(avatar!)) as ImageProvider,
            fit: BoxFit.cover,
          )
              : null,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: hasAvatar
            ? null
            : Center(
          child: Text(
            state.displayName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const Spacer(flex: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: GestureDetector(
            onTap: _openARScanner,
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
                      blurRadius: 16 + 8 * _pulse1.value,
                    ),
                  ],
                ),
                child: child,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: AppColors.cyanEmeraldGradient,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 1.2,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_checkingArAccess)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(Icons.view_in_ar, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Icon(Icons.view_in_ar, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Start AR Experiment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
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
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Scan chemical flashcards to witness amazing reactions in augmented reality',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.isLight
                  ? AppColors.textPrimary
                  : Colors.white,
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.menu_book_outlined, 'Library', AppRoutes.library),
      (Icons.store_outlined, 'Shop', AppRoutes.shop),
      (Icons.shopping_cart_outlined, 'Cart', AppRoutes.cart),
      (Icons.quiz_outlined, 'Quiz', AppRoutes.quizList),
      (Icons.extension_outlined, 'Mini Game', AppRoutes.miniGame),
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
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

}
