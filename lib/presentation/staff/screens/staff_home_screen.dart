import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/feedback_model.dart';
import '../../../domain/models/quiz_draft_model.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../auth/providers/role_session_provider.dart';
import '../../home/providers/theme_provider.dart';
import '../providers/staff_provider.dart';
import 'staff_feedback_detail_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _tab = 0;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().initialize();
    });
  }

  Future<void> _logout() async {
    await context.read<RoleSessionProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;
    final name = result.files.single.name;
    setState(() => _uploading = true);
    await context.read<StaffProvider>().simulateDocumentUpload(name);
    if (mounted) {
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã gửi tài liệu "$name". Hệ thống đang tạo quiz (mock).',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() => _tab = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final staff = context.watch<StaffProvider>();
    final email = context.watch<RoleSessionProvider>().email ?? 'staff';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staff Portal',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textCyan,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.portalProfile,
                      ),
                      icon: Icon(Icons.person_outline,
                          color: AppColors.primary),
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: Icon(Icons.logout, color: AppColors.error),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _tabChip('Feedback', 0),
                    const SizedBox(width: 8),
                    _tabChip('Quiz pipeline', 1),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: staff.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tab == 0
                        ? _feedbackList(staff)
                        : _quizPipeline(staff),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabChip(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : AppColors.cardBg.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedbackList(StaffProvider staff) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: staff.feedbacks.length,
      itemBuilder: (context, i) {
        final f = staff.feedbacks[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StaffFeedbackDetailScreen(feedbackId: f.id),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _badge(f.type.label, AppColors.error),
                      const Spacer(),
                      if (f.staffResponse != null)
                        _badge('Đã phản hồi', AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    f.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    f.anonymous
                        ? 'Ẩn danh'
                        : '${f.reporterName ?? "User"} · ${f.reporterEmail ?? ""}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _quizPipeline(StaffProvider staff) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        GestureDetector(
          onTap: _uploading ? null : _pickDocument,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cyanEmeraldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  _uploading ? Icons.hourglass_top : Icons.upload_file,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _uploading
                        ? 'Đang xử lý tài liệu...'
                        : 'Upload tài liệu để hệ thống tạo quiz',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Quiz do AI sinh — chờ staff duyệt trước khi lên cho người dùng',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        ...staff.quizDrafts.map(_quizCard),
      ],
    );
  }

  Widget _quizCard(QuizDraftModel q) {
    final statusColor = switch (q.status) {
      QuizDraftStatus.pendingReview => AppColors.amber,
      QuizDraftStatus.approved => AppColors.success,
      QuizDraftStatus.rejected => AppColors.error,
    };
    final statusLabel = switch (q.status) {
      QuizDraftStatus.pendingReview => 'Chờ duyệt',
      QuizDraftStatus.approved => 'Đã approve',
      QuizDraftStatus.rejected => 'Từ chối',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _badge(statusLabel, statusColor),
              const Spacer(),
              Text(
                q.sourceDocument,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            'Chủ đề: ${q.topic}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textCyan,
              fontFamily: 'Inter',
            ),
          ),
          if (q.status == QuizDraftStatus.pendingReview) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context
                        .read<StaffProvider>()
                        .rejectQuiz(q.id, note: 'Cần chỉnh sửa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                    ),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<StaffProvider>().approveQuiz(q.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã approve quiz cho người dùng (mock)'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
