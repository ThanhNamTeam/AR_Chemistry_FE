import 'package:flutter/foundation.dart';

/// Ẩn nút nổi khi modal chat đang mở (tránh nút đè lên sheet).
class AiFabVisibility extends ChangeNotifier {
  bool _visible = true;

  bool get visible => _visible;

  void hide() {
    if (!_visible) return;
    _visible = false;
    notifyListeners();
  }

  void show() {
    if (_visible) return;
    _visible = true;
    notifyListeners();
  }
}
