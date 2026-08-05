import 'package:flutter/foundation.dart';

import '../l10n/app_localizations.dart';

/// Đổi exception/chuỗi lỗi kỹ thuật thành thông báo thân thiện cho người dùng.
///
/// Quy tắc (P0 audit UX): người dùng cuối KHÔNG BAO GIỜ được thấy raw
/// exception, response JSON hay stack trace — kể cả debug build. Chi tiết
/// thật được đẩy vào [debugPrint] (đầy đủ trong log/ELK) để dev truy vết.
///
/// Phân loại theo dấu vết phổ biến của stack Flutter/http:
/// - Mạng: SocketException / Failed host lookup / Connection refused|reset
/// - Timeout: TimeoutException
/// - Phiên đăng nhập: 401 / 403 / not signed in
/// - Server: HTTP 5xx
/// - Còn lại: thông báo chung.
String friendlyError(
  AppLocalizations l10n,
  Object? error, {
  String? context,
}) {
  final raw = error?.toString() ?? '';
  debugPrint('[ERROR${context == null ? '' : ':$context'}] $raw');

  final s = raw.toLowerCase();

  if (s.contains('socketexception') ||
      s.contains('failed host lookup') ||
      s.contains('connection refused') ||
      s.contains('connection reset') ||
      s.contains('network is unreachable')) {
    return l10n.errNetwork;
  }
  if (s.contains('timeoutexception') || s.contains('timed out')) {
    return l10n.errTimeout;
  }
  if (s.contains(' 401') ||
      s.contains(' 403') ||
      s.contains('not signed in') ||
      s.contains('unauthorized')) {
    return l10n.errSession;
  }
  if (s.contains(' 500') ||
      s.contains(' 502') ||
      s.contains(' 503') ||
      s.contains(' 504')) {
    return l10n.errServer;
  }
  return l10n.errGeneric;
}
