import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _requestPermission();
    await printFcmToken();
    _listenTokenRefresh();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> printFcmToken() async {
    final token = await _messaging.getToken();

    print('================ FCM TOKEN ================');
    print(token);
    print('===========================================');
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      print('============== NEW FCM TOKEN ==============');
      print(newToken);
      print('===========================================');

      // Sau này chỗ này sẽ gọi API gửi token lên backend
    });
  }
}