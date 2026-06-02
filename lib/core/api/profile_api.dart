import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/auth_token_service.dart';

class ProfileApi {

  Future<Map<String, dynamic>> getProfile() async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['data'] as Map<String, dynamic>;
    }

    throw Exception(
      'Get profile failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in');
    }

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Update profile failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> updateAvatar({
    required String avatarUrl,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in');
    }

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/users/avatar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'avatarUrl': avatarUrl,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Update avatar failed: ${response.statusCode} - ${response.body}',
      );
    }
  }
}