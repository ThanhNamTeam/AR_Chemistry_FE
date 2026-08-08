import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/locale_provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';

class ExperimentScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  const ExperimentScreenHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class ExperimentTimerBadge extends StatelessWidget {
  final String timeText;
  final bool active;

  const ExperimentTimerBadge({
    super.key,
    required this.timeText,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? AppColors.amber.withValues(alpha: 0.18)
            : AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? AppColors.amber.withValues(alpha: 0.45)
              : AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: active ? AppColors.amber : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            timeText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.amber : AppColors.primary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
