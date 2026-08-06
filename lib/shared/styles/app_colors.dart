import 'package:flutter/material.dart';

/// Theme-aware palette. Call [applyTheme] when the user changes theme.
class AppColors {
  static bool isLight = false;

  static Color backgroundDark = const Color(0xFF020817);
  static Color backgroundMid = const Color(0xFF0F172A);
  static Color backgroundBlue = const Color(0xFF0C1A33);

  static Color primary = const Color(0xFF06B6D4);
  static Color primaryLight = const Color(0xFF22D3EE);
  static Color primaryDark = const Color(0xFF0891B2);

  static Color secondary = const Color(0xFF10B981);
  static Color secondaryLight = const Color(0xFF34D399);
  static Color secondaryDark = const Color(0xFF059669);

  static Color accent = const Color(0xFF3B82F6);
  static Color accentLight = const Color(0xFF60A5FA);
  static Color accentDark = const Color(0xFF2563EB);

  static Color amber = const Color(0xFFF59E0B);
  static Color amberLight = const Color(0xFFFBBF24);
  static Color amberDark = const Color(0xFFD97706);

  static Color textPrimary = const Color(0xFFFFFFFF);
  static Color textSecondary = const Color(0xFF94A3B8);
  static Color textCyan = const Color(0xFF67E8F9);
  static Color textAmber = const Color(0xFFFCD34D);

  static Color cardBg = const Color(0xFF0F172A);
  static Color cardBorder = const Color(0xFF164E63);
  static Color surfaceOverlay = const Color(0x1A06B6D4);

  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  /// Màu chữ/icon đặt TRÊN các nền rực (primary/cyanEmerald/amber gradient).
  ///
  /// Dùng TRẮNG theo yêu cầu design (ink tối #0F172A bị chê đậm/nặng).
  /// Đánh đổi: trắng trên các gradient này chỉ đạt ~2,4-2,7:1 contrast
  /// (dưới chuẩn WCAG AA 4,5:1) — chấp nhận vì ưu tiên cảm quan thương hiệu.
  static const Color onGradient = Color(0xFFFFFFFF);

  /// Màu ĐỊNH DANH của Knowledge Point — cố định vàng/gold ở MỌI theme
  /// (P2-7 audit UX). Không dùng dải `amber` vì theme Light ghi đè dải đó
  /// sang xanh; KP đổi màu theo theme khiến "đơn vị tiền tệ" mất nhận diện.
  /// kpGold dùng trên nền sáng (4,8:1 trên trắng), kpGoldBright trên nền tối.
  static const Color kpGold = Color(0xFFB45309);
  static const Color kpGoldBright = Color(0xFFFBBF24);
  static const Color kpGoldBorder = Color(0xFFF59E0B);

  /// Thang bo góc 3 nấc (P2-6 audit UX): phần tử nhỏ (chip/input/nút vuông),
  /// thẻ/card, và pill tròn hoàn toàn. Không thêm nấc mới ngoài 3 nấc này.
  static const double radiusSm = 12;
  static const double radiusCard = 16;
  static const double radiusPill = 999;

  static LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient cyanEmeraldGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF020817), Color(0xFF0C1A33), Color(0xFF020817)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // KHÔNG const: theme Light đổi dải "amber" (nút Nâng cấp, badge KP) sang
  // xanh của bộ màu để toàn màn một tông; theme tối giữ cam. Gán lại trong
  // [applyTheme].
  static LinearGradient amberGradient = const LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static void applyTheme({
    required Color primaryColor,
    required Color accentColor,
    required bool light,
    bool useAccentAsSecondary = false,
  }) {
    isLight = light;
    primary = primaryColor;
    accent = accentColor;
    primaryLight = Color.lerp(primaryColor, Colors.white, 0.25)!;
    primaryDark = Color.lerp(primaryColor, Colors.black, 0.2)!;
    secondary = useAccentAsSecondary
        ? accentColor
        : const Color(0xFF10B981);
    secondaryLight = Color.lerp(secondary, Colors.white, 0.2)!;
    secondaryDark = Color.lerp(secondary, Colors.black, 0.15)!;
    accentLight = Color.lerp(accent, Colors.white, 0.25)!;
    accentDark = Color.lerp(accent, Colors.black, 0.2)!;

    if (isLight) {
      // Dải xanh thiết kế: #27A4F2 #3EAEF4 #6EC2F7 #9FD7F9 #CFEBFC.
      // Nền dùng ĐƠN MÀU rất nhạt (trắng ngả xanh) để nội dung nổi;
      // #CFEBFC làm lớp giữa của gradient nền, #9FD7F9 làm viền thẻ.
      backgroundDark = const Color(0xFFF5FAFE);
      backgroundMid = const Color(0xFFE7F4FD);
      backgroundBlue = const Color(0xFFCFEBFC);
      cardBg = const Color(0xFFFFFFFF);
      cardBorder = const Color(0xFF9FD7F9);
      textPrimary = const Color(0xFF0F172A);
      textSecondary = const Color(0xFF475569);
      // Chữ nhấn phải sẫm hơn #27A4F2 mới đủ tương phản trên nền trắng.
      textCyan = Color.lerp(primaryColor, const Color(0xFF0F172A), 0.45)!;
      primaryLight = primaryDark;
      secondaryLight = secondaryDark;

      // Dải "amber" (nút Nâng cấp, badge KP) chuyển sang xanh cùng bộ —
      // Light không còn màu cam lệch tông.
      amber = const Color(0xFF27A4F2);
      amberLight = const Color(0xFF6EC2F7);
      amberDark = const Color(0xFF1B87D6);
      textAmber = Color.lerp(const Color(0xFF27A4F2), const Color(0xFF0F172A), 0.45)!;
      amberGradient = const LinearGradient(
        colors: [Color(0xFF27A4F2), Color(0xFF3EAEF4)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else {
      backgroundDark = const Color(0xFF020817);
      backgroundMid = const Color(0xFF0F172A);
      backgroundBlue = _tintBackground(primaryColor);
      cardBg = const Color(0xFF0F172A);
      cardBorder = Color.lerp(primaryColor, const Color(0xFF164E63), 0.4)!;
      textPrimary = const Color(0xFFFFFFFF);
      textSecondary = const Color(0xFF94A3B8);
      textCyan = Color.lerp(primaryColor, Colors.white, 0.55)!;
      textAmber = const Color(0xFFFCD34D);

      // Khôi phục dải cam mặc định — các field này là static bị nhánh light
      // ghi đè, không trả lại thì đổi Light -> Dark sẽ kẹt màu xanh.
      amber = const Color(0xFFF59E0B);
      amberLight = const Color(0xFFFBBF24);
      amberDark = const Color(0xFFD97706);
      amberGradient = const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }

    primaryGradient = LinearGradient(
      colors: [primary, accentDark],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    // Gradient CTA: Light đi trong dải xanh (#27A4F2 -> #3EAEF4) cho đồng
    // bộ; theme tối giữ xanh->lục đặc trưng cũ.
    cyanEmeraldGradient = isLight
        ? LinearGradient(
            colors: [primary, accent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        : LinearGradient(
            colors: [primary, secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );
    backgroundGradient = LinearGradient(
      colors: [backgroundDark, backgroundBlue, backgroundDark],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static Color _tintBackground(Color c) {
    return Color.alphaBlend(c.withOpacity(0.12), const Color(0xFF020817));
  }

  /// Solid card surface — avoids dark glass on light backgrounds.
  static Color get cardSurface =>
      isLight ? const Color(0xFFFFFFFF) : cardBg.withOpacity(0.55);

  static Color get cardSurfaceMuted =>
      isLight ? const Color(0xFFF1F5F9) : cardBg.withOpacity(0.45);

  /// Links, badges, action labels on light UI.
  static Color get accentText => isLight ? primaryDark : primaryLight;

  /// Email / metadata subtitles.
  static Color get subtitleAccent => isLight ? textCyan : textCyan;

  /// Positive highlights (revenue, success values).
  static Color get emphasisPositive => isLight ? secondaryDark : secondaryLight;

  /// Bottom nav & chips — unselected label/icon.
  static Color get navMuted => isLight ? const Color(0xFF64748B) : textSecondary;

  static Color get navBarBg =>
      isLight ? const Color(0xFFFFFFFF) : cardBg.withOpacity(0.92);

  static Color get shadowSoft => isLight
      ? Colors.black.withOpacity(0.08)
      : Colors.black.withOpacity(0.25);

  static Color get shadowCard => isLight
      ? Colors.black.withOpacity(0.06)
      : AppColors.primary.withOpacity(0.06);

  static Color substanceStateColor(String? state) {
    switch (state?.toUpperCase()) {
      case 'SOLID':
        return const Color(0xFF8B5CF6);
      case 'LIQUID':
        return const Color(0xFF38BDF8);
      case 'GAS':
        return amber;
      case 'AQUEOUS':
        return secondary;
      default:
        return primary;
    }
  }

  static LinearGradient substanceStateGradient(String? state) {
    final color = substanceStateColor(state);

    return LinearGradient(
      colors: [
        color,
        Color.lerp(color, backgroundDark, isLight ? 0.12 : 0.28)!,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color substanceStateSurface(String? state) {
    final color = substanceStateColor(state);

    return color.withOpacity(isLight ? 0.12 : 0.16);
  }

  static Color substanceStateBorder(String? state) {
    final color = substanceStateColor(state);

    return color.withOpacity(isLight ? 0.35 : 0.45);
  }
}

