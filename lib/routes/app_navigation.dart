import 'package:flutter/material.dart';

import 'app_routes.dart';

class AppNavigation {
  /// Opens My Bag while keeping [AppRoutes.home] in the stack when possible.
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
