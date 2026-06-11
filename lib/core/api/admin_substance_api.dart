import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/response/page_response.dart';
import '../../domain/models/chemical_substance_model.dart';
import '../services/auth_token_service.dart';

class AdminSubstanceApi {
  Future<PageResponse<ChemicalSubstanceModel>> getSubstances({
    int page = 0,
    int size = 20,
    String sort = 'formula,asc',
    bool? active,
    String? chemicalGroup,
    String? type,
    bool? includedInFullKit,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load substances');
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.adminSubstancesUrl(
          page: page,
          size: size,
          sort: sort,
          active: active,
          chemicalGroup: chemicalGroup,
          type: type,
          includedInFullKit: includedInFullKit,
        ),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return PageResponse<ChemicalSubstanceModel>.fromJson(
        data,
            (item) => ChemicalSubstanceModel.fromJson(item),
      );
    }

    throw Exception(
      'Load substances failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<ChemicalSubstanceModel> updateSubstanceActive({
    required String id,
    required bool active,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot update substance');
    }

    final response = await http.patch(
      Uri.parse(ApiConstants.adminSubstanceActiveUrl(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'active': active,
      }),
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return ChemicalSubstanceModel.fromJson(data);
    }

    throw Exception(
      'Update substance active failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<ChemicalSubstanceModel> updateSubstanceIncludedInFullKit({
    required String id,
    required bool includedInFullKit,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot update full kit flag');
    }

    final response = await http.patch(
      Uri.parse(ApiConstants.adminSubstanceIncludedInFullKitUrl(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'includedInFullKit': includedInFullKit,
      }),
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return ChemicalSubstanceModel.fromJson(data);
    }

    throw Exception(
      'Update substance full kit flag failed: ${response.statusCode} - ${response.body}',
    );
  }
}