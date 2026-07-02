import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/navigation/app_navigator.dart';
import '../../../core/storage/ai_fab_storage.dart';
import '../../../routes/app_routes.dart';

enum AiFabDisplayMode { expanded, minimized }

/// Quản lý hiển thị nút AI nổi.
///
/// - [userEnabled]: người dùng bật/tắt trong phần cài đặt (lưu vào storage).
/// - [_modalOpen]: tạm ẩn khi modal chat đang mở (không persist).
/// - [displayMode]: expanded (64px + label) hoặc minimized (48px sparkle).
/// - [visible]: kết hợp cả hai — FAB chỉ hiện khi user bật VÀ modal chưa mở.
class AiFabVisibility extends ChangeNotifier {
  final _storage = AiFabStorage();

  bool _userEnabled = true;
  bool _modalOpen = false;
  AiFabDisplayMode _displayMode = AiFabDisplayMode.expanded;
  double _scrollDownAccum = 0;

  static const _scrollMinimizeThreshold = 100.0;

  /// Màn có list scroll dài — auto-minimize khi user scroll xuống.
  static const scrollAutoMinimizeRoutes = {
    AppRoutes.shop,
    AppRoutes.library,
    AppRoutes.myBag,
    AppRoutes.cart,
    AppRoutes.quizList,
    AppRoutes.quizHistory,
    AppRoutes.myFeedbacks,
    AppRoutes.mySingleCards,
    AppRoutes.miniGame,
    AppRoutes.substanceDetail,
  };

  bool get visible => _userEnabled && !_modalOpen;
  bool get userEnabled => _userEnabled;
  bool get isMinimized => _displayMode == AiFabDisplayMode.minimized;
  bool get isExpanded => _displayMode == AiFabDisplayMode.expanded;
  AiFabDisplayMode get displayMode => _displayMode;

  AiFabVisibility() {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    _userEnabled = await _storage.loadEnabled();
    notifyListeners();
  }

  Future<void> setUserEnabled(bool value) async {
    if (_userEnabled == value) return;
    _userEnabled = value;
    notifyListeners();
    await _storage.saveEnabled(value);
  }

  void hide() {
    if (_modalOpen) return;
    _modalOpen = true;
    notifyListeners();
  }

  void show() {
    if (!_modalOpen) return;
    _modalOpen = false;
    notifyListeners();
  }

  void minimize() {
    if (_displayMode == AiFabDisplayMode.minimized) return;
    _displayMode = AiFabDisplayMode.minimized;
    _scrollDownAccum = 0;
    notifyListeners();
  }

  void expand() {
    if (_displayMode == AiFabDisplayMode.expanded) return;
    _displayMode = AiFabDisplayMode.expanded;
    _scrollDownAccum = 0;
    notifyListeners();
  }

  /// Gọi từ [NotificationListener] trên overlay — scroll xuống trên màn list.
  void onScrollNotification(ScrollNotification notification) {
    if (!visible || isMinimized) return;

    final route = AppNavigator.currentRouteName;
    if (route == null || !scrollAutoMinimizeRoutes.contains(route)) {
      return;
    }

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta;
      if (delta == null || delta <= 0) return;
      _scrollDownAccum += delta;
      if (_scrollDownAccum >= _scrollMinimizeThreshold) {
        minimize();
      }
    } else if (notification is ScrollEndNotification) {
      _scrollDownAccum = 0;
    }
  }
}
