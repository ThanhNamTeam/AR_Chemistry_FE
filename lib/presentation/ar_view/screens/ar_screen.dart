// AR Screen - placeholder for actual AR implementation
// This file is ready for integration with ARCore/ARKit
import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';

class ARScreen extends StatelessWidget {
  const ARScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera placeholder
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF0C1A33)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                  ),
                  child: Icon(Icons.view_in_ar,
                      color: AppColors.primary, size: 56),
                ),
                const SizedBox(height: 24),
                Text(l10n.arCamera,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter')),
                const SizedBox(height: 8),
                Text(l10n.arCoreReady,
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Icon(Icons.arrow_back,
                      color: AppColors.primary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
