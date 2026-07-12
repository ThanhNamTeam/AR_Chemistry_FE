import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../domain/models/app_portal.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/styles/app_typography.dart';
import '../../home/providers/theme_provider.dart';

class ProfileLanguageSection extends StatelessWidget {
  final AppPortal portal;

  const ProfileLanguageSection({super.key, required this.portal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isEnglish = localeProvider.isEnglishFor(portal);
    final isVietnamese = localeProvider.isVietnameseFor(portal);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.language,
            style: AppTypography.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LanguageChip(
                  label: l10n.english,
                  langCode: 'EN',
                  selected: isEnglish,
                  onTap: () => localeProvider.setLocale(
                    const Locale('en'),
                    portal: portal,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LanguageChip(
                  label: l10n.vietnamese,
                  langCode: 'VI',
                  selected: isVietnamese,
                  onTap: () => localeProvider.setLocale(
                    const Locale('vi'),
                    portal: portal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final String langCode;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.langCode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.cardSurfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? Colors.white.withOpacity(0.22)
                    : AppColors.primary.withOpacity(0.12),
                border: Border.all(
                  color: selected
                      ? Colors.white.withOpacity(0.35)
                      : AppColors.primary.withOpacity(0.25),
                ),
              ),
              child: Text(
                langCode,
                style: AppTypography.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.accentText,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
