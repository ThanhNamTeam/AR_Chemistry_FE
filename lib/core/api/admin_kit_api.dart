import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/request/create_kit_request.dart';
import '../../domain/models/kit_model.dart';
import '../services/auth_token_service.dart';

class AdminKitApi {
  Future<List<KitModel>> getKits() async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load kits');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.adminKitsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final data = json['data'];

      if (data is Map<String, dynamic>) {
        final items = data['items'];

        if (items is List) {
          return items
              .whereType<Map<String, dynamic>>()
              .map(KitModel.fromJson)
              .toList();
        }
      }

      return [];
    }

    throw Exception(
      'Load kits failed: ${response.statusCode} - ${response.body}',
    );
  }
  Future<KitModel> createKit(CreateKitRequest request) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot create kit');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.adminKitsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return KitModel.fromJson(json['data']);
    }

    throw Exception(
      'Create kit failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<KitModel> getKitByCode(String code) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load kit detail');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.kitByCodeUrl(code)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return KitModel.fromJson(json['data']);
    }

    throw Exception(
      'Load kit detail failed: ${response.statusCode} - ${response.body}',
    );
  }
}