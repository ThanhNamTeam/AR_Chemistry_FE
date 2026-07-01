import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class OrientationLockService {
  const OrientationLockService._();

  static const MethodChannel _channel = MethodChannel(
    'labedu/orientation',
  );

  static const scannerUnitySceneLoaded = 'scannerUnitySceneLoaded';
  static const scannerUnityReadyFallback = 'scannerUnityReadyFallback';
  static const scannerAlreadyReady = 'scannerAlreadyReady';
  static const scannerEnter = 'scannerEnter';
  static const scannerExit = 'scannerExit';

  static Future<void> lockScannerLandscape({required String reason}) async {
    await _invokeAndroidOrientation(
      'lockScannerLandscape',
      reason: reason,
      arguments: <String, Object?>{'reason': reason},
    );
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static Future<void> requestScannerLandscape() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await _invokeAndroidOrientation(
      'requestScannerLandscape',
      reason: 'requestScannerLandscape',
    );
  }

  static Future<void> restoreAppPortrait({String reason = scannerExit}) async {
    await _invokeAndroidOrientation(
      'restoreAppPortrait',
      reason: reason,
      arguments: <String, Object?>{'reason': reason},
    );
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Future<void> logAndroidOrientationState(String reason) async {
    await _invokeAndroidOrientation('getOrientationState', reason: reason);
  }

  static Future<void> _invokeAndroidOrientation(
    String method, {
    String? reason,
    Object? arguments,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      final state = await _channel.invokeMapMethod<String, Object?>(
        method,
        arguments,
      );
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
