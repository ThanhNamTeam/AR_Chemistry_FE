import 'package:shared_preferences/shared_preferences.dart';

class AiFabStorage {
  static const _xKey = 'ai_fab_x_fraction';
  static const _yKey = 'ai_fab_y_fraction';

  Future<({double x, double y})?> loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final x = prefs.getDouble(_xKey);
    final y = prefs.getDouble(_yKey);
    if (x == null || y == null) return null;
    return (x: x, y: y);
  }

  Future<void> savePosition(double x, double y) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_xKey, x.clamp(0.0, 1.0));
    await prefs.setDouble(_yKey, y.clamp(0.0, 1.0));
  }
}
