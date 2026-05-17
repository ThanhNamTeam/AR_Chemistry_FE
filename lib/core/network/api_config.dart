/// Backend base URL — cập nhật khi có API thật.
class ApiConfig {
  static const String baseUrl = 'https://your-api.example.com';
  static const String feedbackPath = '/api/feedback';
  static const String feedbackUploadPath = '/api/feedback/upload';

  static String get feedbackUrl => '$baseUrl$feedbackPath';
  static String get feedbackUploadUrl => '$baseUrl$feedbackUploadPath';

  /// Khi chưa cấu hình BE, lưu feedback cục bộ.
  static bool get useLocalFallback => baseUrl.contains('example.com');
}
