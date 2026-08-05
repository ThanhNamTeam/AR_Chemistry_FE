/// Giữ attempt quiz đang ở trạng thái WAITING_AR trong khi người dùng rời
/// sang luồng quét AR (Unity).
///
/// Luồng quiz mới của backend bắt buộc: start attempt -> quét 2 thẻ + phản
/// ứng AR thành công -> `complete-ar` -> mới mở câu hỏi. Màn quét AR nằm ở
/// cây widget hoàn toàn khác (Unity host), không có cách truyền attemptCode
/// qua arguments — nên dùng một holder tĩnh:
///
/// - Màn chờ AR của quiz `arm()` trước khi mở máy quét, `disarm()` khi thoát.
/// - `ar_camera_view` khi phản ứng khớp sẽ đọc holder; có attempt đang chờ
///   thì gọi complete-ar với mã thẻ vừa quét.
class ActiveQuizAttempt {
  ActiveQuizAttempt._();

  static String? _attemptCode;

  static String? get attemptCode => _attemptCode;
  static bool get isArmed => _attemptCode != null;

  static void arm(String attemptCode) => _attemptCode = attemptCode;

  /// Chỉ gỡ nếu vẫn đang giữ đúng attempt đó — tránh màn A dispose muộn gỡ
  /// nhầm attempt mà màn B vừa arm.
  static void disarm(String attemptCode) {
    if (_attemptCode == attemptCode) _attemptCode = null;
  }

  static void clear() => _attemptCode = null;
}
