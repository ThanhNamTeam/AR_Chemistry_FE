import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDeviceInfoService {
  static Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  static Future<String> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;

      return [
        'Android ${android.version.release}',
        android.manufacturer,
        android.model,
        'SDK ${android.version.sdkInt}',
      ].where((e) => e.trim().isNotEmpty).join(' | ');
    }

    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;

      return [
        '${ios.systemName} ${ios.systemVersion}',
        ios.name,
        ios.model,
      ].where((e) => e.trim().isNotEmpty).join(' | ');
    }

    return Platform.operatingSystem;
  }
}