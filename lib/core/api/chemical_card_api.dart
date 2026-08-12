import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../models/response/chemical_card_response.dart';
import '../models/response/card_bundle_response.dart';
import '../models/response/page_response.dart';
import '../services/auth_token_service.dart';

class ChemicalCardApi {
  final Dio _dio;

  ChemicalCardApi({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.timeout,
          receiveTimeout: ApiConstants.timeout,
          sendTimeout: ApiConstants.timeout,
        ),
      );

  Future<Options> _authOptions() async {
    final token = await AuthTokenService.getValidAccessToken();

    return Options(
      headers: {
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );
  }

  Future<PageResponse<ChemicalCardResponse>> getShopCards({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.chemicalCardsShopPath,
      queryParameters: {
        'page': page,
        'size': size,
        'active': true,
      },
      options: await _authOptions(),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final rawPage = data['data'];

      if (rawPage is Map) {
        return PageResponse.fromJson(
          Map<String, dynamic>.from(rawPage),
          ChemicalCardResponse.fromJson,
        );
      }
    }

    throw Exception('Invalid shop cards response');
  }

  Future<PageResponse<CardBundleResponse>> getShopCardBundles({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.cardBundlesShopPath,
      queryParameters: {
        'page': page,
        'size': size,
      },
      options: await _authOptions(),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final rawPage = data['data'];

      if (rawPage is Map) {
        return PageResponse.fromJson(
          Map<String, dynamic>.from(rawPage),
          CardBundleResponse.fromJson,
        );
      }
    }

    throw Exception('Invalid shop card bundles response');
  }

  Future<void> deleteCardBundle(String id) async {
    await _dio.delete(
      '${ApiConstants.cardBundlesShopPath}/$id',
      options: await _authOptions(),
    );
  }
}