import 'package:shared_preferences/shared_preferences.dart';

/// Chuỗi ngày học liên tiếp (streak), lưu cục bộ theo email.
///
/// Quy tắc: mỗi ngày mở app (vào Home khi đã đăng nhập) tính là một ngày học.
/// - Hôm qua có học → streak +1.
/// - Hôm nay đã tính rồi → giữ nguyên.
/// - Bỏ lỡ ≥1 ngày → reset về 1.
///
/// Lưu client-side vì backend chưa có API streak; đổi máy sẽ mất chuỗi —
/// chấp nhận được cho v1, sau này backend có thể đồng bộ.
class StudyStreakService {
  StudyStreakService._();

  static String _countKey(String email) => 'study_streak_count_$email';
  static String _lastDayKey(String email) => 'study_streak_last_day_$email';

  static String _dayString(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Ghi nhận "hôm nay có học" và trả về độ dài chuỗi hiện tại.
  static Future<int> touchToday(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = _dayString(today);
    final yesterdayStr =
        _dayString(today.subtract(const Duration(days: 1)));

    final lastDay = prefs.getString(_lastDayKey(email));
    var count = prefs.getInt(_countKey(email)) ?? 0;

    if (lastDay == todayStr) {
      // Hôm nay đã ghi nhận — không đổi.
      return count == 0 ? 1 : count;
    }

    count = (lastDay == yesterdayStr) ? count + 1 : 1;

    await prefs.setInt(_countKey(email), count);
    await prefs.setString(_lastDayKey(email), todayStr);
    return count;
  }

  /// Đọc streak hiện tại mà không ghi nhận ngày mới.
  /// Trả 0 nếu chuỗi đã đứt (lần học cuối trước hôm qua).
  static Future<int> current(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDay = prefs.getString(_lastDayKey(email));
    if (lastDay == null) return 0;

    final today = DateTime.now();
    final valid = lastDay == _dayString(today) ||
        lastDay == _dayString(today.subtract(const Duration(days: 1)));
    return valid ? (prefs.getInt(_countKey(email)) ?? 0) : 0;
  }
}
