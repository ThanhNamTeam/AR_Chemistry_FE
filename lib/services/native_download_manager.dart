import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class NativeDownloadInfo {
  final bool exists;
  final String status;
  final int bytesDownloaded;
  final int totalBytes;
  final String? localUri;
  final int? reason;

  const NativeDownloadInfo({
    required this.exists,
    required this.status,
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.localUri,
    required this.reason,
  });

  bool get isRunning => status == 'running' || status == 'pending' || status == 'paused';
  bool get isDone => status == 'successful';
  bool get isFailed => status == 'failed';
  bool get hasRealTotal => totalBytes > 0;

  double get progress {
    if (totalBytes <= 0) return 0;
    return bytesDownloaded / totalBytes;
  }

  factory NativeDownloadInfo.fromMap(Map<dynamic, dynamic> map) {
    return NativeDownloadInfo(
      exists: map['exists'] == true,
      status: map['status']?.toString() ?? 'unknown',
      bytesDownloaded: (map['bytesDownloaded'] as num?)?.toInt() ?? 0,
      totalBytes: (map['totalBytes'] as num?)?.toInt() ?? -1,
      localUri: map['localUri']?.toString(),
      reason: (map['reason'] as num?)?.toInt(),
    );
  }
}

class NativeDownloadStartResult {
  final int downloadId;
  final String filePath;

  const NativeDownloadStartResult({
    required this.downloadId,
    required this.filePath,
  });
}

class NativeDownloadManager {
  static const MethodChannel _channel =
  MethodChannel('ar_chemistry_visual/download_manager');

  static Future<NativeDownloadStartResult> startDownload({
    required String url,
    required String fileName,
  }) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'startDownload',
      {
        'url': url,
        'fileName': fileName,
      },
    );

    if (result == null) {
      throw Exception('Không start được DownloadManager');
    }

    return NativeDownloadStartResult(
      downloadId: (result['downloadId'] as num).toInt(),
      filePath: result['filePath'].toString(),
    );
  }

  static Future<NativeDownloadInfo> queryDownload(int downloadId) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'queryDownload',
      {
        'downloadId': downloadId,
      },
    );

    if (result == null) {
      return const NativeDownloadInfo(
        exists: false,
        status: 'not_found',
        bytesDownloaded: 0,
        totalBytes: -1,
        localUri: null,
        reason: null,
      );
    }

    return NativeDownloadInfo.fromMap(result);
  }

  static Future<void> removeDownload(int downloadId) async {
    await _channel.invokeMethod('removeDownload', {
      'downloadId': downloadId,
    });
  }
}

String formatBytes(int bytes) {
  if (bytes < 0) return '-- MB';
  final mb = bytes / 1024 / 1024;
  return '${mb.toStringAsFixed(0)} MB';
}

File fileFromAndroidLocalUriOrPath({
  required String savedPath,
  String? localUri,
}) {
  if (localUri != null && localUri.startsWith('file://')) {
    return File(Uri.parse(localUri).toFilePath());
  }

  return File(savedPath);
}