import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../../domain/models/knowledge_point_wallet.dart';
import '../services/auth_token_service.dart';

class KnowledgePointApi {
  Future<KnowledgePointWallet> getMyKnowledgePoints() async {
    final token = await AuthTokenService.getValidAccessToken();

    final response = await http.get(
      Uri.parse(ApiConstants.knowledgePointsMeUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Failed to load knowledge points');
    }

    final data = body['data'] as Map<String, dynamic>;

    return KnowledgePointWallet.fromJson(data);
  }
}