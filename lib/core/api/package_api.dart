import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/response/package_response.dart';
import '../services/auth_token_service.dart';

class PackageApi {
  Future<List<PackageResponse>> getPackages() async {
    final url = '${ApiConstants.baseUrl}/packages';

    debugPrint('Get packages URL: $url');

    final accessToken = await AuthTokenService.getValidAccessToken();

    final response = await http.get(
      Uri.parse(url),
      headers: {
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      },
    );

    debugPrint('Get packages status: ${response.statusCode}');
    debugPrint('Get packages response: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final list = json['data'] as List;

      return list.map((item) => PackageResponse.fromJson(item)).toList();
    }

    throw Exception(
      'Get packages failed: ${response.statusCode} - ${response.body}',
    );
  }
}