import 'package:flutter/foundation.dart';

import '../../../core/storage/feedback_storage_service.dart';
import '../../../domain/models/feedback_model.dart';
import '../../../domain/models/quiz_draft_model.dart';

class StaffFeedbackItem {
  final String id;
  final String title;
  final String content;
  final FeedbackType type;
  final bool anonymous;
  final String? imageUrl;
  final String? reporterName;
  final String? reporterEmail;
  final String? staffResponse;
  final DateTime submittedAt;

  StaffFeedbackItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.anonymous,
    this.imageUrl,
    this.reporterName,
    this.reporterEmail,
    this.staffResponse,
    required this.submittedAt,
  });

  StaffFeedbackItem copyWith({String? staffResponse}) => StaffFeedbackItem(
        id: id,
        title: title,
        content: content,
        type: type,
        anonymous: anonymous,
        imageUrl: imageUrl,
        reporterName: reporterName,
        reporterEmail: reporterEmail,
        staffResponse: staffResponse ?? this.staffResponse,
        submittedAt: submittedAt,
      );
}

class StaffProvider extends ChangeNotifier {
  final FeedbackStorageService _feedbackStorage = FeedbackStorageService();

  List<StaffFeedbackItem> _feedbacks = [];
  List<QuizDraftModel> _quizDrafts = [];
  bool _loading = false;

  List<StaffFeedbackItem> get feedbacks => List.unmodifiable(_feedbacks);
  List<QuizDraftModel> get quizDrafts => List.unmodifiable(_quizDrafts);
  List<QuizDraftModel> get pendingQuizzes =>
      _quizDrafts.where((q) => q.status == QuizDraftStatus.pendingReview).toList();
  bool get isLoading => _loading;

  int get totalFeedbacks => _feedbacks.length;
  int get awaitingResponseCount =>
      _feedbacks.where((f) => f.staffResponse == null).length;
  int get respondedCount =>
      _feedbacks.where((f) => f.staffResponse != null).length;
  int get approvedQuizzesCount => _quizDrafts
      .where((q) => q.status == QuizDraftStatus.approved)
      .length;
  int get rejectedQuizzesCount => _quizDrafts
      .where((q) => q.status == QuizDraftStatus.rejected)
      .length;

  /// Mock weekly feedback volume for dashboard chart.
  List<({String label, double value})> get feedbackTrendWeek => const [
        (label: 'T2', value: 4),
        (label: 'T3', value: 7),
        (label: 'T4', value: 5),
        (label: 'T5', value: 9),
        (label: 'T6', value: 6),
        (label: 'T7', value: 3),
        (label: 'CN', value: 2),
      ];

  List<StaffFeedbackItem> get recentFeedbacks {
    final sorted = List<StaffFeedbackItem>.from(_feedbacks)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return sorted.take(3).toList();
  }

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    await _loadFeedbacks();
    _seedMockQuizDrafts();
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadFeedbacks() async {
    final raw = await _feedbackStorage.getSubmissions();
    final items = <StaffFeedbackItem>[];

    for (var i = 0; i < raw.length; i++) {
      final m = raw[i];
      final typeStr = m['type'] as String? ?? 'BUG';
      final type = FeedbackType.values.firstWhere(
        (t) => t.apiValue == typeStr,
        orElse: () => FeedbackType.bug,
      );
      items.add(StaffFeedbackItem(
        id: 'fb_$i',
        title: m['title'] as String? ?? 'Không tiêu đề',
        content: m['content'] as String? ?? '',
        type: type,
        anonymous: m['anonymous'] as bool? ?? false,
        imageUrl: m['imageUrl'] as String?,
        reporterName: m['reporterName'] as String?,
        reporterEmail: m['reporterEmail'] as String?,
        staffResponse: m['staffResponse'] as String?,
        submittedAt: DateTime.tryParse(m['submittedAt'] as String? ?? '') ??
            DateTime.now(),
      ));
    }

    if (items.isEmpty) {
      items.addAll(_mockFeedbacks());
    }

    _feedbacks = items;
  }

  List<StaffFeedbackItem> _mockFeedbacks() => [
        StaffFeedbackItem(
          id: 'mock_1',
          title: 'Lỗi hiển thị quiz',
          content: 'Khó hiển thị quiz trên màn hình nhỏ.',
          type: FeedbackType.bug,
          anonymous: false,
          reporterName: 'Nam',
          reporterEmail: 'user@example.com',
          submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        StaffFeedbackItem(
          id: 'mock_2',
          title: 'Trải nghiệm mua thẻ',
          content: 'Muốn có thêm combo giá tốt hơn.',
          type: FeedbackType.experience,
          anonymous: true,
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  void _seedMockQuizDrafts() {
    if (_quizDrafts.isNotEmpty) return;
    _quizDrafts = [
      QuizDraftModel(
        id: 'q1',
        title: 'Phản ứng axit-bazơ cơ bản',
        topic: 'Acid-Base',
        sourceDocument: 'acid_base_chapter.pdf',
        status: QuizDraftStatus.pendingReview,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      QuizDraftModel(
        id: 'q2',
        title: 'Cân bằng phương trình hóa học',
        topic: 'Balancing Equations',
        sourceDocument: 'balancing_lab.docx',
        status: QuizDraftStatus.pendingReview,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  Future<void> submitFeedbackResponse(String id, String response) async {
    final idx = _feedbacks.indexWhere((f) => f.id == id);
    if (idx < 0) return;
    _feedbacks[idx] = _feedbacks[idx].copyWith(staffResponse: response);
    notifyListeners();
  }

  Future<void> simulateDocumentUpload(String fileName) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _quizDrafts.insert(
      0,
      QuizDraftModel(
        id: 'q_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Quiz tự sinh — ${fileName.split('.').first}',
        topic: 'Hóa học AR',
        sourceDocument: fileName,
        status: QuizDraftStatus.pendingReview,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void approveQuiz(String id, {String? note}) {
    _updateQuiz(id, QuizDraftStatus.approved, note);
  }

  void rejectQuiz(String id, {String? note}) {
    _updateQuiz(id, QuizDraftStatus.rejected, note);
  }

  void _updateQuiz(String id, QuizDraftStatus status, String? note) {
    final idx = _quizDrafts.indexWhere((q) => q.id == id);
    if (idx < 0) return;
    _quizDrafts[idx] =
        _quizDrafts[idx].copyWith(status: status, staffNote: note);
    notifyListeners();
  }
}
