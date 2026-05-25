import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/models/request/generate_upload_url_request.dart';
import '../api/upload_api.dart';
import '../constants/api_constants.dart';
import '../models/request/feedback_request.dart';
import '../services/auth_token_service.dart';
import '../storage/feedback_storage_service.dart';

class FeedbackApiService {
  static const int _maxFeedbackFileSize = 10 * 1024 * 1024;

  static const Set<String> _allowedFeedbackContentTypes = {
    'image/png',
    'image/jpeg',
    'application/pdf',
  };

  final Dio _dio;
  final UploadApi _uploadApi;
  final FeedbackStorageService _local = FeedbackStorageService();

  FeedbackApiService({
    Dio? dio,
    UploadApi? uploadApi,
  })  : _dio = dio ?? Dio(),
        _uploadApi = uploadApi ?? UploadApi();

  Future<Options> _authOptions({
    String? contentType,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    return Options(
      contentType: contentType,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Upload file minh họa feedback lên S3.
  /// Hỗ trợ: PNG, JPEG, PDF. Giới hạn: 10MB.
  Future<String?> uploadFeedbackImage(String filePath) async {
    final file = File(filePath);


    if (!await file.exists()) {
      throw Exception('File không tồn tại');
    }

    final fileSize = await file.length();

    if (fileSize > _maxFeedbackFileSize) {
      throw Exception('File vượt quá giới hạn 10MB');
    }

    final contentType = lookupMimeType(file.path);

    if (contentType == null ||
        !_allowedFeedbackContentTypes.contains(contentType)) {
      throw Exception(
        'File không hợp lệ. Chỉ hỗ trợ PNG, JPEG hoặc PDF.',
      );
    }

    if (ApiConstants.useLocalFallback) {
      final dir = await getApplicationDocumentsDirectory();
      final feedbackDir = Directory('${dir.path}/feedback_files');

      if (!await feedbackDir.exists()) {
        await feedbackDir.create(recursive: true);
      }

      final ext = p.extension(filePath).isNotEmpty
          ? p.extension(filePath)
          : _extensionFromContentType(contentType);

      final name = 'fb_${DateTime.now().millisecondsSinceEpoch}$ext';
      final dest = p.join(feedbackDir.path, name);

      await file.copy(dest);
      return dest;
    }

    final fileName = p.basename(file.path);
    final bytes = await file.readAsBytes();



    final presigned = await _uploadApi.generateUploadUrl(
      GenerateUploadUrlRequest(
        purposeCode: 'FEEDBACK',
        fileName: fileName,
        contentType: contentType,
        fileSize: fileSize,
      ),
    );

    await _uploadApi.uploadFileToS3(
      uploadUrl: presigned.uploadUrl,
      bytes: bytes,
      contentType: contentType,
    );

    return presigned.fileUrl;
  }

  Future<void> submitFeedback(
      FeedbackRequest request,
      ) async {
    final body = request.toJson();

    if (ApiConstants.useLocalFallback) {
      await _local.appendSubmission(body);
      await Future.delayed(const Duration(milliseconds: 400));
      return;
    }

    await _dio.post(
      ApiConstants.feedbackUrl,
      data: body,
      options: await _authOptions(),
    );
  }

  String _extensionFromContentType(String contentType) {
    switch (contentType) {
      case 'image/png':
        return '.png';
      case 'image/jpeg':
        return '.jpg';
      case 'application/pdf':
        return '.pdf';
      default:
        return '';
    }
  }
}