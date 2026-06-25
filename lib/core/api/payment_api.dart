import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../models/request/create_payment_request.dart';
import '../models/response/ar_access_response.dart';
import '../models/response/page_response.dart';
import '../models/response/payment_response.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../models/request/create_payment_request.dart';
import '../models/response/page_response.dart';
import '../models/response/payment_response.dart';
import '../services/auth_token_service.dart';

class PaymentApi {
  Future<Map<String, String>> _authHeaders({
    bool json = false,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in');
    }

    return {
      if (json) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// USER tạo payment
  Future<String> createPayment(
      CreatePaymentRequest request,
      ) async {
    final url = '${ApiConstants.baseUrl}/payments';
    final body = jsonEncode(request.toJson());

    debugPrint('Create payment URL: $url');
    debugPrint('Create payment body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: await _authHeaders(json: true),
      body: body,
    );

    debugPrint('Create payment status: ${response.statusCode}');
    debugPrint('Create payment response: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }

    throw Exception(
      'Create payment failed: ${response.statusCode} - ${response.body}',
    );
  }

  /// STAFF lấy danh sách payment
  Future<PageResponse<PaymentResponse>> getPaymentsForStaff({
    int page = 0,
    int size = 10,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/payments?page=$page&size=$size'),
      headers: await _authHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return PageResponse<PaymentResponse>.fromJson(
        json['data'],
            (item) => PaymentResponse.fromJson(item),
      );
    }

    throw Exception(
      'Get payments failed: ${response.statusCode} - ${response.body}',
    );
  }

  /// STAFF duyệt payment
  Future<String> approvePayment(
      String paymentId,
      ) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/payments/approve/$paymentId'),
      headers: await _authHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }

    throw Exception(
      'Approve payment failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<ArAccessResponse> verifyGooglePlayPurchase({
    required String productId,
    required String purchaseToken,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.verifyGooglePlayPurchaseUrl),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'productId': productId,
        'purchaseToken': purchaseToken,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return ArAccessResponse.fromJson(json['data'] ?? json);
    }

    throw Exception(
      'Verify Google Play failed: ${response.statusCode} - ${response.body}',
    );
  }
}