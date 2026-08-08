import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../../domain/models/app_portal.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/styles/app_typography.dart';

enum AppThemeKey { dark, light, ocean, galaxy, forest }

class AppThemeOption {
  final AppThemeKey key;
  final Color primary;
  final Color accent;

  const AppThemeOption({
    required this.key,
    required this.primary,
    required this.accent,
  });
}

class ThemeProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  final Map<AppPortal, AppThemeKey> _themes = {
    for (final p in AppPortal.values) p: AppThemeKey.dark,
  };

  AppPortal _activePortal = AppPortal.auth;

  static const options = [
    AppThemeOption(
      key: AppThemeKey.dark,
      primary: Color(0xFF06B6D4),
      accent: Color(0xFF3B82F6),
    ),
    AppThemeOption(
      // Bộ màu Light theo dải xanh thiết kế:
      // #27A4F2 #3EAEF4 #6EC2F7 #9FD7F9 #CFEBFC.
      // Accent cũng là xanh (không dùng cam) để toàn theme một tông;
      // các mã còn lại của dải nằm trong AppColors.applyTheme (nhánh light).
      key: AppThemeKey.light,
      primary: Color(0xFF27A4F2),
      accent: Color(0xFF3EAEF4),
    ),
    AppThemeOption(
      key: AppThemeKey.ocean,
      primary: Color(0xFF06B6D4),
      accent: Color(0xFF14B8A6),
    ),
    AppThemeOption(
      key: AppThemeKey.galaxy,
      primary: Color(0xFFD946EF),
      accent: Color(0xFF8B5CF6),
    ),
    AppThemeOption(
      key: AppThemeKey.forest,
      primary: Color(0xFF10B981),
      accent: Color(0xFF14B8A6),
    ),
  ];

  AppPortal get activePortal => _activePortal;

  /// Theme of the portal currently on screen (drives [AppColors] + MaterialApp).
  AppThemeKey get theme => _themes[_activePortal]!;

  AppThemeKey themeFor(AppPortal portal) => _themes[portal]!;

  AppThemeOption get currentOption =>
      options.firstWhere((o) => o.key == theme);

  AppThemeOption optionFor(AppPortal portal) =>
      options.firstWhere((o) => o.key == themeFor(portal));

  Future<void> loadThemes() async {
    final legacy = await _storage.getTheme();
    for (final portal in AppPortal.values) {
      var saved = await _storage.getThemeForPortal(portal);
      if (saved == null &&
          portal == AppPortal.user &&
          legacy != null &&
          legacy.isNotEmpty) {
        saved = legacy;
        await _storage.setThemeForPortal(portal, legacy);
      }
      if (saved != null) {
        _themes[portal] = AppThemeKey.values.firstWhere(
          (k) => k.name == saved,
          orElse: () => AppThemeKey.dark,
        );
      }
    }
    _syncPaletteFor(_activePortal);
    notifyListeners();
  }

  void _syncPaletteFor(AppPortal portal) {
    final o = optionFor(portal);
    AppColors.applyTheme(
      primaryColor: o.primary,
      accentColor: o.accent,
      light: o.key == AppThemeKey.light,
      useAccentAsSecondary:
          o.key == AppThemeKey.forest || o.key == AppThemeKey.ocean,
    );
  }

  Future<void> setActivePortal(AppPortal portal) async {
    if (_activePortal == portal) return;
    _activePortal = portal;
    _syncPaletteFor(portal);
    notifyListeners();
  }

  Future<void> setTheme(AppThemeKey key, {AppPortal? portal}) async {
    final target = portal ?? _activePortal;
    _themes[target] = key;
    await _storage.setThemeForPortal(target, key.name);
    if (target == _activePortal) {
      _syncPaletteFor(target);
    }
    notifyListeners();
  }

  ThemeData buildThemeData() {
    final option = currentOption;
    final isLight = AppColors.isLight;
    final bodyColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    final base = ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      // onPrimary/onSecondary đặt tường minh = ink tối: Material mặc định suy
      // ra TRẮNG cho các primary rực (#27A4F2/#06B6D4...) khiến MỌI
      // ElevatedButton trong app fail WCAG AA (~2,4-2,7:1). Ink tối trên các
      // nền này đạt 7,5-7,9:1. Đây là token trung tâm — sửa một chỗ, cả app
      // đổi theo (xem AppColors.onGradient cho các widget vẽ gradient tay).
      colorScheme: isLight
          ? ColorScheme.light(
              primary: option.primary,
              onPrimary: AppColors.onGradient,
              secondary: option.accent,
              onSecondary: AppColors.onGradient,
              surface: const Color(0xFFF8FAFC),
              // ignore: deprecated_member_use
              background: const Color(0xFFFFFFFF),
            )
          : ColorScheme.dark(
              primary: option.primary,
              onPrimary: AppColors.onGradient,
              secondary: option.accent,
              onSecondary: AppColors.onGradient,
              surface: const Color(0xFF0F172A),
              // ignore: deprecated_member_use
              background: const Color(0xFF020817),
            ),
      scaffoldBackgroundColor:
          isLight ? const Color(0xFFFFFFFF) : const Color(0xFF020817),
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? Colors.white : const Color(0xFF020817),
        foregroundColor: isLight ? Colors.black87 : Colors.white,
        elevation: 0,
      ),
    );

    final textTheme = AppTypography.apply(base.textTheme).apply(
      bodyColor: bodyColor,
      displayColor: bodyColor,
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isLight ? Colors.black87 : Colors.white,
        ),
      ),
    );
  }
}
