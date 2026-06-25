import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/ar_asset_api.dart';

class ArAssetDownloader {
  static const String _markerVersionKey = 'ar_marker_version';
  static const String _reactionVersionKey = 'ar_reaction_version';

  static Future<void> ensureReady({
    void Function(double progress, String message)? onProgress,
  }) async {
    onProgress?.call(0.0, 'Đang kiểm tra dữ liệu AR...');

    final latest = await ArAssetApi().getLatestArAssets();
    final prefs = await SharedPreferences.getInstance();

    final savedMarkerVersion = prefs.getInt(_markerVersionKey) ?? 0;
    final savedReactionVersion = prefs.getInt(_reactionVersionKey) ?? 0;

    final needMarker = savedMarkerVersion != latest.markerVersion;
    final needReaction = savedReactionVersion != latest.reactionVersion;

    if (!needMarker && !needReaction) {
      onProgress?.call(1.0, 'Dữ liệu AR đã sẵn sàng');
      return;
    }

    if (needMarker) {
      await _downloadAndExtract(
        url: latest.markerUrl,
        folderName: 'markers',
        version: latest.markerVersion,
        startProgress: 0.0,
        endProgress: needReaction ? 0.5 : 1.0,
        label: 'Marker',
        onProgress: onProgress,
      );

      await prefs.setInt(_markerVersionKey, latest.markerVersion);
    }

    if (needReaction) {
      await _downloadAndExtract(
        url: latest.reactionUrl,
        folderName: 'reactions',
        version: latest.reactionVersion,
        startProgress: needMarker ? 0.5 : 0.0,
        endProgress: 1.0,
        label: 'Reaction',
        onProgress: onProgress,
      );

      await prefs.setInt(_reactionVersionKey, latest.reactionVersion);
    }

    onProgress?.call(1.0, 'Hoàn tất tải dữ liệu AR');
  }

  static Future<void> _downloadAndExtract({
    required String url,
    required String folderName,
    required int version,
    required double startProgress,
    required double endProgress,
    required String label,
    void Function(double progress, String message)? onProgress,
  }) async {
    final appDir = await getApplicationSupportDirectory();
    final targetDir = Directory('${appDir.path}/ar_assets/$folderName/v$version');

    if (await targetDir.exists()) {
      await targetDir.delete(recursive: true);
    }

    await targetDir.create(recursive: true);

    final zipPath = '${targetDir.path}/bundle.zip';

    onProgress?.call(startProgress, 'Đang tải $label...');

    await Dio().download(
      url,
      zipPath,
      onReceiveProgress: (received, total) {
        if (total <= 0) return;

        final downloadProgress = received / total;
        final mappedProgress =
            startProgress + (endProgress - startProgress) * downloadProgress * 0.8;

        onProgress?.call(
          mappedProgress.clamp(0.0, 1.0),
          'Đang tải $label...',
        );
      },
    );

    onProgress?.call(
      startProgress + (endProgress - startProgress) * 0.85,
      'Đang giải nén $label...',
    );

    final inputStream = InputFileStream(zipPath);
    final archive = ZipDecoder().decodeStream(inputStream);

    for (final file in archive.files) {
      final filePath = '${targetDir.path}/${file.name}';

      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }

    inputStream.close();
    await File(zipPath).delete();

    onProgress?.call(endProgress, 'Đã chuẩn bị xong $label');
  }

  static Future<String> getMarkerPath() async {
    final prefs = await SharedPreferences.getInstance();
    final version = prefs.getInt(_markerVersionKey) ?? 1;

    final appDir = await getApplicationSupportDirectory();
    return '${appDir.path}/ar_assets/markers/v$version';
  }

  static Future<String> getReactionPath() async {
    final prefs = await SharedPreferences.getInstance();
    final version = prefs.getInt(_reactionVersionKey) ?? 1;

    final appDir = await getApplicationSupportDirectory();
    return '${appDir.path}/ar_assets/reactions/v$version';
  }
}