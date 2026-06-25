import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../models/response/ar_asset_response.dart';
import '../services/auth_token_service.dart';

class ArAssetApi {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
    ),
  );

  Future<ArAssetResponse> getLatestArAssets() async {
    final token = await AuthTokenService.getValidAccessToken();

    final response = await _dio.get(
      ApiConstants.latestArAssetsUrl,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final data = response.data['data'];
    return ArAssetResponse.fromJson(data);
  }
}