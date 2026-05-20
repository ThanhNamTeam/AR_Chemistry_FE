import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import 'pressable_scale.dart';

class GradientPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final bool loading;
  final EdgeInsetsGeometry padding;

  const GradientPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient,
    this.loading = false,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppColors.primaryGradient;
    final enabled = onTap != null && !loading;

    return PressableScale(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          gradient: enabled ? effectiveGradient : null,
          color: enabled ? null : AppColors.textSecondary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
        ),
      ),
    );
  }
}
