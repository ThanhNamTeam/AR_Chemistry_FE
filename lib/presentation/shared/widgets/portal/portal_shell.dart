import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
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
                    : IndexedStack(index: selectedIndex, children: pages),
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
          // Logo app thay cho khối gradient + icon lọ hóa chất cũ (quá đậm,
          // tranh chú ý với tiêu đề portal).
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cardBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Image.asset(
              'assets/icon/app_icon.jpg',
              fit: BoxFit.cover,
            ),
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
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
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
            semanticLabel: AppLocalizations.of(context).profile,
          ),
          _HeaderIconButton(
            icon: Icons.logout_rounded,
            color: AppColors.error,
            onTap: onLogout,
            semanticLabel: AppLocalizations.of(context).logout,
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

  /// P2-8: nút chỉ có icon — screen reader cần nhãn mô tả hành động.
  final String? semanticLabel;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: c, size: 22),
          ),
        ),
      ),
    );
  }
}

class _PortalBottomNav extends StatefulWidget {
  final List<PortalNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _PortalBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<_PortalBottomNav> createState() => _PortalBottomNavState();
}

class _PortalBottomNavState extends State<_PortalBottomNav> {
  /// Dưới bề rộng này mỗi tab, chữ bắt đầu bị cắt ("Người d...") — lúc đó
  /// chuyển sang chế độ CUỘN NGANG thay vì chia đều ép chật.
  static const double _minItemWidth = 68;

  final ScrollController _scroll = ScrollController();
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
  }

  @override
  void didUpdateWidget(covariant _PortalBottomNav old) {
    super.didUpdateWidget(old);
    if (old.items.length != widget.items.length) {
      _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
    }
    if (old.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Cuộn tab đang chọn về giữa thanh — người dùng luôn thấy mình đang ở đâu,
  /// và thấy hé tab kế bên nên tự hiểu là thanh cuộn được.
  void _revealSelected() {
    if (!mounted || !_scroll.hasClients) return;
    final ctx = _itemKeys[widget.selectedIndex].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Đồng bộ với UserBottomNav: thanh phẳng full-width sát đáy, kẻ viền trên,
    // tab active đổi màu chữ + icon — bỏ thẻ nổi bo góc và pill gradient cũ
    // (khối xanh đặc quá đậm, lệch hẳn với cổng người dùng).
    return Material(
      color: AppColors.isLight ? Colors.white : AppColors.backgroundMid,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fits =
                  constraints.maxWidth >= widget.items.length * _minItemWidth;

              // Ít tab (staff): dàn đều kín thanh như trước.
              if (fits) {
                return Row(
                  children: List.generate(
                    widget.items.length,
                    (i) => Expanded(child: _buildItem(i, compactWidth: null)),
                  ),
                );
              }

              // Nhiều tab (admin 7 tab): cuộn ngang, mỗi tab đủ rộng cho nhãn.
              return SingleChildScrollView(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    widget.items.length,
                    (i) => _buildItem(i, compactWidth: _minItemWidth + 8),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int i, {required double? compactWidth}) {
    final item = widget.items[i];
    final selected = widget.selectedIndex == i;
    final color = selected ? AppColors.primary : AppColors.navMuted;

    return KeyedSubtree(
      key: _itemKeys[i],
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: InkWell(
          // InkWell thay GestureDetector để có phản hồi chạm (ripple),
          // giống hệt UserBottomNav.
          onTap: () => widget.onSelected(i),
          child: Container(
            width: compactWidth,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 24,
                  color: color,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                    fontFamily: 'Inter',
                    decoration: TextDecoration.none,
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
