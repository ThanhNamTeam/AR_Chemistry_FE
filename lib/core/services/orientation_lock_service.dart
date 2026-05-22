import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class OrientationLockService {
  const OrientationLockService._();

  static const MethodChannel _channel = MethodChannel(
    'ar_chemistry_visual/orientation',
  );

  static Future<void> requestScannerLandscape() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
    ]);
    await _invokeAndroidOrientation(
      'requestScannerLandscape',
      reason: 'requestScannerLandscape',
    );
  }

  static Future<void> restoreAppPortrait() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await _invokeAndroidOrientation(
      'restoreAppPortrait',
      reason: 'restoreAppPortrait',
    );
  }

  static Future<void> logAndroidOrientationState(String reason) async {
    await _invokeAndroidOrientation('getOrientationState', reason: reason);
  }

  static Future<void> _invokeAndroidOrientation(
    String method, {
    String? reason,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      final state = await _channel.invokeMapMethod<String, Object?>(method);
      debugPrint(
        '[AR_UNITY_TIMING] orientationNative $method '
        'reason=${reason ?? method} state=$state',
      );
    } on MissingPluginException catch (error) {
      debugPrint(
        '[AR_UNITY_TIMING] orientationChannelMissing method=$method '
        'reason=${reason ?? method} $error',
      );
    } on PlatformException catch (error) {
      debugPrint(
        '[AR_UNITY_TIMING] orientationPlatformError method=$method '
        'reason=${reason ?? method} code=${error.code} '
        'message=${error.message} details=${error.details}',
      );
    }
  }
}
