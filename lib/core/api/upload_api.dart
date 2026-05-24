import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../../core/models/request/generate_upload_url_request.dart';
import '../../core/models/response/presigned_upload_response.dart';
import '../services/auth_token_service.dart';


class UploadApi {
  Future<PresignedUploadResponse> generateUploadUrl(
      GenerateUploadUrlRequest request,
      ) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot generate upload url');
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/files/presigned-url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return PresignedUploadResponse.fromJson(json['data']);
    }

    throw Exception(
      'Generate upload url failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<void> uploadFileToS3({
    required String uploadUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {
        'Content-Type': contentType,
      },
      body: bytes,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upload file to S3 failed: ${response.body}');
    }
  }
}