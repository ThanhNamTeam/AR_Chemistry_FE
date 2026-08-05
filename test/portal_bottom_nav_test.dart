import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:labedu/core/l10n/app_localizations.dart';
import 'package:labedu/core/l10n/locale_provider.dart';
import 'package:labedu/presentation/home/providers/theme_provider.dart';
import 'package:labedu/presentation/shared/widgets/portal/portal_shell.dart';

/// Thanh nav portal với 7 tab (admin) từng bị Row+Expanded ép mỗi ô ~55px,
/// cắt nhãn thành "Người d...". Test khoá hành vi mới: chật thì CUỘN NGANG.
void main() {
  List<PortalNavItem> makeItems(int n) => List.generate(
    n,
    (i) => PortalNavItem(
      icon: Icons.circle_outlined,
      activeIcon: Icons.circle,
      label: i == 6 ? 'Người dùng' : 'Tab $i',
    ),
  );

  Widget host({required int count, required double width}) {
    SharedPreferences.setMockInitialValues({});
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: MaterialApp(
        // Header portal giờ dùng AppLocalizations (nhãn Semantics P2-8) —
        // harness phải có delegates như app thật, thiếu sẽ _TypeError.
        locale: const Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: PortalShell(
                portalTitle: 'Admin',
                roleBadge: 'ADMIN',
                userEmail: 'a@b.c',
                selectedIndex: count - 1, // chọn tab cuối — phải tự cuộn tới
                onTabSelected: (_) {},
                navItems: makeItems(count),
                pages: List.generate(count, (_) => const SizedBox()),
                onProfile: () {},
                onLogout: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('7 tab / màn hẹp: không overflow, nav cuộn được', (tester) async {
    // Ép CẢ MÀN HÌNH về 360px — SizedBox giữa khung 800px mặc định làm toạ
    // độ toàn cục lệch, assert vùng nhìn thấy sẽ sai.
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(count: 7, width: 360));
    await tester.pumpAndSettle();

    // Không có lỗi overflow (RenderFlex overflowed sẽ ném qua takeException).
    expect(tester.takeException(), isNull);

    // Ở chế độ chật phải có scroll ngang trong thanh nav.
    expect(
      find.descendant(
        of: find.byType(PortalShell),
        matching: find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
      ),
      findsOneWidget,
    );

    // Tab cuối đang chọn phải được cuộn vào vùng nhìn thấy.
    expect(find.text('Người dùng'), findsOneWidget);
    final box = tester.getRect(find.text('Người dùng'));
    expect(box.left, greaterThanOrEqualTo(0));
    expect(box.right, lessThanOrEqualTo(360));
  });

  testWidgets('ít tab: vẫn dàn đều, KHÔNG cuộn (giữ hành vi staff cũ)', (
    tester,
  ) async {
    await tester.pumpWidget(host(count: 4, width: 360));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(PortalShell),
        matching: find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
      ),
      findsNothing,
    );
  });
}
