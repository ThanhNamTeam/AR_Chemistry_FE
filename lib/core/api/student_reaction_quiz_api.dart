import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/auth_token_service.dart';
import '../../domain/models/student_quiz_attempt_history_model.dart';
import '../../domain/models/student_reaction_quiz_models.dart';

/// Client cho luồng quiz MỚI theo phản ứng (StudentQuizController).
///
/// Vòng đời một attempt:
///   start -> WAITING_AR -> (quét 2 thẻ + phản ứng AR ok -> complete-ar)
///         -> RUNNING (7 phút, autosave từng đáp án) -> submit/timeout.
class StudentReactionQuizApi {
  Future<Map<String, String>> _headers() async {
    final token = await AuthTokenService.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _data(http.Response response, String action) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        '$action failed: ${response.statusCode} - ${response.body}',
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['data'] as Map<String, dynamic>?) ?? const {};
  }

  Future<({List<StudentReactionModel> items, bool hasNext})> getReactions({
    required int grade,
    required String reactionCategory,
    String keyword = '',
    int page = 0,
    int size = 10,
  }) async {
    final response = await http
        .get(
          Uri.parse(ApiConstants.studentReactionsUrl(
            grade: grade,
            reactionCategory: reactionCategory,
            keyword: keyword,
            page: page,
            size: size,
          )),
          headers: await _headers(),
        )
        .timeout(ApiConstants.timeout);

    final data = _data(response, 'Load reactions');
    final items = (data['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(StudentReactionModel.fromJson)
        .toList();
    return (items: items, hasNext: data['hasNext'] == true);
  }

  /// Start (hoặc lấy lại attempt WAITING_AR/RUNNING đang có — BE tự xử lý).
  Future<StartQuizModel> startAttempt(String reactionId) async {
    final response = await http
        .post(
          Uri.parse(ApiConstants.studentStartAttemptUrl(reactionId)),
          headers: await _headers(),
        )
        .timeout(ApiConstants.timeout);
    return StartQuizModel.fromJson(_data(response, 'Start attempt'));
  }

  Future<QuizAttemptStateModel> getState(String attemptCode) async {
    final response = await http
        .get(
          Uri.parse(ApiConstants.studentAttemptStateUrl(attemptCode)),
          headers: await _headers(),
        )
        .timeout(ApiConstants.timeout);
    return QuizAttemptStateModel.fromJson(_data(response, 'Load state'));
  }

  /// Báo BE là AR đã thực hiện thành công — mở khoá câu hỏi, bắt đầu timer.
  Future<void> completeAr(
    String attemptCode, {
    required List<String> scannedCardCodes,
    String? arSessionCode,
  }) async {
    final response = await http
        .post(
          Uri.parse(ApiConstants.studentCompleteArUrl(attemptCode)),
          headers: await _headers(),
          body: jsonEncode({
            'scannedCardCodes': scannedCardCodes,
            'reactionSuccessful': true,
            if (arSessionCode != null) 'arSessionCode': arSessionCode,
          }),
        )
        .timeout(ApiConstants.timeout);
    _data(response, 'Complete AR');
  }

  Future<QuizContentModel> getContent(String attemptCode) async {
    final response = await http
        .get(
          Uri.parse(ApiConstants.studentAttemptContentUrl(attemptCode)),
          headers: await _headers(),
        )
        .timeout(ApiConstants.timeout);
    return QuizContentModel.fromJson(_data(response, 'Load content'));
  }

  Future<void> saveAnswer(
    String attemptCode,
    String questionId,
    String selectedAnswer,
  ) async {
    final response = await http
        .put(
          Uri.parse(
              ApiConstants.studentSaveAnswerUrl(
                attemptCode: attemptCode,
                questionId: questionId,
              )
          ),
          headers: await _headers(),
          // BE SaveQuizAnswerRequest chỉ có một field tên `answer`.
          body: jsonEncode({'answer': selectedAnswer}),
        )
        .timeout(ApiConstants.timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Save answer failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> submit(String attemptCode) async {
    final response = await http
        .post(
          Uri.parse(ApiConstants.studentSubmitAttemptUrl(attemptCode)),
          headers: await _headers(),
        )
        .timeout(ApiConstants.timeout);
    _data(response, 'Submit');
  }

  Future<void> abandon(String attemptCode) async {
    final response = await http
        .post(
          Uri.parse(ApiConstants.studentAbandonAttemptUrl(attemptCode)),
          headers: await _headers(),
        )
        .timeout(ApiConstants.timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Abandon failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<({List<StudentQuizAttemptHistoryModel> items, bool hasNext})>
      getReactionHistory(
    String reactionId, {
    int page = 0,
    int size = 10,
  }) async {
    final response = await http
        .get(
          Uri.parse(ApiConstants.studentReactionHistoryUrl(
            reactionId,
            page: page,
            size: size,
          )),
          headers: await _headers(),
        )
        .timeout(ApiConstants.timeout);

    final data = _data(response, 'Load history');
    final items = (data['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((j) => StudentQuizAttemptHistoryModel.fromJson(j))
        .toList();
    return (items: items, hasNext: data['hasNext'] == true);
  }
}
