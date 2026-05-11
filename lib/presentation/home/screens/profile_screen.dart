import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: AppColors.primary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text('Profile',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter')),
                    ],
                  ),
                ),

                // Avatar + name
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.secondary.withOpacity(0.15),
                    ]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.cyanEmeraldGradient,
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 20)
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (state.userName ?? 'S').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Inter'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(state.userName ?? 'Student',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter')),
                      const SizedBox(height: 4),
                      Text(state.userEmail ?? '',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter')),
                      const SizedBox(height: 16),
                      KnowledgePointsBadge(points: state.knowledgePoints),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _StatCard(
                        icon: Icons.menu_book_outlined,
                        label: 'Cards',
                        value: '${state.unlockedCards.length}',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.science_outlined,
                        label: 'Elements',
                        value: '${state.cards.length}',
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.auto_awesome,
                        label: 'KP',
                        value: '${state.knowledgePoints}',
                        color: AppColors.amber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Menu items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: Icons.menu_book_outlined,
                        label: 'My Library',
                        subtitle: '${state.unlockedCards.length} cards unlocked',
                        color: AppColors.primary,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.library),
                      ),
                      const SizedBox(height: 10),
                      _MenuItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'My Bag',
                        subtitle: 'View your purchased cards',
                        color: AppColors.secondary,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.myBag),
                      ),
                      const SizedBox(height: 10),
                      _MenuItem(
                        icon: Icons.store_outlined,
                        label: 'Shop',
                        subtitle: 'Buy new chemical cards',
                        color: AppColors.accent,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.shop),
                      ),
                      const SizedBox(height: 10),
                      _MenuItem(
                        icon: Icons.qr_code_scanner,
                        label: 'AR Scanner',
                        subtitle: 'Scan your chemical cards',
                        color: AppColors.accentLight,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.scan),
                      ),
                      const SizedBox(height: 24),

                      // Logout
                      GestureDetector(
                        onTap: () {
                          state.logout();
                          Navigator.pushNamedAndRemoveUntil(
                              context, AppRoutes.login, (r) => false);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: AppColors.error, size: 20),
                              SizedBox(width: 10),
                              Text('Logout',
                                  style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Inter')),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter')),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter')),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
