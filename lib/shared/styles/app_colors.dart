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

  static const LinearGradient amberGradient = LinearGradient(
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
      backgroundDark = const Color(0xFFF8FAFC);
      backgroundMid = const Color(0xFFE2E8F0);
      backgroundBlue = const Color(0xFFDBEAFE);
      cardBg = const Color(0xFFFFFFFF);
      cardBorder = Color.lerp(primaryColor, Colors.grey, 0.5)!;
      textPrimary = const Color(0xFF0F172A);
      textSecondary = const Color(0xFF64748B);
      textCyan = primaryColor;
      textAmber = const Color(0xFFD97706);
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
    }

    primaryGradient = LinearGradient(
      colors: [primary, accentDark],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    cyanEmeraldGradient = LinearGradient(
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
}
