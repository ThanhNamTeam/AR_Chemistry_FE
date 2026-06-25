import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/feedback_api_service.dart';
import '../../../domain/models/admin_feedback_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/portal_scaffold.dart';
import '../../home/providers/theme_provider.dart';

class StaffFeedbackDetailScreen extends StatefulWidget {
  final String feedbackId;

  const StaffFeedbackDetailScreen({super.key, required this.feedbackId});

  @override
  State<StaffFeedbackDetailScreen> createState() =>
      _StaffFeedbackDetailScreenState();
}

class _StaffFeedbackDetailScreenState extends State<StaffFeedbackDetailScreen> {
  final _responseCtrl = TextEditingController();
  final _api = FeedbackApiService();

  AdminFeedbackModel? _feedback;
  bool _loading = true;
  bool _saving = false;
  bool _prefilled = false;
  String _status = 'OPEN';
  String _priority = 'MEDIUM';



  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _responseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);

    try {
      final feedback = await _api.getFeedbackDetail(widget.feedbackId);

      if (!mounted) return;

      setState(() {
        _feedback = feedback;
        _status = feedback.status.isNotEmpty ? feedback.status : 'OPEN';
        _priority = feedback.priority.isNotEmpty ? feedback.priority : 'MEDIUM';
        _loading = false;
      });

      if (!_prefilled && feedback.staffReply != null) {
        _responseCtrl.text = feedback.staffReply!;
        _prefilled = true;
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tải được feedback: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleFeedback() async {
    if (_feedback == null) return;

    final reply = _responseCtrl.text.trim();

    if (reply.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập phản hồi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _api.handleFeedback(
        feedbackId: _feedback!.id,
        status: _status,
        priority: _priority,
        staffReply: reply,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xử lý feedback'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xử lý feedback thất bại: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    if (_loading) {
      return const PortalScaffold(
        title: 'Chi tiết feedback',
        showBack: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final f = _feedback;

    if (f == null) {
      return const PortalScaffold(
        title: 'Feedback',
        showBack: true,
        body: Center(child: Text('Không tìm thấy')),
      );
    }

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
            _InfoCard(feedback: f),
            if (f.imageUrl != null && f.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  f.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              dropdownColor: AppColors.cardSurface,
              decoration: InputDecoration(
                labelText: 'Độ ưu tiên',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'LOW', child: Text('LOW')),
                DropdownMenuItem(value: 'MEDIUM', child: Text('MEDIUM')),
                DropdownMenuItem(value: 'HIGH', child: Text('HIGH')),
                DropdownMenuItem(value: 'URGENT', child: Text('URGENT')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              dropdownColor: AppColors.cardSurface,
              decoration: InputDecoration(
                labelText: 'Trạng thái',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'OPEN', child: Text('OPEN')),
                DropdownMenuItem(value: 'IN_PROGRESS', child: Text('IN_PROGRESS')),
                DropdownMenuItem(value: 'RESOLVED', child: Text('RESOLVED')),
                DropdownMenuItem(value: 'REJECTED', child: Text('REJECTED')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
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
              onTap: _saving ? null : _handleFeedback,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _saving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
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
          _InfoRow(label: 'Người gửi', value: feedback.displayName ?? 'Unknown'),
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
          if (feedback.staffReply != null && feedback.staffReply!.isNotEmpty)
            _InfoRow(label: 'Phản hồi cũ', value: feedback.staffReply!),
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
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}