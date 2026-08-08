import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/staff_lesson_quiz_overview_model.dart';
import '../../domain/models/staff_quiz_attempt_detail_model.dart';
import '../../domain/models/staff_quiz_attempt_model.dart';
import '../../domain/models/staff_quiz_detail_model.dart';
import '../../domain/models/staff_quiz_summary_model.dart';
import '../../domain/models/staff_reaction_quiz_overview_model.dart';
import '../../domain/models/staff_reaction_quiz_prompt_model.dart';
import '../constants/api_constants.dart';
import '../models/request/start_quiz_import_request.dart';
import '../models/response/page_response.dart';
import '../services/auth_token_service.dart';

class StaffQuizManagementApi {
  /// Reaction-based API mới.
  Future<PageResponse<StaffReactionQuizOverviewModel>>
  getReactionQuizOverview({
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot load reaction quiz overview',
      );
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.staffReactionQuizOverviewUrl(
          page: page,
          size: size,
        ),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json =
      jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return PageResponse<StaffReactionQuizOverviewModel>.fromJson(
        data,
        StaffReactionQuizOverviewModel.fromJson,
      );
    }

    throw Exception(
      'Load reaction quiz overview failed: '
          '${response.statusCode} - ${response.body}',
    );
  }

  /// Reaction-based API mới.
  Future<PageResponse<StaffQuizSummaryModel>>
  getQuizzesByReaction({
    required String reactionCode,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot load reaction quizzes',
      );
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.staffReactionQuizzesUrl(
          reactionCode: reactionCode,
          page: page,
          size: size,
        ),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json =
      jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return PageResponse<StaffQuizSummaryModel>.fromJson(
        data,
        StaffQuizSummaryModel.fromJson,
      );
    }

    throw Exception(
      'Load reaction quizzes failed: '
          '${response.statusCode} - ${response.body}',
    );
  }

  Future<StaffReactionQuizPromptModel> getReactionQuizPrompt({
    required String reactionCode,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot load reaction quiz prompt',
      );
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.staffReactionQuizPromptUrl(reactionCode),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json =
      jsonDecode(response.body) as Map<String, dynamic>;

      // Endpoint này trả QuizPromptResponse trực tiếp,
      // không có wrapper ApiResponse.data.
      return StaffReactionQuizPromptModel.fromJson(json);
    }

    throw Exception(
      'Load reaction quiz prompt failed: '
          '${response.statusCode} - ${response.body}',
    );
  }

  Future<StaffQuizDetailModel> getQuizDetail({
    required String quizCode,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot load quiz detail',
      );
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.staffQuizDetailUrl(
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

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json =
      jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return StaffQuizDetailModel.fromJson(data);
    }

    throw Exception(
      'Load quiz detail failed: '
          '${response.statusCode} - ${response.body}',
    );
  }

  Future<void> startQuizImport(
      StartQuizImportRequest request,
      ) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot start quiz import',
      );
    }

    final response = await http.post(
      Uri.parse(ApiConstants.staffQuizImportStartUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      'Start quiz import failed: '
          '${response.statusCode} - ${response.body}',
    );
  }

  Future<void> publishQuiz(String quizCode) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot publish quiz',
      );
    }

    final response = await http.post(
      Uri.parse(
        ApiConstants.staffQuizPublishUrl(quizCode),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      'Publish quiz failed: '
          '${response.statusCode} - ${response.body}',
    );
  }

  Future<PageResponse<StaffQuizAttemptModel>> getQuizAttempts({
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot load quiz attempts',
      );
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.staffQuizAttemptsUrl(
          page: page,
          size: size,
        ),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json =
      jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return PageResponse<StaffQuizAttemptModel>.fromJson(
        data,
        StaffQuizAttemptModel.fromJson,
      );
    }

    throw Exception(
      'Load quiz attempts failed: '
          '${response.statusCode} - ${response.body}',
    );
  }

  Future<StaffQuizAttemptDetailModel> getQuizAttemptDetail({
    required String attemptCode,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot load quiz attempt detail',
      );
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.staffQuizAttemptDetailUrl(attemptCode),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json =
      jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return StaffQuizAttemptDetailModel.fromJson(data);
    }

    throw Exception(
      'Load quiz attempt detail failed: '
          '${response.statusCode} - ${response.body}',
    );
  }

  // =========================================================
  // LEGACY LESSON-BASED METHODS
  // Giữ tạm để StaffProvider/StaffQuizTab cũ chưa bị compile error.
  // Không sử dụng cho reaction flow mới.
  // =========================================================

  @Deprecated(
    'Use getReactionQuizOverview() for the reaction-based flow.',
  )
  Future<PageResponse<StaffLessonQuizOverviewModel>>
  getQuizManagementLessons({
    int page = 0,
    int size = 20,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot load quiz overview',
      );
    }

    final uri = Uri.parse(
      ApiConstants.staffQuizOverviewUrl,
    ).replace(
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

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json =
      jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return PageResponse<StaffLessonQuizOverviewModel>.fromJson(
        data,
        StaffLessonQuizOverviewModel.fromJson,
      );
    }

    throw Exception(
      'Load quiz overview failed: '
          '${response.statusCode} - ${response.body}',
    );
  }

  @Deprecated(
    'Use getQuizzesByReaction() for the reaction-based flow.',
  )
  Future<List<StaffQuizSummaryModel>> getLessonQuizzes({
    required String lessonCode,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot load lesson quizzes',
      );
    }

    final uri = Uri.parse(
      ApiConstants.staffLessonQuizzesUrl(lessonCode),
    ).replace(
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

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json =
      jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final items =
          data['items'] as List<dynamic>? ?? const [];

      return items
          .whereType<Map>()
          .map(
            (item) => StaffQuizSummaryModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }

    throw Exception(
      'Load lesson quizzes failed: '
          '${response.statusCode} - ${response.body}',
    );
  }

  @Deprecated(
    'Use getReactionQuizPrompt() for the reaction-based flow.',
  )
  Future<String> getLessonContent({
    required String lessonCode,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not signed in, cannot load lesson content',
      );
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.staffLessonContentUrl(lessonCode),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json =
      jsonDecode(response.body) as Map<String, dynamic>;

      return json['data'] as String? ?? '';
    }

    throw Exception(
      'Load lesson content failed: '
          '${response.statusCode} - ${response.body}',
    );
  }
}