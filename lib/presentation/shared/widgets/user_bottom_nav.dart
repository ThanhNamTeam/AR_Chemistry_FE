import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/navigation/current_route_observer.dart';
import '../../../domain/models/app_portal.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/app_state.dart';
import '../../home/providers/theme_provider.dart';

/// Thanh điều hướng dưới của cổng người dùng.
///
/// Trước đây thanh này được viết thẳng trong `HomeScreen` nên chỉ Home mới có.
/// Tách ra widget riêng để [UserPortalBottomNavShell] gắn được cho MỌI trang.
class UserBottomNav extends StatelessWidget {
  const UserBottomNav({super.key});

  /// Chiều cao phần nội dung (chưa tính safe area dưới).
  static const double contentHeight = 64;

  @override
  Widget build(BuildContext context) {
    // BẮT BUỘC theo dõi ThemeProvider: màu trong AppColors là biến static bị
    // ghi đè khi đổi theme, nên widget phải rebuild mới đọc được màu mới.
    // (Đi kèm: shell dựng `UserBottomNav()` KHÔNG có `const` — widget const bị
    // Flutter tái dùng nguyên instance nên build() không chạy lại, làm thanh
    // nav kẹt màu tối khi chuyển sang theme Sáng.)
    context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);
    // Thư viện đã gộp vào Cửa hàng (nút sách ở header Cửa hàng, và cả trong
    // Hồ sơ) để nhường chỗ cho Trang chủ — trước đây không có đường quay về
    // Home từ thanh nav.
    final items = <(IconData, String, String)>[
      (Icons.home_outlined, l10n.home, AppRoutes.home),
      (Icons.store_outlined, l10n.shop, AppRoutes.shop),
      (Icons.quiz_outlined, l10n.navQuiz, AppRoutes.quizList),
      (Icons.extension_outlined, l10n.navMiniGame, AppRoutes.miniGame),
    ];

    // BẮT BUỘC bọc Material: widget này sống trong `MaterialApp.builder`, tức
    // nằm NGOÀI Scaffold/Material. Text render ngoài Material sẽ bị Flutter vẽ
    // gạch chân vàng cảnh báo. Material cũng cấp nền cho hiệu ứng ripple.
    // Màu ĐẶC, không alpha: thanh nav nằm trong Column của shell nên phía sau
    // là Material trắng mặc định — nền dark 80% đè lên trắng sẽ ra xám nhạt
    // lệch hẳn với màn Home tối.
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
          child: Row(
            children: items.map((item) {
              return Expanded(
                child: Semantics(
                  button: true,
                  label: item.$2,
                  child: InkWell(
                    // InkWell thay GestureDetector để có phản hồi chạm (ripple).
                    onTap: () => _go(item.$3),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.$1, color: AppColors.primary, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            item.$2,
                            style: TextStyle(
                              // 11px + navMuted: 10px/textSecondary cũ dưới
                              // ngưỡng đọc được và thiếu tương phản.
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navMuted,
                              fontFamily: 'Inter',
                              // Ghi rõ để không phụ thuộc default style bên ngoài.
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Điều hướng tới [route]; nếu đang ở đúng trang đó thì bỏ qua để không
  /// chồng thêm cùng một màn lên stack.
  ///
  /// Phải push qua [AppNavigator] chứ KHÔNG dùng `Navigator.of(context)`:
  /// widget này sống trong `MaterialApp.builder` nên nằm TRÊN Navigator trong
  /// cây widget, context của nó không có Navigator tổ tiên.
  void _go(String route) {
    if (CurrentRouteObserver.routeName.value == route) return;

    // Trang chủ là gốc của cổng người dùng: dọn stack thay vì chồng thêm một
    // Home nữa lên trên (nếu không, bấm Trang chủ nhiều lần sẽ đẻ ra nhiều bản
    // Home và nút back phải bấm rất nhiều lần mới thoát được).
    if (route == AppRoutes.home) {
      AppNavigator.pushNamedAndRemoveAll(route);
      return;
    }

    AppNavigator.pushNamed(route);
  }
}

/// Gắn [UserBottomNav] vào ĐÁY MỌI TRANG của cổng người dùng.
///
/// Dùng [Column] chứ không phải [Stack]: thanh nav chiếm chỗ thật trong layout
/// nên không che mất nội dung cuối trang.
///
/// Thanh chỉ hiện khi: đang ở cổng người dùng, đã đăng nhập, và route hiện tại
/// không nằm trong [_fullScreenRoutes].
class UserPortalBottomNavShell extends StatelessWidget {
  const UserPortalBottomNavShell({super.key, required this.child});

  final Widget child;

  /// Các màn cần toàn màn hình hoặc nằm ngoài cổng người dùng — không hiện nav.
  static const Set<String> _fullScreenRoutes = {
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.verifyOtp,
    AppRoutes.completeProfile,
    AppRoutes.forgotPassword,
    AppRoutes.scan,
    AppRoutes.arAssetLoading,
    AppRoutes.staffHome,
    AppRoutes.adminHome,
    AppRoutes.portalProfile,
  };

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<ThemeProvider>().activePortal;
    final loggedIn = context.watch<AppState>().isLoggedIn;

    if (portal != AppPortal.user || !loggedIn) return child;

    return ValueListenableBuilder<String?>(
      valueListenable: CurrentRouteObserver.routeName,
      builder: (context, route, _) {
        final show = route != null && !_fullScreenRoutes.contains(route);
        if (!show) return child;

        return Column(
          children: [
            Expanded(child: child),
            // KHÔNG dùng `const`: widget const bị Flutter tái dùng nguyên
            // instance, nên khi shell rebuild lúc đổi theme thì build() của
            // thanh nav không chạy lại và nó kẹt màu của theme cũ.
            UserBottomNav(),
          ],
        );
      },
    );
  }
}
