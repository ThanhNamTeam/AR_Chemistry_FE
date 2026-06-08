import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/response/reaction_summary_response.dart';
import '../services/auth_token_service.dart';

class ReactionApi {
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