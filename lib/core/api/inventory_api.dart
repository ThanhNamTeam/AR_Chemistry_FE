import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/response/activate_kit_response.dart';
import '../models/response/page_response.dart';
import '../models/response/substance_detail_response.dart';
import '../models/response/user_inventory_response.dart';
import '../services/auth_token_service.dart';

class InventoryApi {
  Future<PageResponse<UserInventoryResponse>> getMyInventory({
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load inventory');
    }

    final response = await http
        .get(
      Uri.parse(
        ApiConstants.inventoryMeUrl(
          page: page,
          size: size,
        ),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    )
        .timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return PageResponse<UserInventoryResponse>.fromJson(
        json['data'],
        UserInventoryResponse.fromJson,
      );
    }

    throw Exception(
      'Load my inventory failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<SubstanceDetailResponse> getSubstanceDetail(String substanceId) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load substance detail');
    }

    final response = await http
        .get(
      Uri.parse(ApiConstants.inventorySubstanceDetailUrl(substanceId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    )
        .timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return SubstanceDetailResponse.fromJson(json['data']);
    }

    throw Exception(
      'Load substance detail failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<ActivateKitResponse> activateKit(String activationCode) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot activate kit');
    }

    final response = await http
        .post(
      Uri.parse(ApiConstants.activateKitUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'activationCode': activationCode,
      }),
    )
        .timeout(ApiConstants.timeout);

    Map<String, dynamic>? json;

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      }
    } catch (_) {
      json = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ActivateKitResponse.fromJson(
        Map<String, dynamic>.from(json?['data']),
      );
    }

    final message = json?['message']?.toString();

    throw Exception(
      message == null || message.isEmpty
          ? 'Activate kit failed'
          : message,
    );
  }
}