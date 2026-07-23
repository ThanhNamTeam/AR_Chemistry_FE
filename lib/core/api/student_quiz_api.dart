import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/student_quiz_attempt_detail_model.dart';
import '../../domain/models/student_quiz_attempt_history_model.dart';
import '../../domain/models/student_quiz_detail_model.dart';
import '../../domain/models/student_quiz_summary_model.dart';
import '../../domain/models/student_reaction_detail_model.dart';
import '../../domain/models/student_reaction_model.dart';
import '../constants/api_constants.dart';
import '../models/response/page_response.dart';
import '../models/response/submit_quiz_response_model.dart';
import '../services/auth_token_service.dart';

class StudentQuizApi {
  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in',
      );
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeDataMap(
      http.Response response, {
        required String errorMessage,
      }) {
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        '$errorMessage: '
            '${response.statusCode} - ${response.body}',
      );
    }

    final body =
    jsonDecode(response.body) as Map<String, dynamic>;

    final data = body['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception(
        '$errorMessage: invalid response data',
      );
    }

    return data;
  }

  /*
   * GET /student/reactions/{reactionId}/quiz
   */
  Future<StudentQuizSummaryModel?>
  getPublishedQuizByReaction({
    required String reactionId,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .get(
      Uri.parse(
        ApiConstants
            .studentPublishedQuizByReactionUrl(
          reactionId,
        ),
      ),
      headers: headers,
    )
        .timeout(ApiConstants.timeout);

    if (response.statusCode == 404) {
      return null;
    }

    final data = _decodeDataMap(
      response,
      errorMessage: 'Load published quiz failed',
    );

    return StudentQuizSummaryModel.fromJson(data);
  }

  /*
   * POST /student/reactions/{reactionId}/attempts
   *
   * Backend trả StartQuizResponse.
   * Tạm dùng Map nếu bạn chưa tạo model.
   */
  Future<Map<String, dynamic>> startQuiz({
    required String reactionId,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .post(
      Uri.parse(
        ApiConstants.studentStartAttemptUrl(
          reactionId,
        ),
      ),
      headers: headers,
    )
        .timeout(ApiConstants.timeout);

    return _decodeDataMap(
      response,
      errorMessage: 'Start quiz failed',
    );
  }

  /*
   * POST /student/quiz-attempts/{attemptCode}/complete-ar
   */
  Future<Map<String, dynamic>> completeAr({
    required String attemptCode,
    required List<String> scannedCardCodes,
    required bool reactionSuccessful,
    String? arSessionCode,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .post(
      Uri.parse(
        ApiConstants.studentCompleteArUrl(
          attemptCode,
        ),
      ),
      headers: headers,
      body: jsonEncode({
        'scannedCardCodes': scannedCardCodes,
        'reactionSuccessful': reactionSuccessful,
        if (arSessionCode != null &&
            arSessionCode.trim().isNotEmpty)
          'arSessionCode': arSessionCode.trim(),
      }),
    )
        .timeout(ApiConstants.timeout);

    return _decodeDataMap(
      response,
      errorMessage: 'Complete AR failed',
    );
  }

  /*
   * GET /student/quiz-attempts/{attemptCode}/state
   */
  Future<Map<String, dynamic>> getAttemptState({
    required String attemptCode,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .get(
      Uri.parse(
        ApiConstants.studentAttemptStateUrl(
          attemptCode,
        ),
      ),
      headers: headers,
    )
        .timeout(ApiConstants.timeout);

    return _decodeDataMap(
      response,
      errorMessage: 'Load attempt state failed',
    );
  }

  /*
   * GET /student/quiz-attempts/{attemptCode}/content
   */
  Future<StudentQuizDetailModel> getQuizContent({
    required String attemptCode,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .get(
      Uri.parse(
        ApiConstants.studentQuizContentUrl(
          attemptCode,
        ),
      ),
      headers: headers,
    )
        .timeout(ApiConstants.timeout);

    final data = _decodeDataMap(
      response,
      errorMessage: 'Load quiz content failed',
    );

    return StudentQuizDetailModel.fromJson(data);
  }

  /*
   * PUT /student/quiz-attempts/{attemptCode}/answers/{questionId}
   */
  Future<void> saveAnswer({
    required String attemptCode,
    required String questionId,
    required String selectedAnswer,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .put(
      Uri.parse(
        ApiConstants.studentSaveAnswerUrl(
          attemptCode: attemptCode,
          questionId: questionId,
        ),
      ),
      headers: headers,
      body: jsonEncode({
        'answer': selectedAnswer,
      }),
    )
        .timeout(ApiConstants.timeout);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Save answer failed: '
            '${response.statusCode} - ${response.body}',
      );
    }
  }

  /*
   * POST /student/quiz-attempts/{attemptCode}/submit
   */
  Future<SubmitQuizResponseModel> submitAttempt({
    required String attemptCode,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .post(
      Uri.parse(
        ApiConstants.studentSubmitAttemptUrl(
          attemptCode,
        ),
      ),
      headers: headers,
    )
        .timeout(ApiConstants.timeout);

    final data = _decodeDataMap(
      response,
      errorMessage: 'Submit quiz failed',
    );

    return SubmitQuizResponseModel.fromJson(data);
  }

  /*
   * GET /student/quiz-attempts/{attemptCode}/result
   */
  Future<StudentQuizAttemptDetailModel>
  getQuizAttemptResult({
    required String attemptCode,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .get(
      Uri.parse(
        ApiConstants.studentAttemptResultUrl(
          attemptCode,
        ),
      ),
      headers: headers,
    )
        .timeout(ApiConstants.timeout);

    final data = _decodeDataMap(
      response,
      errorMessage: 'Load attempt result failed',
    );

    return StudentQuizAttemptDetailModel.fromJson(
      data,
    );
  }

  /*
   * GET /student/reactions/{reactionId}/attempt-history
   */
  Future<PageResponse<
      StudentQuizAttemptHistoryModel>>
  getReactionAttemptHistory({
    required String reactionId,
    int page = 0,
    int size = 10,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .get(
      Uri.parse(
        ApiConstants.studentReactionHistoryUrl(
          reactionId,
          page: page,
          size: size,
        ),
      ),
      headers: headers,
    )
        .timeout(ApiConstants.timeout);

    final data = _decodeDataMap(
      response,
      errorMessage: 'Load quiz history failed',
    );

    return PageResponse<
        StudentQuizAttemptHistoryModel>.fromJson(
      data,
          (item) =>
          StudentQuizAttemptHistoryModel.fromJson(
            item,
          ),
    );
  }

  /*
   * POST /student/quiz-attempts/{attemptCode}/abandon
   */
  Future<void> abandonAttempt({
    required String attemptCode,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .post(
      Uri.parse(
        ApiConstants.studentAbandonAttemptUrl(
          attemptCode,
        ),
      ),
      headers: headers,
    )
        .timeout(ApiConstants.timeout);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Abandon quiz attempt failed: '
            '${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PageResponse<StudentReactionModel>> getReactions({
    required int grade,
    required String reactionCategory,
    String? keyword,
    int page = 0,
    int size = 10,
  }) async {
    final headers = await _authHeaders();

    final url = ApiConstants.studentReactionsUrl(
      grade: grade,
      reactionCategory: reactionCategory,
      keyword: keyword,
      page: page,
      size: size,
    );

    debugPrint('[STUDENT-QUIZ-API] GET $url');

    final response = await http
        .get(
      Uri.parse(url),
      headers: headers,
    )
        .timeout(ApiConstants.timeout);

    debugPrint(
      '[STUDENT-QUIZ-API] status=${response.statusCode}',
    );

    debugPrint(
      '[STUDENT-QUIZ-API] body=${response.body}',
    );

    final data = _decodeDataMap(
      response,
      errorMessage: 'Load reactions failed',
    );

    return PageResponse<StudentReactionModel>.fromJson(
      data,
          (item) => StudentReactionModel.fromJson(item),
    );
  }

  Future<StudentReactionDetailModel> getReactionDetail({
    required String reactionId,
  }) async {
    final headers = await _authHeaders();

    final response = await http
        .get(
      Uri.parse(
        ApiConstants.studentReactionDetailUrl(
          reactionId,
        ),
      ),
      headers: headers,
    )
        .timeout(ApiConstants.timeout);

    final data = _decodeDataMap(
      response,
      errorMessage: 'Load reaction detail failed',
    );

    return StudentReactionDetailModel.fromJson(data);
  }
}

