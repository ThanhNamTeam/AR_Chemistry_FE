import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/response/page_response.dart';
import '../services/auth_token_service.dart';
import '../../domain/models/admin_chemical_card_model.dart';
class AdminChemicalCardApi {
  Future<PageResponse<AdminChemicalCardModel>> getCardsForAdmin({
    int page = 0,
    int size = 20,
    bool? active,
    String? substanceId,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load chemical cards');
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.adminChemicalCardsUrl(
          page: page,
          size: size,
          active: active,
          substanceId: substanceId,
        ),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final data = body['data'] ?? body;

      return PageResponse<AdminChemicalCardModel>.fromJson(
        Map<String, dynamic>.from(data),
        AdminChemicalCardModel.fromJson,
      );
    }

    throw Exception(
      'Load chemical cards failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<Map<String, dynamic>> generateCardImageUploadUrl({
    required String id,
    required String frontContentType,
    required int frontFileSize,
    required String backContentType,
    required int backFileSize,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot generate upload url');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.adminChemicalCardImageUploadUrl(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'frontContentType': frontContentType,
        'frontFileSize': frontFileSize,
        'backContentType': backContentType,
        'backFileSize': backFileSize,
      }),
    ).timeout(ApiConstants.timeout);

    final body = _decodeResponseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;
      return Map<String, dynamic>.from(data);
    }

    final message = body['message']?.toString();

    throw Exception(
      message != null && message.isNotEmpty
          ? message
          : 'Generate upload url failed (${response.statusCode})',
    );
  }

  Future<void> uploadFileToS3({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {
        'Content-Type': contentType,
      },
      body: bytes,
    ).timeout(const Duration(minutes: 2));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Upload image to S3 failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Map<String, dynamic> _decodeResponseBody(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {};
    } catch (_) {
      return {};
    }
  }
}