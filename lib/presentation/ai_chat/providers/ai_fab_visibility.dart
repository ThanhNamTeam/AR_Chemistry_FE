import 'package:flutter/foundation.dart';

import '../../../core/storage/ai_fab_storage.dart';

/// Quản lý hiển thị nút AI nổi.
///
/// - [userEnabled]: người dùng bật/tắt trong phần cài đặt (lưu vào storage).
/// - [_modalOpen]: tạm ẩn khi modal chat đang mở (không persist).
/// - [visible]: kết hợp cả hai — FAB chỉ hiện khi user bật VÀ modal chưa mở.
class AiFabVisibility extends ChangeNotifier {
  final _storage = AiFabStorage();

  bool _userEnabled = true;
  bool _modalOpen = false;

  bool get visible => _userEnabled && !_modalOpen;
  bool get userEnabled => _userEnabled;

  AiFabVisibility() {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    _userEnabled = await _storage.loadEnabled();
    notifyListeners();
  }

  /// Bật/tắt bởi người dùng trong profile — được lưu vào storage.
  Future<void> setUserEnabled(bool value) async {
    if (_userEnabled == value) return;
    _userEnabled = value;
    notifyListeners();
    await _storage.saveEnabled(value);
  }

  /// Tạm ẩn FAB khi modal chat mở (không ảnh hưởng preference của user).
  void hide() {
    if (_modalOpen) return;
    _modalOpen = true;
    notifyListeners();
  }

  /// Hiện lại FAB khi modal chat đóng.
  void show() {
    if (!_modalOpen) return;
    _modalOpen = false;
    notifyListeners();
  }
}
