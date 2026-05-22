import 'package:http/http.dart' as http;

class AuthApi {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.131.100.225:8080',
  );

  static const Duration _timeout = Duration(seconds: 8);

  /// `GET /api/v1/users/me` — đồng bộ user Cognito sang BE (không chặn UI).
  Future<void> syncUser(String idToken) async {
    final uri = Uri.parse('$baseUrl/api/v1/users/me');
    final response = await http
        .get(
          uri,
          headers: {'Authorization': 'Bearer $idToken'},
        )
        .timeout(_timeout);

    if (response.statusCode >= 400) {
      throw Exception('Sync user failed: ${response.statusCode}');
    }
  }

  @Deprecated('Use syncUser')
  Future<void> syncGoogleUser(String idToken) => syncUser(idToken);
}
