import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/app_portal.dart';
import '../providers/theme_provider.dart';

/// Full-screen home background image matching the user's profile theme.
class ThemedHomeBackground extends StatelessWidget {
  const ThemedHomeBackground({super.key});

  static String assetFor(AppThemeKey key) {
    switch (key) {
      case AppThemeKey.dark:
        return 'assets/images/Cyber.png';
      case AppThemeKey.light:
        return 'assets/images/Light.png';
      case AppThemeKey.ocean:
        return 'assets/images/Ocean.png';
      case AppThemeKey.galaxy:
        return 'assets/images/Galaxy.png';
      case AppThemeKey.forest:
        return 'assets/images/Forest.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeKey = context.watch<ThemeProvider>().themeFor(AppPortal.user);

    return Image.asset(
      assetFor(themeKey),
      fit: BoxFit.cover,
      alignment: const Alignment(0, 0.30),
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
    );
  }
}
