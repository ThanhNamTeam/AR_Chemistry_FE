import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/ar_asset_api.dart';
import '../models/response/ar_asset_response.dart';

class ArAssetDownloader {
  static const String _markerVersionKey = 'ar_marker_version';
  static const String _reactionVersionKey = 'ar_reaction_version';

  static Future<void> ensureReady({
    void Function(double progress, String message)? onProgress,
  }) async {
    onProgress?.call(0.0, 'Checking AR assets...');

    final prefs = await SharedPreferences.getInstance();
    final savedMarkerVersion = prefs.getInt(_markerVersionKey) ?? 0;
    final savedReactionVersion = prefs.getInt(_reactionVersionKey) ?? 0;

    final hasMarkerCache = await _isValidExtractedFolder(
      'markers',
      savedMarkerVersion,
    );
    final hasReactionCache = await _isValidExtractedFolder(
      'reactions',
      savedReactionVersion,
    );

    final latest = await _getLatestOrUseCache(
      hasMarkerCache: hasMarkerCache,
      hasReactionCache: hasReactionCache,
      onProgress: onProgress,
    );
    if (latest == null) return;
    _validateLatestResponse(latest);

    final needMarker =
        savedMarkerVersion != latest.markerVersion || !hasMarkerCache;
    final needReaction =
        savedReactionVersion != latest.reactionVersion || !hasReactionCache;

    if (!needMarker && !needReaction) {
      onProgress?.call(1.0, 'AR assets ready');
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

      if (!await _isValidExtractedFolder('markers', latest.markerVersion)) {
        throw StateError('Marker bundle extraction is incomplete');
      }

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

      if (!await _isValidExtractedFolder('reactions', latest.reactionVersion)) {
        throw StateError('Reaction bundle extraction is incomplete');
      }

      await prefs.setInt(_reactionVersionKey, latest.reactionVersion);
    }

    onProgress?.call(1.0, 'AR assets ready');
  }

  static Future<ArAssetResponse?> _getLatestOrUseCache({
    required bool hasMarkerCache,
    required bool hasReactionCache,
    void Function(double progress, String message)? onProgress,
  }) async {
    try {
      return await ArAssetApi().getLatestArAssets();
    } catch (_) {
      if (hasMarkerCache && hasReactionCache) {
        onProgress?.call(1.0, 'Using cached AR assets');
        return null;
      }

      rethrow;
    }
  }

  static void _validateLatestResponse(ArAssetResponse latest) {
    if (latest.markerVersion <= 0) {
      throw StateError('AR marker asset version is missing from API');
    }
    if (latest.reactionVersion <= 0) {
      throw StateError('AR reaction asset version is missing from API');
    }
    if (latest.markerUrl.trim().isEmpty) {
      throw StateError('AR marker asset URL is missing from API');
    }
    if (latest.reactionUrl.trim().isEmpty) {
      throw StateError('AR reaction asset URL is missing from API');
    }
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
    final tempDir = Directory(
      '${appDir.path}/ar_assets/.tmp_${folderName}_v$version',
    );

    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    await tempDir.create(recursive: true);

    final zipPath = '${tempDir.path}/bundle.zip';

    onProgress?.call(startProgress, 'Downloading $label...');

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
          'Downloading $label...',
        );
      },
    );

    onProgress?.call(
      startProgress + (endProgress - startProgress) * 0.85,
      'Extracting $label...',
    );

    final inputStream = InputFileStream(zipPath);
    final archive = ZipDecoder().decodeStream(inputStream);

    for (final file in archive.files) {
      final filePath = '${tempDir.path}/${file.name}';

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

    if (await targetDir.exists()) {
      await targetDir.delete(recursive: true);
    }
    await tempDir.rename(targetDir.path);

    onProgress?.call(endProgress, '$label ready');
  }

  static Future<bool> _isValidExtractedFolder(
    String folderName,
    int version,
  ) async {
    if (version <= 0) return false;

    final appDir = await getApplicationSupportDirectory();
    final baseDir = Directory('${appDir.path}/ar_assets/$folderName/v$version');
    if (!await baseDir.exists()) return false;

    final expectedChild = folderName == 'markers'
        ? 'MarkerVisualBundles/Android'
        : 'ReactionBundles/Android';
    final expectedDir = Directory('${baseDir.path}/$expectedChild');
    if (!await expectedDir.exists()) return false;

    await for (final entity in expectedDir.list(recursive: false)) {
      if (entity is File) return true;
    }

    return false;
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
