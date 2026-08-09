import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/app_portal.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';

/// Theme picker scoped to a single portal (user / staff / admin).
class ProfileThemeSection extends StatelessWidget {
  final AppPortal portal;

  const ProfileThemeSection({super.key, required this.portal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final current = themeProvider.themeFor(portal);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appTheme,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ThemeProvider.options.map((option) {
              final selected = current == option.key;
              return GestureDetector(
                onTap: () =>
                    themeProvider.setTheme(option.key, portal: portal),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? LinearGradient(
                            colors: [option.primary, option.accent],
                          )
                        : null,
                    color: selected
                        ? null
                        : AppColors.cardSurfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    l10n.themeName(option.key),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
