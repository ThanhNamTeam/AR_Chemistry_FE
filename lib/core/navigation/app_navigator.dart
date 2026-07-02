import 'package:flutter/material.dart';

/// Navigator gốc — dùng sau async login để tránh mất context.
class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static NavigatorState? get state => key.currentState;

  /// Route name of the topmost visible route (for FAB scroll behavior).
  static String? get currentRouteName {
    final context = key.currentContext;
    if (context == null) return null;
    return ModalRoute.of(context)?.settings.name;
  }

  static Future<T?>? pushNamedAndRemoveAll<T extends Object?>(
    String route, {
    Object? arguments,
  }) {
    return state?.pushNamedAndRemoveUntil<T>(
      route,
      (_) => false,
      arguments: arguments,
    );
  }
}
