import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/response/my_single_card_purchase_response.dart';
import '../models/response/page_response.dart';
import '../models/response/single_card_purchase_response.dart';
import '../models/response/single_card_shop_response.dart';
import '../services/auth_token_service.dart';

class SingleCardApi {
  Future<PageResponse<SingleCardShopResponse>> getSingleCards({
    int page = 0,
    int size = 20,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load single cards');
    }

    final uri = Uri.parse(ApiConstants.singleCardsUrl).replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return PageResponse<SingleCardShopResponse>.fromJson(
        data,
            (item) => SingleCardShopResponse.fromJson(item),
      );
    }

    throw Exception(
      'Load single cards failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<SingleCardPurchaseResponse> fakeBuySingleCard(String singleCardId) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot buy single card');
    }

    final uri = Uri.parse(ApiConstants.fakeBuySingleCardUrl);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'singleCardId': singleCardId,
      }),
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return SingleCardPurchaseResponse.fromJson(data);
    }

    throw Exception(
      'Buy single card failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<PageResponse<MySingleCardPurchaseResponse>> getMySingleCardPurchases({
    int page = 0,
    int size = 20,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load my single cards');
    }

    final uri = Uri.parse(ApiConstants.mySingleCardPurchasesUrl).replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return PageResponse<MySingleCardPurchaseResponse>.fromJson(
        data,
            (item) => MySingleCardPurchaseResponse.fromJson(item),
      );
    }

    throw Exception(
      'Load my single cards failed: ${response.statusCode} - ${response.body}',
    );
  }
}