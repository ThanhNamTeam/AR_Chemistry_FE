import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/staff_quiz_question_model.dart';
import '../../../domain/models/staff_quiz_summary_model.dart';
import '../../../domain/models/staff_lesson_quiz_overview_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';
import '../providers/staff_provider.dart';

class StaffQuizTab extends StatefulWidget {
  const StaffQuizTab({super.key});

  @override
  State<StaffQuizTab> createState() => _StaffQuizTabState();
}

class _StaffQuizTabState extends State<StaffQuizTab> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadLessonQuizOverviews();
    });
  }

  String _buildQuizPrompt({
    required StaffLessonQuizOverviewModel lesson,
    required String content,
  }) {
    return '''
Bạn là giáo viên Hóa học lớp 8.

Dựa hoàn toàn vào nội dung bài học bên dưới, hãy tạo 10 câu quiz cho học sinh lớp 8.

Yêu cầu:
- Xuất kết quả dưới dạng CSV.
- Không giải thích ngoài CSV.
- CSV phải có header đúng như sau:
lesson_code,quiz_title,question_order,type,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty
- type chỉ được là: multiple_choice, true_false, fill_blank
- difficulty chỉ được là: easy, medium, hard
- Tạo 6 câu multiple_choice, 2 câu true_false, 2 câu fill_blank.
- Với multiple_choice phải có đủ option_a, option_b, option_c, option_d.
- Với true_false, correct_answer chỉ được là TRUE hoặc FALSE.
- Với fill_blank, question_text phải có ký hiệu ____ tại chỗ trống.
- Tất cả câu hỏi phải dựa trên nội dung bài học, không dùng kiến thức ngoài.

lesson_code: ${lesson.lessonCode}
quiz_title: Quiz ${lesson.lessonTitle}

Nội dung bài học:
$content
''';
  }

  StaffLessonQuizOverviewModel? _selectedLesson;
  StaffQuizSummaryModel? _selectedQuiz;

  Future<void> _refresh() async {
    final provider = context.read<StaffProvider>();

    if (_selectedQuiz != null) {
      await provider.loadQuizDetail(_selectedQuiz!.quizCode);
    } else if (_selectedLesson != null) {
      await provider.loadQuizzesByLesson(_selectedLesson!.lessonCode);
    } else {
      await provider.loadLessonQuizOverviews();
    }
  }

  Future<void> _pickAndImportCsv(String lessonCode) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không đọc được file CSV.'),
        ),
      );
      return;
    }

    try {
      await context.read<StaffProvider>().importQuizCsv(
        lessonCode: lessonCode,
        fileName: file.name,
        bytes: bytes,
        fileSize: file.size,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã import CSV quiz thành công.'),
        ),
      );

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import CSV thất bại: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final staff = context.watch<StaffProvider>();

    final lessons = staff.lessonQuizOverviews;
    final selectedLesson = _selectedLesson;
    final selectedQuizzes = staff.selectedLessonQuizzes;
    final selectedQuiz = _selectedQuiz;
    final selectedQuizDetail = staff.selectedQuizDetail;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          PortalPrimaryButton(
            label: l10n.isVi ? 'Quản lý quiz theo bài học' : 'Manage quizzes by lesson',
            icon: Icons.quiz_outlined,
            loading: staff.loadingLessonQuizOverviews || staff.importingQuizCsv,
            onPressed: _refresh,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.isVi
                ? 'Chọn một bài học để import CSV quiz, xem quiz nháp hoặc quiz đã publish.'
                : 'Select a lesson to import quiz CSV, review drafts, or view published quizzes.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.isVi
                ? 'CSV do AI tạo theo prompt chuẩn — staff kiểm tra trước khi publish.'
                : 'CSV generated by AI using the standard prompt — staff reviews before publishing.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.subtitleAccent,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          PortalSectionHeader(
            title: l10n.isVi ? 'Quiz Management' : 'Quiz Management',
            actionLabel: '${lessons.length}',
          ),

          if (selectedLesson == null) ...[
            if (staff.loadingLessonQuizOverviews && lessons.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (staff.lessonQuizOverviewError != null)
              _ErrorCard(
                message: staff.lessonQuizOverviewError!,
                onRetry: _refresh,
              )
            else if (lessons.isEmpty)
                _EmptyCard(
                  message: l10n.isVi ? 'Chưa có bài học nào.' : 'No lessons found.',
                )
              else
                ...lessons.map(
                      (lesson) => _LessonQuizOverviewCard(
                    lesson: lesson,

                    // Nút 1: Bài & Prompt
                    onViewPrompt: () async {
                      setState(() {
                        _selectedLesson = lesson;
                        _selectedQuiz = null;
                      });

                      final provider = context.read<StaffProvider>();
                      await Future.wait([
                        provider.loadQuizzesByLesson(lesson.lessonCode),
                        provider.loadLessonContent(lesson.lessonCode),
                      ]);
                    },

                    // Nút 2: Xem quiz
                    onViewQuizzes: () async {
                      setState(() {
                        _selectedLesson = lesson;
                        _selectedQuiz = null;
                      });

                      final provider = context.read<StaffProvider>();

                      // Nếu provider có hàm này thì gọi để không hiện prompt cũ
                      provider.clearSelectedLessonContent();

                      await provider.loadQuizzesByLesson(lesson.lessonCode);
                    },
                  ),
                ),
          ] else if (selectedQuiz == null) ...[
            _SelectedLessonHeader(
              lesson: selectedLesson,
              onBack: () {
                context.read<StaffProvider>().clearSelectedLessonQuizzes();
                setState(() {
                  _selectedLesson = null;
                  _selectedQuiz = null;
                });
              },
            ),
            const SizedBox(height: 10),

            if (staff.loadingLessonContent)
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (staff.lessonContentError != null)
              _ErrorCard(
                message: staff.lessonContentError!,
                onRetry: _refresh,
              )
            else if (staff.selectedLessonContent != null)
                _LessonPromptCard(
                  lesson: selectedLesson,
                  content: staff.selectedLessonContent!,
                  prompt: _buildQuizPrompt(
                    lesson: selectedLesson,
                    content: staff.selectedLessonContent!,
                  ),
                ),
            const SizedBox(height: 10),
            PortalPrimaryButton(
              label: staff.importingQuizCsv ? 'Đang import CSV...' : 'Import CSV cho bài này',
              icon: Icons.upload_file_outlined,
              loading: staff.importingQuizCsv,
              onPressed: staff.importingQuizCsv
                  ? null
                  : () => _pickAndImportCsv(selectedLesson.lessonCode),
            ),
            const SizedBox(height: 10),
            if (staff.loadingSelectedLessonQuizzes && selectedQuizzes.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (staff.selectedLessonQuizError != null)
              _ErrorCard(
                message: staff.selectedLessonQuizError!,
                onRetry: _refresh,
              )
            else if (selectedQuizzes.isEmpty)
                _EmptyCard(
                  message: 'Bài này chưa có quiz. Hãy import CSV để tạo quiz.',
                )
              else
                ...selectedQuizzes.map(
                      (quiz) => _QuizSummaryCard(
                    quiz: quiz,
                    onViewQuestions: () async {
                      setState(() => _selectedQuiz = quiz);
                      await context.read<StaffProvider>().loadQuizDetail(quiz.quizCode);
                    },
                  ),
                ),
          ] else ...[
            _SelectedQuizHeader(
              quiz: selectedQuiz,
              publishing: staff.publishingQuiz,
              onBack: () {
                context.read<StaffProvider>().clearSelectedQuizDetail();
                setState(() => _selectedQuiz = null);
              },
              onPublish: () async {
                try {
                  await context.read<StaffProvider>().publishQuiz(selectedQuiz.quizCode);

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã publish quiz')),
                  );

                  await _refresh();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Publish thất bại: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            if (staff.loadingQuizDetail && selectedQuizDetail == null)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (staff.quizDetailError != null)
              _ErrorCard(
                message: staff.quizDetailError!,
                onRetry: _refresh,
              )
            else if (selectedQuizDetail == null)
                _EmptyCard(
                  message: 'Không tìm thấy chi tiết quiz.',
                )
              else if (selectedQuizDetail.questions.items.isEmpty)
                  _EmptyCard(
                    message: 'Quiz này chưa có câu hỏi.',
                  )
                else
                  ...selectedQuizDetail.questions.items.map(
                        (question) => _QuestionCard(question: question),
                  ),
          ],
        ],
      ),
    );
  }
}

class _LessonQuizOverviewCard extends StatelessWidget {
  final StaffLessonQuizOverviewModel lesson;
  final VoidCallback onViewPrompt;
  final VoidCallback onViewQuizzes;

  const _LessonQuizOverviewCard({
    required this.lesson,
    required this.onViewPrompt,
    required this.onViewQuizzes,
  });

  @override
  Widget build(BuildContext context) {
    final hasQuiz = lesson.hasQuiz;
    final status = lesson.latestQuizStatus?.toLowerCase();

    final Color statusColor = !hasQuiz
        ? AppColors.textSecondary
        : switch (status) {
      'published' => AppColors.success,
      'draft' => AppColors.amber,
      'reviewed' => AppColors.subtitleAccent,
      'archived' => AppColors.textSecondary,
      _ => AppColors.amber,
    };

    final String statusLabel = !hasQuiz
        ? 'Chưa có quiz'
        : switch (status) {
      'published' => 'Đã publish',
      'draft' => 'Bản nháp',
      'reviewed' => 'Đã duyệt',
      'archived' => 'Đã lưu trữ',
      _ => lesson.latestQuizStatus ?? 'Có quiz',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PortalGlassCard(
        accentBorder: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PortalBadge(text: statusLabel, color: statusColor),
                const Spacer(),
                Icon(
                  Icons.menu_book_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    lesson.lessonCode,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _lessonTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.chapter ?? 'Không có chương',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.subtitleAccent,
                fontFamily: 'Inter',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (hasQuiz) ...[
              Row(
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      lesson.latestQuizTitle ?? 'Quiz',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${lesson.questionCount} câu',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewPrompt,
                    icon: Icon(
                      Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.subtitleAccent,
                    ),
                    label: const Text('Bài & Prompt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.subtitleAccent,
                      side: BorderSide(
                        color: AppColors.subtitleAccent.withOpacity(0.45),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewQuizzes,
                    icon: const Icon(Icons.quiz_outlined, size: 18),
                    label: const Text('Xem quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  String get _lessonTitle {
    final number = lesson.lessonNumber;
    if (number == null) return lesson.lessonTitle;
    return 'Bài $number: ${lesson.lessonTitle}';
  }
}

class _SelectedLessonHeader extends StatelessWidget {
  final StaffLessonQuizOverviewModel lesson;
  final VoidCallback onBack;

  const _SelectedLessonHeader({
    required this.lesson,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final title = lesson.lessonNumber == null
        ? lesson.lessonTitle
        : 'Bài ${lesson.lessonNumber}: ${lesson.lessonTitle}';

    return PortalGlassCard(
      accentBorder: AppColors.subtitleAccent,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.subtitleAccent,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.lessonCode,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _LessonPromptCard extends StatelessWidget {
  final StaffLessonQuizOverviewModel lesson;
  final String content;
  final String prompt;

  const _LessonPromptCard({
    required this.lesson,
    required this.content,
    required this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    final lessonTitle = lesson.lessonNumber == null
        ? lesson.lessonTitle
        : 'Bài ${lesson.lessonNumber}: ${lesson.lessonTitle}';

    return PortalGlassCard(
      accentBorder: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nội dung bài học & Prompt',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lessonTitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.subtitleAccent,
              fontFamily: 'Inter',
            ),
          ),
          if (lesson.chapter != null && lesson.chapter!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              lesson.chapter!,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: prompt));

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã copy prompt')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy prompt'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: content));

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã copy nội dung bài học')),
                    );
                  },
                  icon: const Icon(Icons.article_outlined, size: 18),
                  label: const Text('Copy bài'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}


class _SelectedQuizHeader extends StatelessWidget {
  final StaffQuizSummaryModel quiz;
  final VoidCallback onBack;
  final Future<void> Function() onPublish;
  final bool publishing;

  const _SelectedQuizHeader({
    required this.quiz,
    required this.onBack,
    required this.onPublish,
    required this.publishing,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = quiz.status.toLowerCase() == 'draft';
    final canPublish = isDraft && quiz.questionCount > 0;

    return PortalGlassCard(
      accentBorder: AppColors.subtitleAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.subtitleAccent,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${quiz.questionCount} câu • ${quiz.status}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (canPublish) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: publishing ? null : onPublish,
                icon: publishing
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.public_outlined, size: 18),
                label: Text(publishing ? 'Đang publish...' : 'Publish quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else if (quiz.status.toLowerCase() == 'published') ...[
            const SizedBox(height: 12),
            PortalBadge(
              text: 'Quiz đã publish',
              color: AppColors.success,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizSummaryCard extends StatelessWidget {
  final StaffQuizSummaryModel quiz;
  final VoidCallback onViewQuestions;

  const _QuizSummaryCard({
    required this.quiz,
    required this.onViewQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final status = quiz.status.toLowerCase();

    final Color statusColor = switch (status) {
      'published' => AppColors.success,
      'draft' => AppColors.amber,
      'reviewed' => AppColors.subtitleAccent,
      'archived' => AppColors.textSecondary,
      _ => AppColors.amber,
    };

    final String statusLabel = switch (status) {
      'published' => 'Đã publish',
      'draft' => 'Bản nháp',
      'reviewed' => 'Đã duyệt',
      'archived' => 'Đã lưu trữ',
      _ => quiz.status,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PortalGlassCard(
        accentBorder: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PortalBadge(text: statusLabel, color: statusColor),
                const Spacer(),
                Icon(
                  Icons.quiz_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${quiz.questionCount} câu',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              quiz.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version ${quiz.version ?? 1} • ${quiz.generatedBy ?? 'unknown'}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.subtitleAccent,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onViewQuestions,
                icon: Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.subtitleAccent,
                ),
                label: const Text(
                  'Xem câu hỏi',
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.subtitleAccent,
                  side: BorderSide(
                    color: AppColors.subtitleAccent.withOpacity(0.45),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  minimumSize: const Size(0, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final StaffQuizQuestionModel question;

  const _QuestionCard({required this.question});

  List<String> _parseOptions(String? optionsJson) {
    if (optionsJson == null || optionsJson.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(optionsJson);

      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = question.type;
    final difficulty = question.difficulty ?? 'unknown';
    final options = _parseOptions(question.optionsJson);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PortalGlassCard(
        accentBorder: AppColors.subtitleAccent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PortalBadge(
                  text: 'Câu ${question.questionOrder ?? '-'}',
                  color: AppColors.subtitleAccent,
                ),
                const SizedBox(width: 8),
                PortalBadge(
                  text: type,
                  color: AppColors.amber,
                ),
                const Spacer(),
                Text(
                  difficulty,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              question.questionText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            if (options.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...options.asMap().entries.map((entry) {
                final index = entry.key;
                final optionText = entry.value;
                final label = String.fromCharCode(65 + index); // A, B, C, D
                final isCorrect = question.correctAnswer?.trim().toUpperCase() == label;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect
                            ? AppColors.success.withOpacity(0.7)
                            : AppColors.subtitleAccent.withOpacity(0.25),
                      ),
                      color: isCorrect
                          ? AppColors.success.withOpacity(0.10)
                          : Colors.transparent,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$label. ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isCorrect
                                ? AppColors.success
                                : AppColors.subtitleAccent,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            optionText,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 8),
            Text(
              'Đáp án: ${question.correctAnswer ?? '-'}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            if (question.explanation != null &&
                question.explanation!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                question.explanation!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return PortalGlassCard(
      accentBorder: AppColors.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Không tải được dữ liệu quiz',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return PortalGlassCard(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}