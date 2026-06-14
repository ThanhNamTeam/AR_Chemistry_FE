import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/request/generate_activation_codes_request.dart';
import '../../domain/models/activation_code_model.dart';
import '../models/request/update_activation_code_status_request.dart';
import '../services/auth_token_service.dart';

class AdminActivationCodeApi {
  Future<List<ActivationCodeModel>> generateCodes(
      GenerateActivationCodesRequest request,
      ) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot generate activation codes');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.generateActivationCodesUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final data = json['data'];

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ActivationCodeModel.fromJson)
            .toList();
      }

      return [];
    }

    throw Exception(
      'Generate activation codes failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<List<ActivationCodeModel>> getActivationCodes({
    int page = 0,
    int size = 20,
    String? status,
    String? kitId,
    String? usedByUserId,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load activation codes');
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.activationCodesUrl(
          page: page,
          size: size,
          status: status,
          kitId: kitId,
          usedByUserId: usedByUserId,
        ),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final data = json['data'];

      List<dynamic> rawItems = [];

      if (data is Map<String, dynamic>) {
        if (data['items'] is List) {
          rawItems = data['items'];
        } else if (data['content'] is List) {
          rawItems = data['content'];
        }
      } else if (data is List) {
        rawItems = data;
      }

      return rawItems
          .whereType<Map<String, dynamic>>()
          .map(ActivationCodeModel.fromJson)
          .toList();
    }

    throw Exception(
      'Load activation codes failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<ActivationCodeModel> getByCode(String code) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot search activation code');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.activationCodeByCodeUrl(code)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return ActivationCodeModel.fromJson(json['data']);
    }

    throw Exception(
      'Search activation code failed: ${response.statusCode} - ${response.body}',
    );
  }



  Future<ActivationCodeModel> updateStatus(
      String id,
      UpdateActivationCodeStatusRequest request,
      ) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot update activation code status');
    }

    final response = await http.patch(
      Uri.parse(ApiConstants.activationCodeStatusUrl(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return ActivationCodeModel.fromJson(json['data']);
    }

    throw Exception(
      'Update activation code status failed: ${response.statusCode} - ${response.body}',
    );
  }
}