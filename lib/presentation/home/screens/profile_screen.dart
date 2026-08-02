import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/api/library_api.dart';
import '../../../core/api/reaction_api.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/storage/avatar_storage_service.dart';
import '../../../domain/models/app_portal.dart';
import '../../../shared/styles/app_colors.dart';
import '../../ai_chat/providers/ai_fab_visibility.dart';
import '../../shared/widgets/profile_language_section.dart';
import '../../shared/widgets/profile_theme_section.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import '../../../core/portal/portal_scope.dart';
import '../../home/providers/theme_provider.dart';
import '../widgets/profile_update_sheet.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _pickingAvatar = false;

  final LibraryApi _libraryApi = LibraryApi();
  final ReactionApi _reactionApi = ReactionApi();

  bool _isLoadingSummary = true;
  int _unlockedCards = 0;
  int _totalCards = 0;
  int _totalReactions = 0;
  double _libraryProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileSummary();
  }

  Future<void> _loadProfileSummary() async {
    setState(() {
      _isLoadingSummary = true;
    });

    try {
      final results = await Future.wait([
        _libraryApi.getLibrarySummary(),
        _reactionApi.getReactionSummary(),
      ]);

      final librarySummary = results[0] as dynamic;
      final reactionSummary = results[1] as dynamic;

      if (!mounted) return;

      setState(() {
        _unlockedCards = librarySummary.unlockedCards;
        _totalCards = librarySummary.totalCards;
        _libraryProgress = librarySummary.libraryProgress;
        _totalReactions = reactionSummary.totalReactions;
        _isLoadingSummary = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingSummary = false;
      });
    }
  }

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
          .read<AppState>()
          .updateAvatarFromPath(file.path);
      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: const TextStyle(fontFamily: 'Inter')),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.avatarUpdated,
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.cannotOpenGallery,
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();
    final state = context.watch<AppState>();

    final avatar = state.userAvatar;

    final isNetworkAvatar = avatar != null &&
        (avatar.startsWith('http://') || avatar.startsWith('https://'));

    final hasLocalAvatar = avatar != null &&
        !isNetworkAvatar &&
        AvatarStorageService.avatarFileExists(avatar);

    final hasAvatar = isNetworkAvatar || hasLocalAvatar;

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
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Icon(Icons.arrow_back,
                              color: AppColors.primary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(l10n.profile,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter')),
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
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20),
                    ],
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
                                  image: isNetworkAvatar
                                      ? NetworkImage(avatar)
                                      : FileImage(File(avatar!)) as ImageProvider,
                                  fit: BoxFit.cover,
                                )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: hasAvatar
                                  ? null
                                  : Center(
                                      child: Text(
                                        state.displayName
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                            ),
                            if (_pickingAvatar)
                              const SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
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
                          color: AppColors.textSecondary.withOpacity(0.9),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 4),
                      Text(state.userEmail ?? '',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter')),
                      if (state.userPhone != null &&
                          state.userPhone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(state.userPhone!,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.subtitleAccent,
                                fontFamily: 'Inter')),
                      ],
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => ProfileUpdateSheet.show(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.45),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 16, color: AppColors.accentText),
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
                      const SizedBox(height: 16),
                      KnowledgePointsBadge(points: state.knowledgePoints),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.menu_book_outlined,
                            label: l10n.cardsUnlocked,
                            value: _isLoadingSummary ? '...' : '$_unlockedCards/$_totalCards',
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.science_outlined,
                            label: l10n.experiments,
                            value: _isLoadingSummary ? '...' : '$_totalReactions',
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.libraryProgress,
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontFamily: 'Inter')),
                                Text(
                                    '${(_libraryProgress * 100).round()}%',
                                    style: TextStyle(
                                        color: AppColors.accentText,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Inter')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _libraryProgress.clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.15),
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const ProfileLanguageSection(portal: AppPortal.user),
                const SizedBox(height: 24),
                const ProfileThemeSection(portal: AppPortal.user),
                const SizedBox(height: 24),
                const _ChatSettingsSection(),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: Icons.menu_book_outlined,
                        label: l10n.myLibrary,
                        subtitle: l10n.cardsUnlockedSubtitle(_unlockedCards),
                        color: AppColors.primary,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.library),
                      ),
                      const SizedBox(height: 10),
                      _MenuItem(
                        icon: Icons.shopping_bag_outlined,
                        label: l10n.myBag,
                        subtitle: l10n.myBagSubtitle,
                        color: AppColors.secondary,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.myBag),
                      ),
                      const SizedBox(height: 10),
                      _MenuItem(
                        icon: Icons.qr_code_2_outlined,
                        label: l10n.cardPurchased,
                        subtitle: l10n.cardPurchasedSubtitle,
                        color: AppColors.primary,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.mySingleCards),
                      ),
                      const SizedBox(height: 10),
                      _MenuItem(
                        icon: Icons.store_outlined,
                        label: l10n.shop,
                        subtitle: l10n.shopSubtitle,
                        color: AppColors.accent,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.shop),
                      ),
                      const SizedBox(height: 10),
                      _MenuItem(
                        icon: Icons.feedback_outlined,
                        label: l10n.feedback,
                        subtitle: l10n.feedbackSubtitle,
                        color: AppColors.amber,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.feedback),
                      ),
                      const SizedBox(height: 10),
                      _MenuItem(
                        icon: Icons.history_outlined,
                        label: l10n.myFeedbacks,
                        subtitle: l10n.myFeedbacksSubtitle,
                        color: AppColors.secondary,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.myFeedbacks,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () async {
                          // Đăng xuất nhầm rất tốn công khôi phục (email +
                          // mật khẩu + có thể cả OTP) — luôn hỏi trước.
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.cardBg,
                              title: Text(
                                l10n.logoutConfirmTitle,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              content: Text(
                                l10n.logoutConfirmMessage,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    l10n.logout,
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true || !context.mounted) return;

                          await state.logout();
                          await activatePortal(context, AppPortal.auth);
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                                  (r) => false,
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout,
                                  color: AppColors.error, size: 20),
                              const SizedBox(width: 10),
                              Text(l10n.logout,
                                  style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter')),
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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Inter')),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
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
                  Text(label,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter')),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter')),
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

class _ChatSettingsSection extends StatelessWidget {
  const _ChatSettingsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<ThemeProvider>();
    final fabVisibility = context.watch<AiFabVisibility>();
    final enabled = fabVisibility.userEnabled;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              l10n.assistantSettings,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.aiAssistant,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        enabled
                            ? l10n.assistantFabVisible
                            : l10n.assistantFabHidden,
                        style: TextStyle(
                          fontSize: 12,
                          color: enabled
                              ? AppColors.primary.withOpacity(0.85)
                              : AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: (value) => fabVisibility.setUserEnabled(value),
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withOpacity(0.3),
                  inactiveThumbColor: AppColors.textSecondary,
                  inactiveTrackColor: AppColors.textSecondary.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
