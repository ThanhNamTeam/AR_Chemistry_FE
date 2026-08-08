import 'package:flutter/foundation.dart';

import '../../../core/api/feedback_api_service.dart';
import '../../../core/api/staff_quiz_management_api.dart';
import '../../../core/api/upload_api.dart';
import '../../../core/models/request/generate_upload_url_request.dart';
import '../../../core/models/request/start_quiz_import_request.dart';
import '../../../domain/models/staff_lesson_content_model.dart';
import '../../../domain/models/staff_quiz_attempt_detail_model.dart';
import '../../../domain/models/staff_quiz_attempt_model.dart';
import '../../../domain/models/staff_quiz_detail_model.dart';
import '../../../domain/models/staff_quiz_summary_model.dart';
import '../../../domain/models/feedback_model.dart';
import '../../../domain/models/quiz_draft_model.dart';
import '../../../domain/models/staff_lesson_quiz_overview_model.dart';
import '../../../domain/models/staff_reaction_quiz_overview_model.dart';
import '../../../domain/models/staff_reaction_quiz_prompt_model.dart';

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
  final String status;
  final String priority;

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
    required this.status,
    required this.priority,
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
    status: status,
    priority: priority,
  );
}

class StaffProvider extends ChangeNotifier {

  List<StaffFeedbackItem> _feedbacks = [];
  final List<QuizDraftModel> _quizDrafts = [];
  bool _loading = false;

  final FeedbackApiService _feedbackApi = FeedbackApiService();

  final StaffQuizManagementApi _staffQuizManagementApi =
      StaffQuizManagementApi();

  final UploadApi _uploadApi = UploadApi();

  bool _importingQuizCsv = false;
  String? _quizImportError;

  List<StaffQuizAttemptModel> _quizAttempts = [];
  bool _loadingQuizAttempts = false;
  String? _quizAttemptsError;

  StaffQuizAttemptDetailModel? _selectedQuizAttemptDetail;
  bool _loadingQuizAttemptDetail = false;
  String? _quizAttemptDetailError;

  List<StaffQuizAttemptModel> get quizAttempts =>
      List.unmodifiable(_quizAttempts);

  bool get loadingQuizAttempts => _loadingQuizAttempts;

  String? get quizAttemptsError => _quizAttemptsError;

  StaffQuizAttemptDetailModel? get selectedQuizAttemptDetail =>
      _selectedQuizAttemptDetail;

  bool get loadingQuizAttemptDetail => _loadingQuizAttemptDetail;

  String? get quizAttemptDetailError => _quizAttemptDetailError;

  String? _selectedLessonContent;
  bool _loadingLessonContent = false;
  String? _lessonContentError;

  bool _publishingQuiz = false;
  String? _publishQuizError;

  bool get publishingQuiz => _publishingQuiz;

  String? get publishQuizError => _publishQuizError;

  String? get selectedLessonContent => _selectedLessonContent;

  bool get loadingLessonContent => _loadingLessonContent;

  String? get lessonContentError => _lessonContentError;

  bool get importingQuizCsv => _importingQuizCsv;

  String? get quizImportError => _quizImportError;

  List<StaffReactionQuizOverviewModel> _reactionQuizOverviews = [];
  bool _loadingReactionQuizOverviews = false;
  String? _reactionQuizOverviewError;

  String? _selectedReactionCode;
  List<StaffQuizSummaryModel> _selectedReactionQuizzes = [];
  bool _loadingSelectedReactionQuizzes = false;
  String? _selectedReactionQuizError;

  StaffReactionQuizPromptModel? _selectedReactionPrompt;
  bool _loadingReactionPrompt = false;
  String? _reactionPromptError;

  List<StaffReactionQuizOverviewModel> get reactionQuizOverviews =>
      List.unmodifiable(_reactionQuizOverviews);

  bool get loadingReactionQuizOverviews =>
      _loadingReactionQuizOverviews;

  String? get reactionQuizOverviewError =>
      _reactionQuizOverviewError;

  String? get selectedReactionCode => _selectedReactionCode;

  List<StaffQuizSummaryModel> get selectedReactionQuizzes =>
      List.unmodifiable(_selectedReactionQuizzes);

  bool get loadingSelectedReactionQuizzes =>
      _loadingSelectedReactionQuizzes;

  String? get selectedReactionQuizError =>
      _selectedReactionQuizError;

  StaffReactionQuizPromptModel? get selectedReactionPrompt =>
      _selectedReactionPrompt;

  bool get loadingReactionPrompt => _loadingReactionPrompt;

  String? get reactionPromptError => _reactionPromptError;

  List<StaffLessonQuizOverviewModel> _lessonQuizOverviews = [];
  bool _loadingLessonQuizOverviews = false;
  String? _lessonQuizOverviewError;

  String? _selectedLessonCode;
  List<StaffQuizSummaryModel> _selectedLessonQuizzes = [];
  bool _loadingSelectedLessonQuizzes = false;
  String? _selectedLessonQuizError;

  StaffLessonQuizPromptModel? _selectedLessonPrompt;
  bool _loadingLessonPrompt = false;
  String? _lessonPromptError;

  StaffLessonQuizPromptModel? get selectedLessonPrompt => _selectedLessonPrompt;

  bool get loadingLessonPrompt => _loadingLessonPrompt;

  String? get lessonPromptError => _lessonPromptError;

  StaffQuizDetailModel? _selectedQuizDetail;
  bool _loadingQuizDetail = false;
  String? _quizDetailError;

  StaffQuizDetailModel? get selectedQuizDetail => _selectedQuizDetail;

  bool get loadingQuizDetail => _loadingQuizDetail;

  String? get quizDetailError => _quizDetailError;

  String? get selectedLessonCode => _selectedLessonCode;

  List<StaffQuizSummaryModel> get selectedLessonQuizzes =>
      List.unmodifiable(_selectedLessonQuizzes);

  bool get loadingSelectedLessonQuizzes => _loadingSelectedLessonQuizzes;

  String? get selectedLessonQuizError => _selectedLessonQuizError;

  List<StaffLessonQuizOverviewModel> get lessonQuizOverviews =>
      List.unmodifiable(_lessonQuizOverviews);

  bool get loadingLessonQuizOverviews => _loadingLessonQuizOverviews;

  String? get lessonQuizOverviewError => _lessonQuizOverviewError;

  List<StaffFeedbackItem> get feedbacks => List.unmodifiable(_feedbacks);

  List<QuizDraftModel> get quizDrafts => List.unmodifiable(_quizDrafts);

  List<QuizDraftModel> get pendingQuizzes => _quizDrafts
      .where((q) => q.status == QuizDraftStatus.pendingReview)
      .toList();

  bool get isLoading => _loading;

  int get totalFeedbacks => _feedbacks.length;

  int get awaitingResponseCount =>
      _feedbacks.where((f) => f.staffResponse == null).length;

  int get respondedCount =>
      _feedbacks.where((f) => f.staffResponse != null).length;

  int get approvedQuizzesCount =>
      _quizDrafts.where((q) => q.status == QuizDraftStatus.approved).length;

  int get rejectedQuizzesCount =>
      _quizDrafts.where((q) => q.status == QuizDraftStatus.rejected).length;

  /// Mock weekly feedback volume for dashboard chart.
  // feedbackTrendWeek đã xoá: đó là dãy số bịa hard-code, không phải dữ liệu
  // backend. Khi nào BE có API thống kê feedback theo tuần thì thêm lại.

  List<StaffFeedbackItem> get recentFeedbacks {
    final sorted = List<StaffFeedbackItem>.from(_feedbacks)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return sorted.take(3).toList();
  }

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    await _loadFeedbacks();
    await loadReactionQuizOverviews();

    _loading = false;
    notifyListeners();
  }

  Future<void> loadQuizAttempts({int page = 0, int size = 10}) async {
    _loadingQuizAttempts = true;
    _quizAttemptsError = null;
    notifyListeners();

    try {
      final result = await _staffQuizManagementApi.getQuizAttempts(
        page: page,
        size: size,
      );

      _quizAttempts = result.items;
    } catch (e) {
      _quizAttemptsError = e.toString();
    } finally {
      _loadingQuizAttempts = false;
      notifyListeners();
    }
  }

  Future<void> loadQuizAttemptDetail(String attemptCode) async {
    _loadingQuizAttemptDetail = true;
    _quizAttemptDetailError = null;
    _selectedQuizAttemptDetail = null;
    notifyListeners();

    try {
      _selectedQuizAttemptDetail = await _staffQuizManagementApi
          .getQuizAttemptDetail(attemptCode: attemptCode);
    } catch (e) {
      _quizAttemptDetailError = e.toString();
    } finally {
      _loadingQuizAttemptDetail = false;
      notifyListeners();
    }
  }

  void clearQuizAttemptDetail() {
    _selectedQuizAttemptDetail = null;
    _quizAttemptDetailError = null;
    _loadingQuizAttemptDetail = false;
    notifyListeners();
  }

  Future<void> publishQuiz(String quizCode) async {
    _publishingQuiz = true;
    _publishQuizError = null;
    notifyListeners();

    try {
      await _staffQuizManagementApi.publishQuiz(quizCode);

      await loadQuizDetail(quizCode);

      if (_selectedReactionCode != null) {
        await loadQuizzesByReaction(_selectedReactionCode!);
      }

      await loadReactionQuizOverviews();
    } catch (e) {
      _publishQuizError = e.toString();
      rethrow;
    } finally {
      _publishingQuiz = false;
      notifyListeners();
    }
  }
  Future<void> importQuizCsv({
    required String reactionCode,
    required String fileName,
    required Uint8List bytes,
    required int fileSize,
  }) async {
    _importingQuizCsv = true;
    _quizImportError = null;
    notifyListeners();

    try {
      const contentType = 'text/csv';

      final presigned = await _uploadApi.generateUploadUrl(
        GenerateUploadUrlRequest(
          fileName: fileName,
          contentType: contentType,
          fileSize: fileSize,
          purposeCode: 'QUIZ_IMPORT',
        ),
      );

      await _uploadApi.uploadFileToS3(
        uploadUrl: presigned.uploadUrl,
        bytes: bytes,
        contentType: presigned.contentType,
      );

      await _staffQuizManagementApi.startQuizImport(
        StartQuizImportRequest(
          reactionCode: reactionCode,
          s3Key: presigned.storageKey,
          originalFilename: fileName,
        ),
      );

      await loadReactionQuizOverviews();

      if (_selectedReactionCode == reactionCode) {
        await loadQuizzesByReaction(reactionCode);
      }
    } catch (e) {
      _quizImportError = e.toString();
      rethrow;
    } finally {
      _importingQuizCsv = false;
      notifyListeners();
    }
  }

  Future<void> loadLessonContent(String lessonCode) async {
    _loadingLessonContent = true;
    _lessonContentError = null;
    notifyListeners();

    try {
      _selectedLessonContent = await _staffQuizManagementApi.getLessonContent(
        lessonCode: lessonCode,
      );
    } catch (e) {
      _lessonContentError = e.toString();
    } finally {
      _loadingLessonContent = false;
      notifyListeners();
    }
  }

  void clearSelectedLessonPrompt() {
    _selectedLessonPrompt = null;
    _lessonPromptError = null;
    _loadingLessonPrompt = false;
    notifyListeners();
  }

  Future<void> loadQuizDetail(
    String quizCode, {
    int page = 0,
    int size = 10,
  }) async {
    _loadingQuizDetail = true;
    _quizDetailError = null;
    notifyListeners();

    try {
      final result = await _staffQuizManagementApi.getQuizDetail(
        quizCode: quizCode,
        page: page,
        size: size,
      );

      _selectedQuizDetail = result;
    } catch (e) {
      _quizDetailError = e.toString();
    } finally {
      _loadingQuizDetail = false;
      notifyListeners();
    }
  }

  Future<void> loadQuizzesByLesson(String lessonCode) async {
    _selectedLessonCode = lessonCode;
    _loadingSelectedLessonQuizzes = true;
    _selectedLessonQuizError = null;
    notifyListeners();

    try {
      final result = await _staffQuizManagementApi.getLessonQuizzes(
        lessonCode: lessonCode,
      );

      _selectedLessonQuizzes = result;
    } catch (e) {
      _selectedLessonQuizError = e.toString();
    } finally {
      _loadingSelectedLessonQuizzes = false;
      notifyListeners();
    }
  }

  Future<void> loadReactionQuizOverviews({
    int page = 0,
    int size = 10,
  }) async {
    _loadingReactionQuizOverviews = true;
    _reactionQuizOverviewError = null;
    notifyListeners();

    try {
      final result =
      await _staffQuizManagementApi.getReactionQuizOverview(
        page: page,
        size: size,
      );

      _reactionQuizOverviews = result.items;
    } catch (e) {
      _reactionQuizOverviewError = e.toString();
    } finally {
      _loadingReactionQuizOverviews = false;
      notifyListeners();
    }
  }

  Future<void> loadQuizzesByReaction(
      String reactionCode, {
        int page = 0,
        int size = 10,
      }) async {
    _selectedReactionCode = reactionCode;
    _loadingSelectedReactionQuizzes = true;
    _selectedReactionQuizError = null;
    _selectedReactionQuizzes = [];
    notifyListeners();

    try {
      final result =
      await _staffQuizManagementApi.getQuizzesByReaction(
        reactionCode: reactionCode,
        page: page,
        size: size,
      );

      _selectedReactionQuizzes = result.items;
    } catch (e) {
      _selectedReactionQuizError = e.toString();
    } finally {
      _loadingSelectedReactionQuizzes = false;
      notifyListeners();
    }
  }

  Future<void> loadReactionQuizPrompt(
      String reactionCode,
      ) async {
    _loadingReactionPrompt = true;
    _reactionPromptError = null;
    _selectedReactionPrompt = null;
    notifyListeners();

    try {
      _selectedReactionPrompt =
      await _staffQuizManagementApi.getReactionQuizPrompt(
        reactionCode: reactionCode,
      );
    } catch (e) {
      _reactionPromptError = e.toString();
    } finally {
      _loadingReactionPrompt = false;
      notifyListeners();
    }
  }


  void clearSelectedReaction() {
    _selectedReactionCode = null;

    _selectedReactionQuizzes = [];
    _selectedReactionQuizError = null;
    _loadingSelectedReactionQuizzes = false;

    _selectedReactionPrompt = null;
    _reactionPromptError = null;
    _loadingReactionPrompt = false;

    _selectedQuizDetail = null;
    _quizDetailError = null;
    _loadingQuizDetail = false;

    notifyListeners();
  }
  Future<void> loadLessonQuizOverviews({int page = 0, int size = 20}) async {
    _loadingLessonQuizOverviews = true;
    _lessonQuizOverviewError = null;
    notifyListeners();

    try {
      final result = await _staffQuizManagementApi.getQuizManagementLessons(
        page: page,
        size: size,
      );

      _lessonQuizOverviews = result.items;
    } catch (e) {
      _lessonQuizOverviewError = e.toString();
    } finally {
      _loadingLessonQuizOverviews = false;
      notifyListeners();
    }
  }

  Future<void> _loadFeedbacks() async {
    final result = await _feedbackApi.getFeedbacksForStaff(page: 0, size: 50);

    _feedbacks = result.items.map((f) {
      final type = FeedbackType.values.firstWhere(
        (t) => t.apiValue == f.type,
        orElse: () => FeedbackType.bug,
      );

      return StaffFeedbackItem(
        id: f.id,
        title: f.title,
        content: '',
        type: type,
        anonymous: f.anonymous,
        imageUrl: null,
        reporterName: f.displayName,
        reporterEmail: null,
        staffResponse: f.status == 'RESOLVED' ? 'resolved' : null,
        submittedAt: f.createdAt ?? DateTime.now(),
        status: f.status,
        priority: f.priority,
      );
    }).toList();
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
    _quizDrafts[idx] = _quizDrafts[idx].copyWith(
      status: status,
      staffNote: note,
    );
    notifyListeners();
  }

  void clearSelectedLessonQuizzes() {
    _selectedLessonCode = null;
    _selectedLessonQuizzes = [];
    _selectedLessonQuizError = null;
    _loadingSelectedLessonQuizzes = false;

    _selectedQuizDetail = null;
    _quizDetailError = null;
    _loadingQuizDetail = false;

    _selectedLessonPrompt = null;
    _lessonPromptError = null;
    _loadingLessonPrompt = false;

    _selectedLessonContent = null;
    _lessonContentError = null;
    _loadingLessonContent = false;

    notifyListeners();
  }

  void clearSelectedQuizDetail() {
    _selectedQuizDetail = null;
    _quizDetailError = null;
    _loadingQuizDetail = false;
    notifyListeners();
  }

  void clearSelectedLessonContent() {
    _selectedLessonContent = null;
    _lessonContentError = null;
    _loadingLessonContent = false;
    notifyListeners();
  }
}
