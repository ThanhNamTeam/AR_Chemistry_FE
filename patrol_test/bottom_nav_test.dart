import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:labedu/main.dart' as app;

void main() {
  patrolTest(
    'Navigate between bottom tabs correctly',
        ($) async {
      app.main();

      await $.pump(const Duration(seconds: 5));

      if ($('Bỏ qua').exists) {
        await $('Bỏ qua').tap();
        await $.pump(const Duration(seconds: 2));
      }

      // Login
      await $(TextFormField).at(0).enterText(
        'an12345@yopmail.com',
      );

      await $(TextFormField).at(1).enterText(
        '13579Messi@',
      );

      FocusManager.instance.primaryFocus?.unfocus();

      await $.pump(const Duration(seconds: 1));

      await $('Đăng nhập').tap();

      await $.pump(const Duration(seconds: 12));

      // HOME
      expect(
        $(#student_home_screen),
        findsOneWidget,
      );

      // SHOP
      await $(#nav_shop).tap();
      await $.pump(const Duration(seconds: 3));

      expect(
        $(#shop_screen),
        findsOneWidget,
      );

      // QUIZ
      await $(#nav_quiz).tap();
      await $.pump(const Duration(seconds: 3));

      expect(
        $(#quiz_list_screen),
        findsOneWidget,
      );

      // MINI GAME
      await $(#nav_minigame).tap();
      await $.pump(const Duration(seconds: 3));

      expect(
        $(#mini_game_screen),
        findsOneWidget,
      );

      // QUAY VỀ HOME
      await $(#nav_home).tap();
      await $.pump(const Duration(seconds: 3));

      expect(
        $(#student_home_screen),
        findsOneWidget,
      );
    },
  );
}