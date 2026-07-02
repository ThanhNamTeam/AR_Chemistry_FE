import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/auth_token_service.dart';

class NotificationTokenApi {
  Future<void> registerFcmToken({
    required String fcmToken,
    String deviceName = 'Android Device',
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Access token is null or empty');
    }

    final uri = Uri.parse(ApiConstants.notificationTokensUrl);

    final response = await http
        .post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fcmToken': fcmToken,
        'platform': 'ANDROID',
        'deviceName': deviceName,
      }),
    )
        .timeout(ApiConstants.timeout);

    if (response.statusCode >= 400) {
      throw Exception(
        'Register FCM token failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> logoutCurrentDevice({
    required String fcmToken,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Access token is null or empty');
    }

    final uri = Uri.parse(ApiConstants.notificationTokenLogoutUrl);

    final response = await http
        .post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fcmToken': fcmToken,
      }),
    )
        .timeout(ApiConstants.timeout);

    if (response.statusCode >= 400) {
      throw Exception(
        'Logout FCM token failed: ${response.statusCode} - ${response.body}',
      );
    }
  }
}