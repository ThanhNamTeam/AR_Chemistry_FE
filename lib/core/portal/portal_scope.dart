import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/app_portal.dart';
import '../../presentation/home/providers/theme_provider.dart';
import '../l10n/locale_provider.dart';

/// Applies theme + locale for a portal (user / staff / admin).
Future<void> activatePortal(BuildContext context, AppPortal portal) async {
  await context.read<ThemeProvider>().setActivePortal(portal);
  await context.read<LocaleProvider>().setActivePortal(portal);
}
