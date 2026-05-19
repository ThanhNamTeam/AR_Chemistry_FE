import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/locale_provider.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../home/providers/theme_provider.dart';

class PortalNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const PortalNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Shell layout for Staff / Admin portals: header + pages + bottom nav.
class PortalShell extends StatelessWidget {
  final String portalTitle;
  final String roleBadge;
  final String userEmail;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<PortalNavItem> navItems;
  final List<Widget> pages;
  final VoidCallback onProfile;
  final VoidCallback onLogout;
  final bool isLoading;

  const PortalShell({
    super.key,
    required this.portalTitle,
    required this.roleBadge,
    required this.userEmail,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.navItems,
    required this.pages,
    required this.onProfile,
    required this.onLogout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _PortalHeader(
                portalTitle: portalTitle,
                roleBadge: roleBadge,
                userEmail: userEmail,
                onProfile: onProfile,
                onLogout: onLogout,
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : IndexedStack(
                        index: selectedIndex,
                        children: pages,
                      ),
              ),
              _PortalBottomNav(
                items: navItems,
                selectedIndex: selectedIndex,
                onSelected: onTabSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortalHeader extends StatelessWidget {
  final String portalTitle;
  final String roleBadge;
  final String userEmail;
  final VoidCallback onProfile;
  final VoidCallback onLogout;

  const _PortalHeader({
    required this.portalTitle,
    required this.roleBadge,
    required this.userEmail,
    required this.onProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.science, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        portalTitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        roleBadge,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentText,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subtitleAccent,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: Icons.person_outline_rounded,
            onTap: onProfile,
          ),
          _HeaderIconButton(
            icon: Icons.logout_rounded,
            color: AppColors.error,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.withOpacity(0.25)),
          ),
          child: Icon(icon, color: c, size: 22),
        ),
      ),
    );
  }
}

class _PortalBottomNav extends StatelessWidget {
  final List<PortalNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _PortalBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.navBarBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withOpacity(AppColors.isLight ? 0.22 : 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final selected = selectedIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.primaryGradient : null,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.activeIcon : item.icon,
                        size: 22,
                        color: selected
                            ? Colors.white
                            : AppColors.navMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.navMuted,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
