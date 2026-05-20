import 'package:flutter/material.dart';

/// Navigator gốc — dùng sau async login để tránh mất context.
class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static NavigatorState? get state => key.currentState;

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
