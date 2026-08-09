import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class AuthApi {
  /// `GET /api/v1/users/me` — đồng bộ user Cognito sang BE.
  Future<void> syncUser(String idToken) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/users/me');

    final response = await http
        .get(
      uri,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    )
        .timeout(ApiConstants.timeout);

    debugPrint('SYNC USER STATUS: ${response.statusCode}');
    debugPrint('SYNC USER BODY: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Sync user failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  @Deprecated('Use syncUser')
  Future<void> syncGoogleUser(String idToken) => syncUser(idToken);
}