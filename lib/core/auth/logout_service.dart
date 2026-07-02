import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../services/notification_service.dart';
import '../api/notification_token_api.dart';

class LogoutService {
  static Future<void> logout() async {
    try {
      final fcmToken = await NotificationService.instance.getFcmToken();

      if (fcmToken != null && fcmToken.isNotEmpty) {
        await NotificationTokenApi().logoutCurrentDevice(
          fcmToken: fcmToken,
        );

        debugPrint('FCM token deactivated successfully');
      }
    } catch (e) {
      debugPrint('Deactivate FCM token failed, continue logout: $e');
    }

    await NotificationService.instance.stopTokenRefreshListener();

    await Amplify.Auth.signOut();
  }
}