import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../shared/styles/app_colors.dart';

enum AppThemeKey { dark, light, ocean, galaxy, forest }

class AppThemeOption {
  final AppThemeKey key;
  final String name;
  final Color primary;
  final Color accent;

  const AppThemeOption({
    required this.key,
    required this.name,
    required this.primary,
    required this.accent,
  });
}

class ThemeProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  AppThemeKey _theme = AppThemeKey.dark;

  static const options = [
    AppThemeOption(
      key: AppThemeKey.dark,
      name: 'Dark Cyber',
      primary: Color(0xFF06B6D4),
      accent: Color(0xFF3B82F6),
    ),
    AppThemeOption(
      key: AppThemeKey.light,
      name: 'Light Mode',
      primary: Color(0xFF0EA5E9),
      accent: Color(0xFFF59E0B),
    ),
    AppThemeOption(
      key: AppThemeKey.ocean,
      name: 'Ocean Blue',
      primary: Color(0xFF06B6D4),
      accent: Color(0xFF14B8A6),
    ),
    AppThemeOption(
      key: AppThemeKey.galaxy,
      name: 'Purple Galaxy',
      primary: Color(0xFFD946EF),
      accent: Color(0xFF8B5CF6),
    ),
    AppThemeOption(
      key: AppThemeKey.forest,
      name: 'Green Forest',
      primary: Color(0xFF10B981),
      accent: Color(0xFF14B8A6),
    ),
  ];

  AppThemeKey get theme => _theme;

  AppThemeOption get currentOption =>
      options.firstWhere((o) => o.key == _theme);

  Future<void> loadTheme() async {
    final saved = await _storage.getTheme();
    if (saved != null) {
      _theme = AppThemeKey.values.firstWhere(
        (k) => k.name == saved,
        orElse: () => AppThemeKey.dark,
      );
    }
    _syncPalette();
    notifyListeners();
  }

  void _syncPalette() {
    final o = currentOption;
    AppColors.applyTheme(
      primaryColor: o.primary,
      accentColor: o.accent,
      light: o.key == AppThemeKey.light,
      useAccentAsSecondary:
          o.key == AppThemeKey.forest || o.key == AppThemeKey.ocean,
    );
  }

  Future<void> setTheme(AppThemeKey key) async {
    _theme = key;
    _syncPalette();
    await _storage.setTheme(key.name);
    notifyListeners();
  }

  ThemeData buildThemeData() {
    final option = currentOption;
    final isLight = AppColors.isLight;
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: isLight ? Brightness.light : Brightness.dark,
      colorScheme: isLight
          ? ColorScheme.light(
              primary: option.primary,
              secondary: option.accent,
              surface: const Color(0xFFF8FAFC),
              background: const Color(0xFFFFFFFF),
            )
          : ColorScheme.dark(
              primary: option.primary,
              secondary: option.accent,
              surface: const Color(0xFF0F172A),
              background: const Color(0xFF020817),
            ),
      scaffoldBackgroundColor:
          isLight ? const Color(0xFFFFFFFF) : const Color(0xFF020817),
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? Colors.white : const Color(0xFF020817),
        foregroundColor: isLight ? Colors.black87 : Colors.white,
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          color: isLight ? Colors.black87 : Colors.white,
        ),
      ),
    );
  }
}
