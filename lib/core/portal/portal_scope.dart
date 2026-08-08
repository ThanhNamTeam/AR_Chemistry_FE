import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/app_portal.dart';
import '../../presentation/home/providers/theme_provider.dart';
import '../l10n/locale_provider.dart';

/// Applies theme + locale for a portal (user / staff / admin).
Future<void> activatePortal(BuildContext context, AppPortal portal) async {
  final themeProvider = context.read<ThemeProvider>();
  final localeProvider = context.read<LocaleProvider>();
  await themeProvider.setActivePortal(portal);
  await localeProvider.setActivePortal(portal);
}
