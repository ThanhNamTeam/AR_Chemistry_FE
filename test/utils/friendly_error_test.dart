import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/core/l10n/app_localizations.dart';
import 'package:labedu/core/utils/friendly_error.dart';

// Dùng locale VI cho tất cả test
final _viL10n = AppLocalizations(const Locale('vi'));
final _enL10n = AppLocalizations(const Locale('en'));

void main() {
  // ── Network errors ────────────────────────────────────────────────────────

  group('friendlyError – lỗi mạng (network)', () {
    for (final msg in [
      'SocketException: connection refused',
      'Failed host lookup: api.example.com',
      'Connection refused',
      'Connection reset by peer',
      'network is unreachable',
    ]) {
      test('[$msg] → errNetwork', () {
        final result = friendlyError(_viL10n, Exception(msg));
        expect(result, _viL10n.errNetwork);
      });
    }
  });

  // ── Timeout errors ────────────────────────────────────────────────────────

  group('friendlyError – timeout', () {
    test('TimeoutException → errTimeout', () {
      expect(friendlyError(_viL10n, Exception('TimeoutException')),
          _viL10n.errTimeout);
    });

    test('"timed out" → errTimeout', () {
      expect(friendlyError(_viL10n, Exception('Request timed out after 30s')),
          _viL10n.errTimeout);
    });

    test('case-insensitive TimeoutException → errTimeout', () {
      expect(friendlyError(_viL10n, Exception('timeoutexception blah')),
          _viL10n.errTimeout);
    });
  });

  // ── Session / Auth errors ─────────────────────────────────────────────────

  group('friendlyError – phiên đăng nhập', () {
    test('HTTP 401 → errSession', () {
      expect(friendlyError(_viL10n, Exception('HTTP status 401')),
          _viL10n.errSession);
    });

    test('HTTP 403 → errSession', () {
      expect(friendlyError(_viL10n, Exception('Error 403 Forbidden')),
          _viL10n.errSession);
    });

    test('"not signed in" → errSession', () {
      expect(
          friendlyError(_viL10n, Exception('User is not signed in')),
          _viL10n.errSession);
    });

    test('"unauthorized" → errSession', () {
      expect(friendlyError(_viL10n, Exception('unauthorized access')),
          _viL10n.errSession);
    });
  });

  // ── Server errors ─────────────────────────────────────────────────────────

  group('friendlyError – lỗi server', () {
    for (final code in [500, 502, 503, 504]) {
      test('HTTP $code → errServer', () {
        expect(friendlyError(_viL10n, Exception('HTTP $code Internal Error')),
            _viL10n.errServer);
      });
    }
  });

  // ── Generic / unknown ─────────────────────────────────────────────────────

  group('friendlyError – lỗi chung (generic)', () {
    test('exception không rõ → errGeneric', () {
      expect(friendlyError(_viL10n, Exception('Something weird happened')),
          _viL10n.errGeneric);
    });

    test('null error → errGeneric', () {
      expect(friendlyError(_viL10n, null), _viL10n.errGeneric);
    });

    test('string rỗng → errGeneric', () {
      expect(friendlyError(_viL10n, ''), _viL10n.errGeneric);
    });
  });

  // ── Locale switch ─────────────────────────────────────────────────────────

  group('friendlyError – locale VI vs EN', () {
    test('network error: VI ≠ EN message', () {
      final vi = friendlyError(_viL10n, Exception('SocketException'));
      final en = friendlyError(_enL10n, Exception('SocketException'));
      expect(vi, _viL10n.errNetwork);
      expect(en, _enL10n.errNetwork);
      expect(vi, isNot(en));
    });

    test('generic error: VI ≠ EN message', () {
      final vi = friendlyError(_viL10n, Exception('random error'));
      final en = friendlyError(_enL10n, Exception('random error'));
      expect(vi, isNot(en));
    });
  });

  // ── context parameter ─────────────────────────────────────────────────────

  group('friendlyError – context tùy chọn', () {
    test('có context không ảnh hưởng đến kết quả phân loại', () {
      final withCtx =
          friendlyError(_viL10n, Exception('SocketException'), context: 'login');
      final withoutCtx = friendlyError(_viL10n, Exception('SocketException'));
      expect(withCtx, withoutCtx);
    });
  });
}
