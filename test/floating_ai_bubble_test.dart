import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:labedu/core/l10n/app_localizations.dart';
import 'package:labedu/presentation/ai_chat/providers/ai_fab_visibility.dart';
import 'package:labedu/presentation/ai_chat/widgets/ai_chat_icon.dart';
import 'package:labedu/presentation/ai_chat/widgets/floating_ai_bubble.dart';

/// Dựng FloatingAiBubble trong đúng ngữ cảnh nó chạy thật (Stack overlay
/// + provider + localization) để bắt exception làm Flutter hiện ErrorWidget đỏ.
void main() {
  // Vị trí cũ do AiFloatingAssistant lưu lại vẫn còn trong SharedPreferences,
  // nên phải test cả nhánh khôi phục theo tỉ lệ, không chỉ nhánh mặc định.
  for (final saved in <Map<String, Object>>[
    {},
    {'ai_fab_x_fraction': 1.0, 'ai_fab_y_fraction': 1.0},
    {'ai_fab_x_fraction': 0.0, 'ai_fab_y_fraction': 0.0},
    {'ai_fab_x_fraction': 0.93, 'ai_fab_y_fraction': 0.42},
  ]) {
    testWidgets('builds with saved=$saved', (tester) async {
      SharedPreferences.setMockInitialValues(saved);
      await _pumpBubble(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(FloatingAiBubble), findsOneWidget);
    });
  }

  testWidgets('builds while tucked (minimized)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final fab = AiFabVisibility();
    await _pumpBubble(tester, fab: fab);
    fab.minimize();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('kéo xuống giữa đáy → hiện nút X, thả vào đó thì ẩn', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpBubble(tester);

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;

    // Vùng X luôn nằm trong cây (để chạy được fade), nên đo ĐỘ MỜ chứ không
    // đo sự tồn tại: 0 = đang ẩn, 1 = đang hiện.
    double zoneOpacity() => tester
        .widget<AnimatedOpacity>(
          find
              .ancestor(
                of: find.byIcon(Icons.close_rounded),
                matching: find.byType(AnimatedOpacity),
              )
              .first,
        )
        .opacity;

    // Chưa kéo thì nút X còn ẩn.
    expect(zoneOpacity(), 0);

    // Kéo tới đúng tâm vùng X: giữa màn hình theo chiều ngang, cách đáy 96.
    final gesture = await _dragBubbleTo(
      tester,
      Offset(screen.width / 2, screen.height - 96),
    );

    // Đang kéo → nút X phải hiện ra.
    expect(zoneOpacity(), 1);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    // Đã ẩn: bong bóng biến mất, chỉ còn tab gọi lại.
    expect(find.byType(AiChatIcon), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);

    // Chạm tab để gọi lại.
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AiChatIcon), findsOneWidget);
  });

  testWidgets('thả ở giữa màn hình (xa vùng X) thì KHÔNG bị ẩn', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpBubble(tester);

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;

    final gesture = await _dragBubbleTo(
      tester,
      Offset(screen.width / 2, screen.height / 2),
    );
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byType(AiChatIcon), findsOneWidget);
  });

  // Đối chứng: chứng minh vì sao KHÔNG được dùng Tooltip trong overlay này.
  // Nếu test này bắt đầu pass (không còn throw) nghĩa là Flutter đã đổi hành vi
  // và có thể cân nhắc dùng lại Tooltip.
  testWidgets('ĐỐI CHỨNG: Tooltip throw khi không có Overlay tổ tiên', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => const Stack(
          fit: StackFit.expand,
          children: [
            Tooltip(
              message: 'Trợ lý AI',
              child: SizedBox(width: 56, height: 56),
            ),
          ],
        ),
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );
    expect(tester.takeException(), isNotNull);
  });

  testWidgets('long press hiện nhãn mà không cần Overlay', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpBubble(tester);

    expect(find.text('Trợ lý AI'), findsNothing);

    // Nhắm vào chính bong bóng: FloatingAiBubble giờ là Stack phủ toàn màn
    // hình nên tâm của nó là vùng trống, longPress sẽ trượt.
    await tester.longPress(find.byType(AiChatIcon));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.text('Trợ lý AI'), findsOneWidget);

    // Nhãn tự ẩn sau ~1.6s.
    await tester.pump(const Duration(milliseconds: 1700));
    expect(find.text('Trợ lý AI'), findsNothing);
  });
}

/// Kéo bong bóng tới [target] bằng NHIỀU bước nhỏ.
///
/// Quan trọng: một cú `moveTo` duy nhất chỉ sinh `onPanStart` mà không sinh
/// `onPanUpdate`, nên vị trí bong bóng sẽ không đổi và test cho kết quả sai.
/// Ngón tay thật luôn sinh nhiều event, nên chia nhỏ mới phản ánh đúng.
///
/// Trả về gesture đang giữ (chưa nhả) để test tự quyết định thả ở đâu.
Future<TestGesture> _dragBubbleTo(WidgetTester tester, Offset target) async {
  const steps = 20;
  final start = tester.getCenter(find.byType(AiChatIcon));
  final step = (target - start) / steps.toDouble();

  final gesture = await tester.startGesture(start);
  await tester.pump(const Duration(milliseconds: 16));
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(step);
    await tester.pump(const Duration(milliseconds: 16));
  }
  return gesture;
}

/// Dựng bong bóng ĐÚNG như app thật: overlay nằm trong [MaterialApp.builder],
/// tức PHÍA TRÊN Navigator nên KHÔNG có `Overlay` tổ tiên.
///
/// Đây chính là điều kiện đã làm `Tooltip` (dựng bằng OverlayPortal) throw và
/// khiến Flutter vẽ ErrorWidget đỏ. Test cũ đặt widget trong `Scaffold` —
/// tức bên trong Overlay của Navigator — nên không tái hiện được lỗi.
Future<void> _pumpBubble(WidgetTester tester, {AiFabVisibility? fab}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('vi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        return ChangeNotifierProvider.value(
          value: fab ?? AiFabVisibility(),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [child ?? const SizedBox.expand(), const FloatingAiBubble()],
          ),
        );
      },
      home: const Scaffold(body: SizedBox.expand()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
