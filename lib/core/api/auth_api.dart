import 'package:http/http.dart' as http;

class AuthApi {

  static const String baseUrl =
      'http://10.233.197.225:8080/api/v1';

  Future<void> syncGoogleUser(
      String idToken,
      ) async {

    await http.get(
      Uri.parse(
        '$baseUrl/users/me',
      ),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );
  }
}