import 'package:flutter/material.dart';

import '../../../core/api/feedback_api_service.dart';
import '../../../domain/models/admin_feedback_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/portal_scaffold.dart';

class MyFeedbackDetailScreen extends StatefulWidget {
  final String feedbackId;

  const MyFeedbackDetailScreen({
    super.key,
    required this.feedbackId,
  });

  @override
  State<MyFeedbackDetailScreen> createState() => _MyFeedbackDetailScreenState();
}

class _MyFeedbackDetailScreenState extends State<MyFeedbackDetailScreen> {
  final _api = FeedbackApiService();

  bool _loading = true;
  AdminFeedbackModel? _feedback;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);

    try {
      final feedback = await _api.getMyFeedbackDetail(widget.feedbackId);

      if (!mounted) return;

      setState(() {
        _feedback = feedback;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tải được chi tiết feedback: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = _feedback;

    return PortalScaffold(
      title: 'Chi tiết feedback',
      showBack: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : f == null
          ? Center(
        child: Text(
          'Không tìm thấy feedback',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              f.title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              f.content,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(feedback: f),
            if (f.imageUrl != null && f.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  f.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.cardBorder.withOpacity(0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phản hồi từ hệ thống',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    f.staffReply == null || f.staffReply!.isEmpty
                        ? 'Hệ thống sẽ phản hồi trong thời gian sớm nhất.'
                        : f.staffReply!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AdminFeedbackModel feedback;

  const _InfoCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.35),
        ),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Người gửi', value: feedback.displayName ?? 'Unknow'),
          _InfoRow(label: 'Ẩn danh', value: feedback.anonymous ? 'Có' : 'Không'),
          _InfoRow(label: 'Loại', value: feedback.type),
          _InfoRow(label: 'Trạng thái', value: feedback.status),
          _InfoRow(label: 'Độ ưu tiên', value: feedback.priority),
          if (feedback.appVersion != null && feedback.appVersion!.isNotEmpty)
            _InfoRow(label: 'App version', value: feedback.appVersion!),
          if (feedback.deviceInfo != null && feedback.deviceInfo!.isNotEmpty)
            _InfoRow(label: 'Thiết bị', value: feedback.deviceInfo!),
          if (feedback.createdAt != null)
            _InfoRow(label: 'Ngày gửi', value: feedback.createdAt.toString()),
          if (feedback.updatedAt != null)
            _InfoRow(label: 'Cập nhật', value: feedback.updatedAt.toString()),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}