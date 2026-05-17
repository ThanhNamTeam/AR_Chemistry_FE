import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/models/feedback_model.dart';
import '../storage/feedback_storage_service.dart';
import 'api_config.dart';

class FeedbackApiService {
  final Dio _dio;
  final FeedbackStorageService _local = FeedbackStorageService();

  FeedbackApiService({Dio? dio}) : _dio = dio ?? Dio();

  /// Upload ảnh minh họa (tùy chọn). Trả về URL dùng trong [imageUrl].
  Future<String?> uploadFeedbackImage(String filePath) async {
    if (ApiConfig.useLocalFallback) {
      final dir = await getApplicationDocumentsDirectory();
      final feedbackDir = Directory('${dir.path}/feedback_images');
      if (!await feedbackDir.exists()) {
        await feedbackDir.create(recursive: true);
      }
      final ext = filePath.contains('.')
          ? '.${filePath.split('.').last}'
          : '.jpg';
      final name = 'fb_${DateTime.now().millisecondsSinceEpoch}$ext';
      final dest = '${feedbackDir.path}/$name';
      await File(filePath).copy(dest);
      return dest;
    }

    final file = File(filePath);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(RegExp(r'[/\\]')).last,
      ),
    });

    final response = await _dio.post(
      ApiConfig.feedbackUploadUrl,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data;
    if (data is Map && data['url'] != null) return data['url'] as String;
    if (data is Map && data['fileUrl'] != null) return data['fileUrl'] as String;
    if (data is String) return data;
    return null;
  }

  Future<void> submitFeedback(
    FeedbackPayload payload, {
    String? reporterEmail,
    String? reporterName,
  }) async {
    final body = payload.toJson();
    if (!payload.anonymous) {
      if (reporterEmail != null) body['reporterEmail'] = reporterEmail;
      if (reporterName != null) body['reporterName'] = reporterName;
    }

    if (ApiConfig.useLocalFallback) {
      await _local.appendSubmission(body);
      await Future.delayed(const Duration(milliseconds: 400));
      return;
    }

    await _dio.post(ApiConfig.feedbackUrl, data: body);
  }
}
