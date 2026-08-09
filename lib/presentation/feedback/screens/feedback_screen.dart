import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/api/feedback_api_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/request/feedback_request.dart';
import '../../../core/services/app_device_info_service.dart';
import '../../../domain/models/feedback_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../home/providers/theme_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _api = FeedbackApiService();
  final _picker = ImagePicker();

  FeedbackType _type = FeedbackType.bug;
  bool _anonymous = false;
  String? _imagePath;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      setState(() => _imagePath = file.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _submitting = true);

    try {
      String? imageUrl;

      if (_imagePath != null) {
        imageUrl = await _api.uploadFeedbackImage(_imagePath!);
      }

      final appVersion = await AppDeviceInfoService.getAppVersion();
      final deviceInfo = await AppDeviceInfoService.getDeviceInfo();

      if (!mounted) return;

      final request = FeedbackRequest(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        type: _type.apiValue,
        anonymous: _anonymous,
        imageUrl: imageUrl,
        appVersion: appVersion,
        deviceInfo: deviceInfo,
      );

      await _api.submitFeedback(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.feedbackSubmitSuccess,
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.feedbackSubmitFailed,
            style: TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
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
                    Expanded(
                      child: Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.feedbackType,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subtitleAccent,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: FeedbackType.values.map((t) {
                            final selected = _type == t;
                            return GestureDetector(
                              onTap: () => setState(() => _type = t),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? AppColors.primaryGradient
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
                                  t.label,
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
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: l10n.feedbackTitle,
                          hint: l10n.feedbackTitleHint,
                          controller: _titleCtrl,
                          prefixIcon: Icons.title,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? l10n.requiredField
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: l10n.feedbackContentLabel,
                          hint: l10n.feedbackContentHint,
                          controller: _contentCtrl,
                          prefixIcon: Icons.notes_outlined,
                          maxLines: 5,
                          minLines: 4,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? l10n.requiredField
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.illustrationImageOptional,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subtitleAccent,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: _imagePath != null ? 160 : 100,
                            decoration: BoxDecoration(
                              color: AppColors.cardBg.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: _imagePath != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.file(
                                          File(_imagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => _imagePath = null),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: AppColors.primary,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.tapToUploadImage,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.sendAnonymously,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _anonymous
                                          ? l10n.anonymousOnHint
                                          : l10n.anonymousOffHint,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _anonymous,
                                onChanged: (v) =>
                                    setState(() => _anonymous = v),
                                activeThumbColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _submitting ? null : _submit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: _submitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      l10n.submitFeedback,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
