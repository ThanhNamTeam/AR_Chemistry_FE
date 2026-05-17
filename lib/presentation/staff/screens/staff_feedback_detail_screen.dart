import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/portal_scaffold.dart';
import '../../home/providers/theme_provider.dart';
import '../providers/staff_provider.dart';

class StaffFeedbackDetailScreen extends StatefulWidget {
  final String feedbackId;

  const StaffFeedbackDetailScreen({super.key, required this.feedbackId});

  @override
  State<StaffFeedbackDetailScreen> createState() =>
      _StaffFeedbackDetailScreenState();
}

class _StaffFeedbackDetailScreenState extends State<StaffFeedbackDetailScreen> {
  final _responseCtrl = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _responseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final staff = context.watch<StaffProvider>();
    StaffFeedbackItem? item;
    for (final f in staff.feedbacks) {
      if (f.id == widget.feedbackId) {
        item = f;
        break;
      }
    }

    if (item == null) {
      return PortalScaffold(
        title: 'Feedback',
        showBack: true,
        body: const Center(child: Text('Không tìm thấy')),
      );
    }

    if (!_prefilled && item.staffResponse != null) {
      _responseCtrl.text = item.staffResponse!;
      _prefilled = true;
    }

    final f = item;

    return PortalScaffold(
      title: 'Chi tiết feedback',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              f.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              f.content,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Giải pháp / phản hồi cho người dùng',
              hint: 'Mô tả hướng cải thiện...',
              controller: _responseCtrl,
              prefixIcon: Icons.lightbulb_outline,
              maxLines: 5,
              minLines: 4,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                if (_responseCtrl.text.trim().isEmpty) return;
                await staff.submitFeedbackResponse(
                  f.id,
                  _responseCtrl.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã lưu phản hồi staff'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Gửi giải pháp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
