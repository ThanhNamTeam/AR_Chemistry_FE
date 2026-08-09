import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:labedu/main.dart' as app;

void main() {
  patrolTest(
    'Mini Game answer first question and go to question 2',
        ($) async {
      app.main();

      await $.pump(const Duration(seconds: 5));

      if ($('Bỏ qua').exists) {
        await $('Bỏ qua').tap();
        await $.pump(const Duration(seconds: 2));
      }

      // =====================
      // LOGIN
      // =====================

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

      expect(
        $(#student_home_screen),
        findsOneWidget,
      );

      // =====================
      // MINI GAME
      // =====================

      await $(#nav_minigame).tap();

      await $.pump(const Duration(seconds: 3));

      expect(
        $(#mini_game_screen),
        findsOneWidget,
      );

      // Chơi quiz
      await $('Chơi Quiz').tap();

      await $.pump(const Duration(seconds: 2));

      expect(
        $('Chọn độ khó'),
        findsOneWidget,
      );

      // Chọn Dễ
      await $('Dễ').tap();

      await $.pump(const Duration(seconds: 3));

      expect(
        $(#mini_game_play_screen),
        findsOneWidget,
      );

      // =====================
      // CÂU 1
      // =====================

      // Chưa trả lời -> chưa có feedback
      expect(
        $(#minigame_feedback),
        findsNothing,
      );

      // Chọn đáp án đầu tiên.
      // Không quan trọng đúng hay sai,
      // mục tiêu test là interaction flow.
      await $(#minigame_choice_0).tap();

      await $.pump(const Duration(seconds: 1));

      // Sau khi chọn phải hiện feedback
      expect(
        $(#minigame_feedback),
        findsOneWidget,
      );

      // Nút Next vẫn tồn tại
      expect(
        $(#minigame_next_button),
        findsOneWidget,
      );

      // Chuyển câu
      await $(#minigame_next_button).tap();

      await $.pump(const Duration(seconds: 2));

      // =====================
      // CÂU 2
      // =====================

      // Sang câu mới thì feedback phải biến mất
      expect(
        $(#minigame_feedback),
        findsNothing,
      );

      // Màn chơi vẫn còn
      expect(
        $(#mini_game_play_screen),
        findsOneWidget,
      );

      // Top bar của code hiện tại hiển thị 2/total.
      // Kiểm tra đã thực sự sang câu thứ 2.
      expect(
        find.textContaining('2/'),
        findsOneWidget,
      );
    },
  );
}