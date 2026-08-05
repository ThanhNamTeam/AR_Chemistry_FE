import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/storage/avatar_storage_service.dart';
import '../../../domain/models/app_portal.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../auth/providers/role_session_provider.dart';
import '../../../core/portal/portal_scope.dart';
import '../../home/providers/theme_provider.dart';
import '../widgets/profile_language_section.dart';
import '../widgets/profile_theme_section.dart';
import '../../staff/providers/staff_provider.dart';
import '../../admin/providers/admin_provider.dart';
import '../widgets/portal_profile_update_sheet.dart';

class PortalProfileScreen extends StatefulWidget {
  const PortalProfileScreen({super.key});

  @override
  State<PortalProfileScreen> createState() => _PortalProfileScreenState();
}

class _PortalProfileScreenState extends State<PortalProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _pickingAvatar = false;

  Future<void> _pickAvatar() async {
    if (_pickingAvatar) return;
    setState(() => _pickingAvatar = true);
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;

      final error = await context
          .read<RoleSessionProvider>()
          .updateAvatarFromPath(file.path);
      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.avatarUpdated),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotOpenGallery),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingAvatar = false);
    }
  }

  Future<void> _logout() async {
    await context.read<RoleSessionProvider>().logout();
    await activatePortal(context, AppPortal.auth);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();
    final session = context.watch<RoleSessionProvider>();
    final isStaff = session.isStaff;
    final portal =
        isStaff ? AppPortal.staff : AppPortal.admin;
    final avatarPath = session.userAvatar;
    final hasAvatar = AvatarStorageService.avatarFileExists(avatarPath);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        l10n.profile,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.secondary.withOpacity(0.15),
                    ]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickingAvatar ? null : _pickAvatar,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: hasAvatar
                                    ? null
                                    : AppColors.cyanEmeraldGradient,
                                image: hasAvatar
                                    ? DecorationImage(
                                        image: FileImage(File(avatarPath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: hasAvatar
                                  ? null
                                  : Center(
                                      child: Text(
                                        session.displayName
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                            if (!_pickingAvatar)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.backgroundDark,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tapAvatarHint,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          isStaff ? l10n.roleStaff : l10n.roleAdmin,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentText,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        session.displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.email ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      if (session.userPhone != null &&
                          session.userPhone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          session.userPhone!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subtitleAccent,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => PortalProfileUpdateSheet.show(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.45),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: AppColors.accentText,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.updateProfile,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentText,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (isStaff) _buildStaffSummary(context, l10n),
                if (session.isAdmin) _buildAdminSummary(context, l10n),
                const SizedBox(height: 24),
                ProfileLanguageSection(
                  portal: isStaff ? AppPortal.staff : AppPortal.admin,
                ),
                const SizedBox(height: 24),
                ProfileThemeSection(portal: portal),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (isStaff) ...[
                        _PortalMenuItem(
                          icon: Icons.feedback_outlined,
                          label: l10n.manageFeedback,
                          subtitle: l10n.manageFeedbackSubtitle,
                          color: AppColors.amber,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 10),
                        _PortalMenuItem(
                          icon: Icons.quiz_outlined,
                          label: l10n.quizPipeline,
                          subtitle: l10n.quizPipelineSubtitle,
                          color: AppColors.secondary,
                          onTap: () => Navigator.pop(context),
                        ),
                      ] else ...[
                        _PortalMenuItem(
                          icon: Icons.dashboard_outlined,
                          label: l10n.dashboard,
                          subtitle: l10n.dashboardSubtitle,
                          color: AppColors.primary,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 10),
                        _PortalMenuItem(
                          icon: Icons.science_outlined,
                          label: l10n.manageCatalog,
                          subtitle: l10n.manageCatalogSubtitle,
                          color: AppColors.accent,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout,
                                  color: AppColors.error, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                l10n.logout,
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffSummary(BuildContext context, AppLocalizations l10n) {
    final staff = context.watch<StaffProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _miniStat(
            l10n.feedback,
            '${staff.feedbacks.length}',
            AppColors.amber,
          ),
          const SizedBox(width: 10),
          _miniStat(
            l10n.pendingQuizzes,
            '${staff.pendingQuizzes.length}',
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSummary(BuildContext context, AppLocalizations l10n) {
    final admin = context.watch<AdminProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _miniStat(
              l10n.users, '${admin.totalUsers}', AppColors.primary),
          const SizedBox(width: 10),
          _miniStat(
            l10n.chemicals,
            '${admin.catalogCards.length}',
            AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PortalMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
