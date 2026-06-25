import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/models/request/generate_upload_url_request.dart';
import '../../domain/models/admin_feedback_list_model.dart';
import '../api/upload_api.dart';
import '../constants/api_constants.dart';
import '../models/request/feedback_request.dart';
import '../models/response/page_response.dart';
import '../services/auth_token_service.dart';
import '../storage/feedback_storage_service.dart';
import '../../domain/models/admin_feedback_model.dart';

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
  })  : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.timeout,
          receiveTimeout: ApiConstants.timeout,
          sendTimeout: ApiConstants.timeout,
        ),
      ),
        _uploadApi = uploadApi ?? UploadApi();

  Future<Options> _authOptions({
    String? contentType,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in');
    }

    return Options(
      contentType: contentType,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

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
      throw Exception('File không hợp lệ. Chỉ hỗ trợ PNG, JPEG hoặc PDF.');
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

  Future<void> submitFeedback(FeedbackRequest request) async {
    final body = request.toJson();

    if (ApiConstants.useLocalFallback) {
      await _local.appendSubmission(body);
      await Future.delayed(const Duration(milliseconds: 400));
      return;
    }

    await _dio.post(
      ApiConstants.feedbackPath,
      data: body,
      options: await _authOptions(),
    );
  }

  Future<PageResponse<AdminFeedbackListModel>> getFeedbacksForStaff({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get(
      ApiConstants.feedbackPath,
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
          AdminFeedbackListModel.fromJson,
        );
      }
    }

    throw Exception('Invalid feedbacks response');
  }

  Future<AdminFeedbackModel> getFeedbackDetail(String feedbackId) async {
    final response = await _dio.get(
      '${ApiConstants.feedbackPath}/details',
      queryParameters: {
        'feedbackId': feedbackId,
      },
      options: await _authOptions(),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final raw = data['data'];

      if (raw is Map) {
        return AdminFeedbackModel.fromJson(
          Map<String, dynamic>.from(raw),
        );
      }
    }

    throw Exception('Invalid feedback detail response');
  }

  Future<AdminFeedbackModel> handleFeedback({
    required String feedbackId,
    required String status,
    required String priority,
    required String staffReply,
  }) async {
    final response = await _dio.put(
      '${ApiConstants.feedbackPath}/handle',
      queryParameters: {
        'feedbackId': feedbackId,
      },
      data: {
        'status': status,
        'priority': priority,
        'staffReply': staffReply,
      },
      options: await _authOptions(),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final raw = data['data'];

      if (raw is Map) {
        return AdminFeedbackModel.fromJson(
          Map<String, dynamic>.from(raw),
        );
      }
    }

    throw Exception('Invalid handle feedback response');
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

  Future<PageResponse<AdminFeedbackListModel>> getMyFeedbacks({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.feedbackPath}/my-feedbacks',
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
          AdminFeedbackListModel.fromJson,
        );
      }
    }

    throw Exception('Invalid my feedbacks response');
  }

  Future<AdminFeedbackModel> getMyFeedbackDetail(String feedbackId) async {
    final response = await _dio.get(
      '${ApiConstants.feedbackPath}/my-feedbacks/$feedbackId',
      options: await _authOptions(),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final raw = data['data'];
      if (raw is Map) {
        return AdminFeedbackModel.fromJson(
          Map<String, dynamic>.from(raw),
        );
      }
    }

    throw Exception('Invalid my feedback detail response');
  }
}