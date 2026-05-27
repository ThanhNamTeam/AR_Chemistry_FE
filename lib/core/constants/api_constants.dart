class ApiConstants {
  /// Backend base URL — truyền bằng dart-define:
  /// --dart-define=API_BASE_URL=http://192.168.1.13:8080/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.131.100.225:8080/api/v1',
  );

  static const Duration timeout = Duration(seconds: 30);

  //url
  static const String feedbackPath = '/feedbacks';
  static const String aiPath = '/ai';
  static const String chemicalCardsShopPath = '/chemical-cards';

  //feedbacks
  static String get feedbackUrl => '$baseUrl$feedbackPath';

  //AI
  static String get aiChatUrl => '$baseUrl$aiPath/chat';
  static String get aiConversationsUrl => '$baseUrl$aiPath/conversations';

  //cards
  static String get chemicalCardsShopUrl => '$baseUrl$chemicalCardsShopPath';

  //bundle
  static const String cardBundlesShopPath = '/card-bundles';

  static String aiConversationDetailUrl(String id) {
    return '$baseUrl$aiPath/conversations/$id';
  }



  /// Khi chưa cấu hình BE, lưu feedback cục bộ.
  static bool get useLocalFallback => baseUrl.contains('example.com');
}