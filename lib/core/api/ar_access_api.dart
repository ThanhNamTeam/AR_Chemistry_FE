import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/response/ar_access_response.dart';
import '../services/auth_token_service.dart';


class ArAccessApi {
  Future<ArAccessResponse> getMyArAccess() async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot check AR access');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.myArAccessUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return ArAccessResponse.fromJson(json['data']);
    }

    throw Exception(
      'Check AR access failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<ArAccessResponse> fakePurchaseAr30Days() async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot fake purchase AR access');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.fakePurchaseAr30DaysUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return ArAccessResponse.fromJson(json['data']);
    }

    throw Exception(
      'Fake purchase AR 30 days failed: ${response.statusCode} - ${response.body}',
    );
  }
}