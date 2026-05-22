import '../api/auth_api.dart';

/// Backend base URL — dùng chung với [AuthApi] (`API_BASE_URL` dart-define).
class ApiConfig {
  static String get baseUrl => AuthApi.baseUrl;

  static const String apiPrefix = '/api/v1';

  static const String feedbackPath = '/api/feedback';
  static const String feedbackUploadPath = '/api/feedback/upload';

  static const String aiPath = '$apiPrefix/ai';

  static String get feedbackUrl => '$baseUrl$feedbackPath';
  static String get feedbackUploadUrl => '$baseUrl$feedbackUploadPath';

  static String get aiChatUrl => '$baseUrl$aiPath/chat';
  static String get aiConversationsUrl => '$baseUrl$aiPath/conversations';
  static String aiConversationDetailUrl(String id) =>
      '$baseUrl$aiPath/conversations/$id';

  /// Khi chưa cấu hình BE, lưu feedback cục bộ.
  static bool get useLocalFallback => baseUrl.contains('example.com');
}
