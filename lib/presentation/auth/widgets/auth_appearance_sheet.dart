import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/app_portal.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/profile_language_section.dart';
import '../../shared/widgets/profile_theme_section.dart';

/// Language + theme picker for the auth flow (onboarding / login only).
class AuthAppearanceSheet {
  static Future<void> show(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  l10n.appearanceSettings,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const ProfileLanguageSection(portal: AppPortal.auth),
              const SizedBox(height: 20),
              const ProfileThemeSection(portal: AppPortal.auth),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthSettingsButton extends StatelessWidget {
  const AuthSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AuthAppearanceSheet.show(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.28)),
          ),
          child: Icon(
            Icons.tune_rounded,
            color: AppColors.accentText,
            size: 22,
          ),
        ),
      ),
    );
  }
}
