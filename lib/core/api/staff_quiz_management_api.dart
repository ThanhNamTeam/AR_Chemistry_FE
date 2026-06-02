import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/staff_lesson_content_model.dart';
import '../../domain/models/staff_quiz_detail_model.dart';
import '../../domain/models/staff_quiz_summary_model.dart';
import '../constants/api_constants.dart';
import '../models/request/start_quiz_import_request.dart';
import '../models/response/page_response.dart';
import '../../domain/models/staff_lesson_quiz_overview_model.dart';
import '../services/auth_token_service.dart';

class StaffQuizManagementApi {
  Future<PageResponse<StaffLessonQuizOverviewModel>> getQuizManagementLessons({
    int page = 0,
    int size = 20,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load quiz overview');
    }

    final uri = Uri.parse(ApiConstants.staffQuizOverviewUrl).replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return PageResponse<StaffLessonQuizOverviewModel>.fromJson(
        data,
            (item) => StaffLessonQuizOverviewModel.fromJson(item),
      );
    }

    throw Exception(
      'Load quiz overview failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<List<StaffQuizSummaryModel>> getLessonQuizzes({
    required String lessonCode,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load lesson quizzes');
    }

    final uri = Uri.parse(ApiConstants.staffLessonQuizzesUrl(lessonCode)).replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      return items
          .map(
            (item) => StaffQuizSummaryModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    throw Exception(
      'Load lesson quizzes failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<StaffQuizDetailModel> getQuizDetail({
    required String quizCode,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load quiz detail');
    }

    final uri = Uri.parse(ApiConstants.staffQuizQuestionsUrl(quizCode)).replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return StaffQuizDetailModel.fromJson(data);
    }

    throw Exception(
      'Load quiz detail failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<void> startQuizImport(StartQuizImportRequest request) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot start quiz import');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.staffQuizImportStartUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      'Start quiz import failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<String> getLessonContent({
    required String lessonCode,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load lesson content');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.staffLessonContentUrl(lessonCode)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['data'] as String? ?? '';
    }

    throw Exception(
      'Load lesson content failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<void> publishQuiz(String quizCode) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot publish quiz');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.staffQuizPublishUrl(quizCode)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      'Publish quiz failed: ${response.statusCode} - ${response.body}',
    );
  }
}