import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:labedu/main.dart' as app;

void main() {
  patrolTest(
    'Student login successfully',
        ($) async {
      unawaited(app.main());

      await $.pump(const Duration(seconds: 5));

      if ($('Bỏ qua').exists) {
        await $('Bỏ qua').tap();
        await $.pump(const Duration(seconds: 2));
      }

      expect(
        $(TextFormField),
        findsAtLeastNWidgets(2),
      );

      await $(TextFormField).at(0).enterText(
        'an12345@yopmail.com',
      );

      await $(TextFormField).at(1).enterText(
        '13579Messi@',
      );

      await $.pump(const Duration(seconds: 1));

      FocusManager.instance.primaryFocus?.unfocus();

      await $.pump(const Duration(seconds: 1));

      expect(
        $('Đăng nhập'),
        findsOneWidget,
      );

      await $('Đăng nhập').tap();

      // Chờ Cognito + backend + navigation
      await $.pump(const Duration(seconds: 12));

      // Login screen phải biến mất
      expect(
        $('Đăng nhập'),
        findsNothing,
      );

      // HomeScreen phải xuất hiện
      expect(
        $(#student_home_screen),
        findsOneWidget,
      );
    },
  );
}