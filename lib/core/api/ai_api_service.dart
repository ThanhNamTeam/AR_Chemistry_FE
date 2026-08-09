import 'package:dio/dio.dart';

import '../../domain/models/ai_chat_models.dart';
import '../constants/api_constants.dart';
import '../services/auth_token_service.dart';

class AiApiException implements Exception {
  AiApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AiApiService {
  AiApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _timeout = Duration(seconds: 60);

  Future<String?> _resolveToken() async {
    return AuthTokenService.getValidAccessToken();
  }

  Future<Options> _authOptions() async {
    final token = await _resolveToken();
    if (token == null || token.isEmpty) {
      throw AiApiException('Bạn cần đăng nhập để dùng trợ lý AI.');
    }
    return Options(
      headers: {'Authorization': 'Bearer $token'},
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
    );
  }

  T _parseEnvelope<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> data) mapper,
  ) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw AiApiException('Phản hồi không hợp lệ từ máy chủ.');
    }
    final success = body['success'] as bool? ?? false;
    if (!success) {
      throw AiApiException(
        body['message'] as String? ?? 'Yêu cầu thất bại.',
        statusCode: response.statusCode,
      );
    }
    final data = body['data'];
    if (data == null) {
      throw AiApiException('Không có dữ liệu trong phản hồi.');
    }
    if (data is Map<String, dynamic>) {
      return mapper(data);
    }
    throw AiApiException('Định dạng dữ liệu không hợp lệ.');
  }

  List<T> _parseEnvelopeList<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> item) mapper,
  ) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw AiApiException('Phản hồi không hợp lệ từ máy chủ.');
    }
    final success = body['success'] as bool? ?? false;
    if (!success) {
      throw AiApiException(
        body['message'] as String? ?? 'Yêu cầu thất bại.',
        statusCode: response.statusCode,
      );
    }
    final data = body['data'];
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(mapper)
        .toList();
  }

  Future<AiChatResult> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.aiChatUrl,
        data: {
          'message': message,
          if (conversationId != null && conversationId.isNotEmpty)
            'conversationId': conversationId,
        },
        options: await _authOptions(),
      );
      return _parseEnvelope(response, AiChatResult.fromJson);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<List<ConversationSummary>> getConversations() async {
    try {
      final response = await _dio.get(
        ApiConstants.aiConversationsUrl,
        options: await _authOptions(),
      );
      return _parseEnvelopeList(
        response,
        ConversationSummary.fromJson,
      );
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<List<ChatMessage>> getConversationMessages(String id) async {
    try {
      final response = await _dio.get(
        ApiConstants.aiConversationDetailUrl(id),
        options: await _authOptions(),
      );
      return _parseEnvelope(response, messagesFromConversationDetail);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  /// Chấm câu trả lời AI: 1 = 👍, -1 = 👎, 0 = bỏ chấm.
  Future<void> rateMessage(String messageId, int rating) async {
    try {
      final response = await _dio.patch(
        ApiConstants.aiMessageRatingUrl(messageId),
        data: {'rating': rating},
        options: await _authOptions(),
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final success = body['success'] as bool? ?? true;
        if (!success) {
          throw AiApiException(
            body['message'] as String? ?? 'Gửi đánh giá thất bại.',
          );
        }
      }
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<void> deleteConversation(String id) async {
    try {
      final response = await _dio.delete(
        ApiConstants.aiConversationDetailUrl(id),
        options: await _authOptions(),
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final success = body['success'] as bool? ?? true;
        if (!success) {
          throw AiApiException(
            body['message'] as String? ?? 'Xóa cuộc trò chuyện thất bại.',
          );
        }
      }
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  AiApiException _fromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return AiApiException(
        data['message'] as String? ?? 'Lỗi kết nối máy chủ.',
        statusCode: e.response?.statusCode,
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AiApiException('Hết thời gian chờ — AI có thể đang xử lý, thử lại.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return AiApiException(
        'Không kết nối được backend (${ApiConstants.baseUrl}). '
        'Kiểm tra mạng và API_BASE_URL trong file .env.',);
    }
    return AiApiException(e.message ?? 'Lỗi mạng không xác định.');
  }
}
