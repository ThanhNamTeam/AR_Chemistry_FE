import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/response/library_card_response.dart';
import '../models/response/library_summary_response.dart';
import '../models/response/page_response.dart';
import '../services/auth_token_service.dart';

class LibraryApi {
  Future<PageResponse<LibraryCardResponse>> getLibraryCards({
    int page = 0,
    int size = 30,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load library cards');
    }

    final response = await http
        .get(
      Uri.parse(
        ApiConstants.libraryCardsUrl(
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

    final json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PageResponse<LibraryCardResponse>.fromJson(
        json['data'],
        LibraryCardResponse.fromJson,
      );
    }

    throw Exception(
      json['message']?.toString() ?? 'Load library cards failed',
    );
  }

  Future<LibrarySummaryResponse> getLibrarySummary() async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load library summary');
    }

    final response = await http
        .get(
      Uri.parse(ApiConstants.librarySummaryUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return LibrarySummaryResponse.fromJson(json['data']);
    }

    throw Exception(
      json['message']?.toString() ?? 'Load library summary failed',
    );
  }
}