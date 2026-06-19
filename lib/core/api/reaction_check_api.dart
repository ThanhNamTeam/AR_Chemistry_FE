import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../models/response/reaction_check_response.dart';
import '../services/auth_token_service.dart';

enum ReactionCheckFailureType {
  timeout,
  networkError,
  authRequired,
  malformedResponse,
  serverError,
  cancelled,
}

class ReactionCheckFailure implements Exception {
  const ReactionCheckFailure(this.type, this.message);

  final ReactionCheckFailureType type;
  final String message;

  String get code => switch (type) {
    ReactionCheckFailureType.timeout => 'TIMEOUT',
    ReactionCheckFailureType.networkError => 'NETWORK_ERROR',
    ReactionCheckFailureType.authRequired => 'AUTH_REQUIRED',
    ReactionCheckFailureType.malformedResponse => 'MALFORMED_RESPONSE',
    ReactionCheckFailureType.serverError => 'SERVER_ERROR',
    ReactionCheckFailureType.cancelled => 'CANCELLED',
  };
}

class ReactionCheckApi {
  ReactionCheckApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: ApiConstants.timeout,
              receiveTimeout: ApiConstants.timeout,
              sendTimeout: ApiConstants.timeout,
            ),
          );

  final Dio _dio;

  Future<ReactionCheckResponse> check({
    required List<String> qrPayloads,
    required CancelToken cancelToken,
  }) async {
    final normalized =
        qrPayloads
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    if (normalized.isEmpty) {
      throw const ReactionCheckFailure(
        ReactionCheckFailureType.malformedResponse,
        'Không có mã QR hợp lệ để kiểm tra.',
      );
    }

    var token = await AuthTokenService.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw const ReactionCheckFailure(
        ReactionCheckFailureType.authRequired,
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }

    try {
      return await _send(normalized, token, cancelToken);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 && !cancelToken.isCancelled) {
        token = await AuthTokenService.getValidAccessToken(forceRefresh: true);
        if (token == null || token.isEmpty) {
          throw const ReactionCheckFailure(
            ReactionCheckFailureType.authRequired,
            'Không thể làm mới phiên đăng nhập.',
          );
        }
        try {
          return await _send(normalized, token, cancelToken);
        } on DioException catch (retryError) {
          throw _mapDio(retryError);
        }
      }
      throw _mapDio(error);
    }
  }

  Future<ReactionCheckResponse> _send(
    List<String> qrPayloads,
    String token,
    CancelToken cancelToken,
  ) async {
    final response = await _dio.post<dynamic>(
      '/reactions/check',
      data: <String, Object?>{'qrPayloads': qrPayloads},
      options: Options(
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
      cancelToken: cancelToken,
    );

    final envelope = response.data;
    if (envelope is! Map || envelope['success'] != true) {
      throw const ReactionCheckFailure(
        ReactionCheckFailureType.malformedResponse,
        'Backend trả về phản hồi không hợp lệ.',
      );
    }
    final data = envelope['data'];
    if (data is! Map) {
      throw const ReactionCheckFailure(
        ReactionCheckFailureType.malformedResponse,
        'Backend không trả về dữ liệu kiểm tra phản ứng.',
      );
    }

    try {
      return ReactionCheckResponse.fromJson(Map<String, dynamic>.from(data));
    } on FormatException {
      throw const ReactionCheckFailure(
        ReactionCheckFailureType.malformedResponse,
        'Không đọc được dữ liệu kiểm tra phản ứng.',
      );
    }
  }

  ReactionCheckFailure _mapDio(DioException error) {
    if (CancelToken.isCancel(error)) {
      return const ReactionCheckFailure(
        ReactionCheckFailureType.cancelled,
        'Yêu cầu đã được thay thế bởi lần quét mới.',
      );
    }
    if (error.response?.statusCode == 401 ||
        error.response?.statusCode == 403) {
      return const ReactionCheckFailure(
        ReactionCheckFailureType.authRequired,
        'Bạn cần đăng nhập lại để tiếp tục quét.',
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const ReactionCheckFailure(
        ReactionCheckFailureType.timeout,
        'Kiểm tra phản ứng quá thời gian. Hãy thử lại.',
      );
    }
    if (error.type == DioExceptionType.connectionError) {
      return const ReactionCheckFailure(
        ReactionCheckFailureType.networkError,
        'Không kết nối được backend. Kiểm tra mạng rồi thử lại.',
      );
    }
    return ReactionCheckFailure(
      ReactionCheckFailureType.serverError,
      'Backend không thể kiểm tra phản ứng (${error.response?.statusCode ?? 'unknown'}).',
    );
  }
}
