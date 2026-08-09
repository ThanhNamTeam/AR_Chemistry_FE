import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/native_download_manager.dart';
import '../api/ar_asset_api.dart';
import '../models/response/ar_asset_response.dart';

class ArAssetDownloader {
  static const String _markerVersionKey = 'ar_marker_version';
  static const String _reactionVersionKey = 'ar_reaction_version';

  static Future<void>? _runningTask;

  static bool get isDownloading => _runningTask != null;

  static bool _isExtracting = false;
  static bool get isExtracting => _isExtracting;

  static Future<void> ensureReady({
    void Function(double progress, String message)? onProgress,
  }) {
    _runningTask ??= _ensureReadyInternal(onProgress: onProgress).whenComplete(
      () {
        _runningTask = null;
      },
    );

    return _runningTask!;
  }

  static Future<void> _ensureReadyInternal({
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
        totalBytes: latest.markerSizeBytes,
        startProgress: 0,
        endProgress: needReaction ? 0.5 : 1,
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
        totalBytes: latest.reactionSizeBytes,
        startProgress: needMarker ? 0.5 : 0,
        endProgress: 1,
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
    required int totalBytes,
    void Function(double progress, String message)? onProgress,
  }) async {
    final appDir = await getApplicationSupportDirectory();

    final targetDir = Directory(
      '${appDir.path}/ar_assets/$folderName/v$version',
    );

    final tempDir = Directory(
      '${appDir.path}/ar_assets/.tmp_${folderName}_v$version',
    );

    final extractDir = Directory('${tempDir.path}/extract');

    if (await extractDir.exists()) {
      await extractDir.delete(recursive: true);
    }

    await extractDir.create(recursive: true);

    onProgress?.call(startProgress, 'Downloading $label...');

    final prefs = await SharedPreferences.getInstance();

    final downloadIdKey = 'ar_${folderName}_v${version}_download_id';
    final downloadPathKey = 'ar_${folderName}_v${version}_download_path';

    int? downloadId = prefs.getInt(downloadIdKey);
    String? savedPath = prefs.getString(downloadPathKey);

    if (downloadId == null || savedPath == null) {
      final started = await NativeDownloadManager.startDownload(
        url: url,
        fileName: '${folderName}_v$version.zip',
      );

      downloadId = started.downloadId;
      savedPath = started.filePath;

      await prefs.setInt(downloadIdKey, downloadId);
      await prefs.setString(downloadPathKey, savedPath);
    }

    var maxShownBytes = 0;

    final oldInfo = await NativeDownloadManager.queryDownload(downloadId);
    if (oldInfo.exists && oldInfo.bytesDownloaded > 0) {
      maxShownBytes = oldInfo.bytesDownloaded;
    }

    while (true) {
      final info = await NativeDownloadManager.queryDownload(downloadId!);

      if (!info.exists) {
        final restarted = await NativeDownloadManager.startDownload(
          url: url,
          fileName: '${folderName}_v$version.zip',
        );

        downloadId = restarted.downloadId;
        savedPath = restarted.filePath;

        await prefs.setInt(downloadIdKey, downloadId);
        await prefs.setString(downloadPathKey, savedPath);

        continue;
      }

      if (info.bytesDownloaded > maxShownBytes) {
        maxShownBytes = info.bytesDownloaded;
      }

      final realTotalBytes = info.totalBytes > 0 ? info.totalBytes : totalBytes;

      if (realTotalBytes > 0) {
        final safeProgress = (maxShownBytes / realTotalBytes).clamp(0.0, 1.0);

        final mappedProgress =
            startProgress + (endProgress - startProgress) * safeProgress * 0.95;

        onProgress?.call(
          mappedProgress.clamp(0.0, 1.0),
          'Downloading $label... ${_formatBytes(maxShownBytes)} / ${_formatBytes(realTotalBytes)}',
        );
      } else {
        onProgress?.call(
          startProgress,
          'Downloading $label... ${_formatBytes(maxShownBytes)} / --',
        );
      }

      if (info.isDone) {
        break;
      }

      if (info.isFailed) {
        await prefs.remove(downloadIdKey);
        await prefs.remove(downloadPathKey);

        throw StateError('Không thể tải $label. Android reason=${info.reason}');
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    final zipPath = savedPath;

    if (zipPath == null || zipPath.trim().isEmpty) {
      throw StateError('Download xong nhưng savedPath bị null');
    }

    final zipFile = fileFromAndroidLocalUriOrPath(
      savedPath: zipPath,
      localUri: null,
    );

    if (!await zipFile.exists()) {
      throw StateError('Download xong nhưng không thấy file zip: ${zipFile.path}');
    }

    _isExtracting = true;

    final inputStream = InputFileStream(zipFile.path);
    final archive = ZipDecoder().decodeStream(inputStream);

    final totalFiles = archive.files.length;
    var currentFile = 0;

    try {
      for (final file in archive.files) {
        currentFile++;

        final extractProgress = totalFiles == 0 ? 1.0 : currentFile / totalFiles;

        final mappedProgress =
            endProgress -
                (endProgress - startProgress) * 0.05 +
                ((endProgress - startProgress) * 0.05 * extractProgress);

        onProgress?.call(
          mappedProgress.clamp(0.0, 1.0),
          'Extracting $label... ($currentFile/$totalFiles)',
        );

        final normalizedName = file.name.replaceAll('\\', '/');
        final filePath = '${extractDir.path}/$normalizedName';

        if (file.isFile) {
          final outFile = File(filePath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }
    } finally {
      _isExtracting = false;
      await inputStream.close();
    }

    if (await targetDir.exists()) {
      await targetDir.delete(recursive: true);
    }

    await targetDir.parent.create(recursive: true);
    await extractDir.rename(targetDir.path);

    await prefs.remove(downloadIdKey);
    await prefs.remove(downloadPathKey);

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

  static String _formatBytes(int bytes) {
    final mb = bytes / (1024 * 1024);

    if (mb >= 1) {
      return '${mb.toStringAsFixed(1)}MB';
    }

    final kb = bytes / 1024;
    return '${kb.toStringAsFixed(1)}KB';
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
