import 'package:flutter/widgets.dart';

/// Theo dõi tên route đang hiển thị và phát ra dưới dạng [ValueNotifier].
///
/// [AppNavigator.currentRouteName] chỉ đọc được tại thời điểm gọi, không báo
/// thay đổi. Thanh điều hướng dưới lại nằm trong `MaterialApp.builder` —
/// tức PHÍA TRÊN Navigator — nên không dùng được `ModalRoute.of(context)`.
/// Observer này lấp đúng khoảng trống đó: mỗi lần điều hướng sẽ cập nhật
/// [routeName], giúp lớp chrome bên ngoài biết đang ở màn nào để ẩn/hiện.
class CurrentRouteObserver extends NavigatorObserver {
  static final ValueNotifier<String?> routeName = ValueNotifier<String?>(null);

  void _update(Route<dynamic>? route) {
    if (route is ModalRoute) {
      routeName.value = route.settings.name;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _update(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _update(previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _update(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _update(newRoute);
  }
}

/// Instance dùng chung, đăng ký trong `MaterialApp.navigatorObservers`.
final currentRouteObserver = CurrentRouteObserver();
