import 'package:flutter/material.dart';

import 'app_routes.dart';

class AppNavigation {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static Future<T?> pushNamed<T extends Object?>(
      String routeName, {
        Object? arguments,
      }) {
    final nav = navigatorKey.currentState;
    if (nav == null) return Future.value(null);

    return nav.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushNamedAndRemoveAll<T extends Object?>(
      String routeName, {
        Object? arguments,
      }) {
    final nav = navigatorKey.currentState;
    if (nav == null) return Future.value(null);

    return nav.pushNamedAndRemoveUntil<T>(
      routeName,
          (_) => false,
      arguments: arguments,
    );
  }

  static void openMyBag(BuildContext context) {
    final nav = Navigator.of(context);
    var hasHome = false;

    nav.popUntil((route) {
      if (route.settings.name == AppRoutes.home) {
        hasHome = true;
        return true;
      }
      return false;
    });

    if (!hasHome) {
      nav.pushReplacementNamed(AppRoutes.home);
    }

    nav.pushNamed(AppRoutes.myBag);
  }

  static void backFromMyBag(BuildContext context) {
    final nav = Navigator.of(context);

    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacementNamed(AppRoutes.home);
    }
  }
}