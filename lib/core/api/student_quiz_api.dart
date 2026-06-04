import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/student_published_quiz_model.dart';
import '../../domain/models/student_quiz_attempt_detail_model.dart';
import '../../domain/models/student_quiz_attempt_history_model.dart';
import '../constants/api_constants.dart';
import '../models/request/submit_quiz_request_model.dart';
import '../models/response/page_response.dart';
import '../models/response/submit_quiz_response_model.dart';
import '../services/auth_token_service.dart';
import '../../domain/models/student_quiz_detail_model.dart';
import '../../domain/models/student_quiz_summary_model.dart';


class StudentQuizApi {
  Future<StudentQuizSummaryModel?> getPublishedQuizByLesson({
    required String lessonCode,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load quiz');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.studentPublishedQuizByLessonUrl(lessonCode)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'];

      if (data == null) return null;

      return StudentQuizSummaryModel.fromJson(
        data as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Load published quiz failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<StudentQuizDetailModel> getQuizQuestions({
    required String quizCode,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load quiz questions');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.studentQuizQuestionsUrl(quizCode)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return StudentQuizDetailModel.fromJson(data);
    }

    throw Exception(
      'Load quiz questions failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<SubmitQuizResponseModel> submitQuiz({
    required String quizCode,
    required SubmitQuizRequestModel request,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot submit quiz');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.studentSubmitQuizUrl(quizCode)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return SubmitQuizResponseModel.fromJson(data);
    }

    throw Exception(
      'Submit quiz failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<List<StudentPublishedQuizModel>> getPublishedQuizzes() async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load published quizzes');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.studentPublishedQuizzesUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>? ?? [];

      return data
          .map(
            (item) => StudentPublishedQuizModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    throw Exception(
      'Load published quizzes failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<PageResponse<StudentQuizAttemptHistoryModel>> getQuizAttemptHistory({
    String? quizCode,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load quiz history');
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.studentQuizAttemptsUrl(
          quizCode: quizCode,
          page: page,
          size: size,
        ),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return PageResponse<StudentQuizAttemptHistoryModel>.fromJson(
        data,
            (item) => StudentQuizAttemptHistoryModel.fromJson(item),
      );
    }

    throw Exception(
      'Load quiz history failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<StudentQuizAttemptDetailModel> getQuizAttemptDetail({
    required String attemptCode,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load attempt detail');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.studentQuizAttemptDetailUrl(attemptCode)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return StudentQuizAttemptDetailModel.fromJson(data);
    }

    throw Exception(
      'Load attempt detail failed: ${response.statusCode} - ${response.body}',
    );
  }
}