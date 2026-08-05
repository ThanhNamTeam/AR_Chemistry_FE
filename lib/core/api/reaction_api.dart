import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/response/reaction_summary_response.dart';
import '../services/auth_token_service.dart';
import '../services/flashcard_review_service.dart';

class ReactionApi {
  /// Tải danh sách phản ứng đang bật (kèm phương trình) cho chế độ Ôn thẻ.
  Future<List<CachedReaction>> getActiveReactions({int size = 100}) async {
    final token = await AuthTokenService.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load reactions');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.reactionsListUrl(size: size)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final items = (json['data']?['items'] as List<dynamic>? ?? []);
      return items
          .whereType<Map<String, dynamic>>()
          .map((item) => CachedReaction(
                code: item['code']?.toString() ?? '',
                name: item['name']?.toString() ?? '',
                equation: item['equation']?.toString() ?? '',
                reactionType: item['reactionType']?.toString(),
              ))
          .where((r) => r.equation.isNotEmpty)
          .toList();
    }

    throw Exception(
      json['message']?.toString() ?? 'Load reactions failed',
    );
  }
  Future<ReactionSummaryResponse> getReactionSummary() async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load reaction summary');
    }

    final response = await http
        .get(
      Uri.parse(ApiConstants.reactionSummaryUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ReactionSummaryResponse.fromJson(json['data']);
    }

    throw Exception(
      json['message']?.toString() ?? 'Load reaction summary failed',
    );
  }
}