import 'package:flutter/material.dart';

class AppColors {
  // Background gradient colors
  static const Color backgroundDark = Color(0xFF020817);   // slate-950
  static const Color backgroundMid = Color(0xFF0F172A);    // slate-900
  static const Color backgroundBlue = Color(0xFF0C1A33);   // blue-950

  // Primary - Cyan
  static const Color primary = Color(0xFF06B6D4);         // cyan-500
  static const Color primaryLight = Color(0xFF22D3EE);    // cyan-400
  static const Color primaryDark = Color(0xFF0891B2);     // cyan-600

  // Secondary - Emerald
  static const Color secondary = Color(0xFF10B981);       // emerald-500
  static const Color secondaryLight = Color(0xFF34D399);  // emerald-400
  static const Color secondaryDark = Color(0xFF059669);   // emerald-600

  // Accent - Blue
  static const Color accent = Color(0xFF3B82F6);          // blue-500
  static const Color accentLight = Color(0xFF60A5FA);     // blue-400
  static const Color accentDark = Color(0xFF2563EB);      // blue-600

  // Amber - Knowledge Points
  static const Color amber = Color(0xFFF59E0B);           // amber-500
  static const Color amberLight = Color(0xFFFBBF24);      // amber-400
  static const Color amberDark = Color(0xFFD97706);       // amber-600

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);   // slate-400
  static const Color textCyan = Color(0xFF67E8F9);        // cyan-300
  static const Color textAmber = Color(0xFFFCD34D);       // amber-300

  // Card / Surface
  static const Color cardBg = Color(0xFF0F172A);          // slate-900
  static const Color cardBorder = Color(0xFF164E63);      // cyan-900
  static const Color surfaceOverlay = Color(0x1A06B6D4);  // cyan with opacity

  // Status
  static const Color success = Color(0xFF22C55E);         // green-500
  static const Color error = Color(0xFFEF4444);           // red-500
  static const Color warning = Color(0xFFF59E0B);         // amber-500

  // Gradient stops
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accentDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cyanEmeraldGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, backgroundBlue, backgroundDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
