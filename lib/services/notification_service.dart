import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';

import '../core/navigation/app_navigator.dart';
import '../routes/app_navigation.dart';
import '../routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  Map<String, dynamic>? _pendingNotificationData;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSubscription;

  static const AndroidNotificationChannel _androidChannel =
  AndroidNotificationChannel(
    'ar_chemistry_high_importance',
    'AR Chemistry Notifications',
    description: 'Thông báo nhắc học, quét AR và Knowledge Point',
    importance: Importance.high,
  );

  Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _initFcmListeners();
    await printFcmToken();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;

        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;

          _handleNotificationClick(
            data,
            navigateNow: true,
          );
        } catch (e) {
          debugPrint('Parse notification payload failed: $e');
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  void handlePendingNavigationAfterLoginReady() {
    _tryNavigateFromPendingNotification();
  }

  Future<void> _initFcmListeners() async {
    // App đang mở foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM foreground message: ${message.data}');
      _showForegroundNotification(message);
    });

    // App đang chạy nền, user bấm notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM opened from background: ${message.data}');

      _handleNotificationClick(
        message.data,
        navigateNow: true,
      );
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM opened from terminated: ${initialMessage.data}');

      // App tắt hẳn: chỉ lưu pending, chưa navigate ngay.
      // Đợi app restore session vào Home xong rồi LoginScreen/AppState sẽ gọi.
      _handleNotificationClick(
        initialMessage.data,
        navigateNow: false,
      );
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    final title = notification?.title ?? message.data['title'] ?? 'AR Chemistry';
    final body = notification?.body ??
        message.data['body'] ??
        'Bạn có thông báo mới từ AR Chemistry';

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationClick(
      Map<String, dynamic> data, {
        bool navigateNow = false,
      }) {
    debugPrint('Notification clicked data=$data');

    _pendingNotificationData = data;

    if (navigateNow) {
      Future.delayed(const Duration(milliseconds: 300), () {
        handlePendingNavigationAfterLoginReady();
      });
    }
  }

  bool get hasPendingNotificationNavigation {
    return _pendingNotificationData != null;
  }


  Future<String?> getFcmToken() async {
    return _messaging.getToken();
  }

  Future<void> printFcmToken() async {
    final token = await getFcmToken();

    debugPrint('================ FCM TOKEN ================');
    debugPrint(token);
    debugPrint('===========================================');
  }

  void startTokenRefreshListener({
    required Future<void> Function(String token) onRefresh,
  }) {
    _tokenRefreshSubscription?.cancel();

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
          (newToken) async {
        debugPrint('============== NEW FCM TOKEN ==============');
        debugPrint(newToken);
        debugPrint('===========================================');

        try {
          await onRefresh(newToken);
        } catch (e) {
          debugPrint('Refresh FCM token failed: $e');
        }
      },
    );
  }

  Future<void> stopTokenRefreshListener() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  void _tryNavigateFromPendingNotification({int attempt = 0}) {
    final data = _pendingNotificationData;
    if (data == null) return;

    final nav = AppNavigator.key.currentState;

    if (nav == null) {
      if (attempt < 20) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _tryNavigateFromPendingNotification(attempt: attempt + 1);
        });
      } else {
        debugPrint('Navigator still null, skip notification navigation');
      }
      return;
    }

    final screen = data['screen'];
    debugPrint('Navigate from notification. screen=$screen');

    _pendingNotificationData = null;

    switch (screen) {
      case 'AR_SCAN':
        nav.pushNamed(AppRoutes.scan);
        break;

      case 'SHOP':
        nav.pushNamed(AppRoutes.shop);
        break;

      case 'QUIZ':
        nav.pushNamed(AppRoutes.quizList);
        break;

      case 'MINI_GAME':
        nav.pushNamed(AppRoutes.miniGame);
        break;

      case 'MY_CARDS':
        nav.pushNamed(AppRoutes.mySingleCards);
        break;

      case 'MY_BAG':
        nav.pushNamed(AppRoutes.myBag);
        break;

      case 'PROFILE':
        nav.pushNamed(AppRoutes.profile);
        break;

      default:
        nav.pushNamed(AppRoutes.home);
        break;
    }
  }
}