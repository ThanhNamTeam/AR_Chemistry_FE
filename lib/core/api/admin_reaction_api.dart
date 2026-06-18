import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../../domain/models/reaction_definition_model.dart';
import '../models/request/create_reaction_definition_request.dart';
import '../models/response/page_response.dart';
import '../services/auth_token_service.dart';

class AdminReactionApi {
  Future<PageResponse<ReactionDefinitionModel>> getReactionsForAdmin({
    int page = 0,
    int size = 20,
    bool? active,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load reactions');
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.adminReactionsUrl(
          page: page,
          size: size,
          active: active,
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

      return PageResponse<ReactionDefinitionModel>.fromJson(
        Map<String, dynamic>.from(data),
        ReactionDefinitionModel.fromJson,
      );
    }

    throw Exception(
      'Load reactions failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<ReactionDefinitionModel> createReaction(
      CreateReactionDefinitionRequest request,
      ) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot create reaction');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.createAdminReactionUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    ).timeout(ApiConstants.timeout);

    final body = _decodeResponseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;

      return ReactionDefinitionModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    final message = body['message']?.toString();

    throw Exception(
      message != null && message.isNotEmpty
          ? message
          : 'Create reaction failed (${response.statusCode})',
    );
  }

  Future<ReactionDefinitionModel> updateReactionActive({
    required String id,
    required bool active,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot update reaction status');
    }

    final uri = Uri.parse(ApiConstants.adminReactionActiveUrl(id)).replace(
      queryParameters: {
        'active': active.toString(),
      },
    );

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    final body = _decodeResponseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;

      return ReactionDefinitionModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    final message = body['message']?.toString();

    throw Exception(
      message != null && message.isNotEmpty
          ? message
          : 'Update reaction status failed (${response.statusCode})',
    );
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