import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Đọc cấu hình môi trường từ `.env` hoặc `--dart-define`.
///
/// Thứ tự ưu tiên:
/// 1. `--dart-define=API_BASE_URL=...` (CI / build release)
/// 2. `.env` (dev local — đổi IP khi đổi WiFi)
class EnvConfig {
  EnvConfig._();

  static const _defineKey = 'API_BASE_URL';
  static const _fallbackUrl = 'http://127.0.0.1:8080/api/v1';

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[EnvConfig] Không tìm thấy .env — copy .env.hoaianstudio thành .env '
          'và sửa API_BASE_URL.',
        );
      }
    }
  }

  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment(_defineKey);
    if (fromDefine.isNotEmpty) return _normalize(fromDefine);

    final fromEnv = dotenv.env[_defineKey];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return _normalize(fromEnv.trim());
    }

    if (kDebugMode) {
      debugPrint(
        '[EnvConfig] Dùng fallback $_fallbackUrl — hãy cấu hình .env',
      );
    }
    return _fallbackUrl;
  }

  /// Đọc biến môi trường: ưu tiên `--dart-define`, sau đó `.env`.
  static String value(String key, {String fromDefine = ''}) {
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromEnv = dotenv.env[key]?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    throw StateError(
      'Thiếu cấu hình "$key". Thêm vào .env hoặc truyền --dart-define=$key=...',
    );
  }

  static String _normalize(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
