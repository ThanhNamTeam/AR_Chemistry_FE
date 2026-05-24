class ApiConstants {

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.13:8080/api/v1',
  );

  static const Duration timeout = Duration(
    seconds: 8,
  );

}