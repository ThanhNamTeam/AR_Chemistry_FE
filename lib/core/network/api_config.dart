import '../api/auth_api.dart';
import '../constants/api_constants.dart';

/// Backend base URL — dùng chung với [AuthApi] (`API_BASE_URL` dart-define).
class ApiConfig {
  static String get baseUrl => ApiConstants.baseUrl;


  static const String feedbackPath = '/api/feedback';
  static const String feedbackUploadPath = '/api/feedback/upload';

  static const String aiPath = '/ai';

  static String get feedbackUrl => '$baseUrl$feedbackPath';
  static String get feedbackUploadUrl => '$baseUrl$feedbackUploadPath';

  static String get aiChatUrl => '$baseUrl$aiPath/chat';
  static String get aiConversationsUrl => '$baseUrl$aiPath/conversations';
  static String aiConversationDetailUrl(String id) =>
      '$baseUrl$aiPath/conversations/$id';

  /// Khi chưa cấu hình BE, lưu feedback cục bộ.
  static bool get useLocalFallback => baseUrl.contains('example.com');
}
