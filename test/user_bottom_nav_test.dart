import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:labedu/core/l10n/app_localizations.dart';
import 'package:labedu/core/navigation/app_navigator.dart';
import 'package:labedu/presentation/shared/widgets/user_bottom_nav.dart';
import 'package:labedu/domain/models/app_portal.dart';
import 'package:labedu/presentation/home/providers/theme_provider.dart';
import 'package:labedu/routes/app_routes.dart';

/// Dựng thanh nav ĐÚNG như app thật: trong `MaterialApp.builder`, tức
/// - nằm TRÊN Navigator  -> `Navigator.of(context)` sẽ ném exception
/// - nằm NGOÀI Material  -> Text bị gạch chân vàng cảnh báo
///
/// Cả hai lỗi này đều đã xảy ra trên thiết bị thật; test dưới đây khoá lại.
void main() {
  testWidgets('bấm nav KHÔNG ném "context does not include a Navigator"', (
    tester,
  ) async {
    await _pumpNav(tester);

    await tester.tap(find.byIcon(Icons.store_outlined));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('chữ trong nav KHÔNG bị gạch chân (phải có Material tổ tiên)', (
    tester,
  ) async {
    await _pumpNav(tester);

    // Có Material bao ngoài thì Text mới không rơi vào style debug gạch vàng.
    expect(
      find.ancestor(
        of: find.byType(InkWell).first,
        matching: find.byType(Material),
      ),
      findsWidgets,
    );

    // Chỉ xét nhãn BÊN TRONG thanh nav, không xét Text của các route khác.
    final navLabels = tester.widgetList<Text>(
      find.descendant(
        of: find.byType(UserBottomNav),
        matching: find.byType(Text),
      ),
    );
    expect(navLabels, isNotEmpty);
    for (final text in navLabels) {
      expect(text.style?.decoration, TextDecoration.none);
    }
  });

  testWidgets('đang ở đúng trang đó thì không push trùng', (tester) async {
    await _pumpNav(tester);
    AppNavigator.pushNamed(AppRoutes.shop);
    await tester.pumpAndSettle();

    final before = AppNavigator.state!.canPop();
    await tester.tap(find.byIcon(Icons.store_outlined));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(AppNavigator.state!.canPop(), before);
  });

  testWidgets('đổi theme thì màu thanh nav đổi theo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final theme = ThemeProvider();
    await theme.setActivePortal(AppPortal.user);
    await theme.setTheme(AppThemeKey.dark);

    await _pumpNav(tester, theme: theme);

    Color navColor() => tester
        .widget<Material>(
          find
              .descendant(
                of: find.byType(UserBottomNav),
                matching: find.byType(Material),
              )
              .first,
        )
        .color!;

    final darkColor = navColor();

    await theme.setTheme(AppThemeKey.light);
    await tester.pumpAndSettle();

    // Nếu thanh nav bị `const` (không rebuild) thì màu sẽ giữ nguyên -> fail.
    expect(navColor(), isNot(darkColor));
    expect(navColor(), Colors.white);
  });

  testWidgets('nav có Trang chủ và KHÔNG còn Thư viện', (tester) async {
    await _pumpNav(tester);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsNothing);
  });

  testWidgets('bấm Trang chủ dọn stack, không chồng nhiều Home', (
    tester,
  ) async {
    await _pumpNav(tester);

    // Đi lòng vòng vài trang cho stack sâu lên.
    AppNavigator.pushNamed(AppRoutes.shop);
    await tester.pumpAndSettle();
    AppNavigator.pushNamed(AppRoutes.quizList);
    await tester.pumpAndSettle();
    expect(AppNavigator.state!.canPop(), isTrue);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('home'), findsOneWidget);
    // Stack đã được dọn: không còn gì để pop.
    expect(AppNavigator.state!.canPop(), isFalse);
  });
}

Future<void> _pumpNav(WidgetTester tester, {ThemeProvider? theme}) async {
  // UserBottomNav watch ThemeProvider (để rebuild khi đổi theme) nên MỌI test
  // đều phải có provider, nếu không sẽ ném ProviderNotFoundException.
  SharedPreferences.setMockInitialValues({});
  final themeProvider = theme ?? ThemeProvider();
  final app = MaterialApp(
      navigatorKey: AppNavigator.key,
      locale: const Locale('vi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routes: {
        AppRoutes.home: (_) => const Scaffold(body: Text('home')),
        AppRoutes.shop: (_) => const Scaffold(body: Text('shop')),
        AppRoutes.library: (_) => const Scaffold(body: Text('library')),
        AppRoutes.quizList: (_) => const Scaffold(body: Text('quiz')),
        AppRoutes.miniGame: (_) => const Scaffold(body: Text('game')),
      },
      initialRoute: AppRoutes.home,
      builder: (context, child) => Column(
        children: [
          Expanded(child: child ?? const SizedBox.expand()),
          UserBottomNav(),
        ],
      ),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: app,
    ),
  );
  await tester.pumpAndSettle();
}
