import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'presentation/home/providers/app_state.dart';
import 'presentation/home/providers/home_provider.dart';
import 'routes/app_routes.dart';

import 'domain/models/account_setup_model.dart';
// Screens
import 'presentation/auth/screens/onboarding_screen.dart';
import 'presentation/auth/screens/login_screen.dart';
import 'presentation/auth/screens/complete_profile_screen.dart';
import 'presentation/home/screens/home_screen.dart';
import 'presentation/home/screens/profile_screen.dart';
import 'presentation/inventory/screens/library_screen.dart';
import 'presentation/inventory/screens/my_bag_screen.dart';
import 'presentation/ar_view/screens/scan_screen.dart';
import 'presentation/ar_view/screens/result_screen.dart';
import 'presentation/payment/screens/shop_screen.dart';
import 'presentation/payment/screens/cart_screen.dart';
import 'presentation/payment/screens/payment_success_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ARChemistryApp());
}

class ARChemistryApp extends StatelessWidget {
  const ARChemistryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MaterialApp(
        title: 'AR Chemistry Lab',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: AppRoutes.onboarding,
        routes: _buildRoutes(),
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF06B6D4),
        secondary: Color(0xFF10B981),
        surface: Color(0xFF0F172A),
        background: Color(0xFF020817),
      ),
      scaffoldBackgroundColor: const Color(0xFF020817),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF020817),
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      AppRoutes.onboarding: (_) => const OnboardingScreen(),
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.completeProfile: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final setupArgs = args is AccountSetupRouteArgs
            ? args
            : AccountSetupRouteArgs.registration();
        return CompleteProfileScreen(args: setupArgs);
      },
      AppRoutes.home: (_) => const HomeScreen(),
      AppRoutes.profile: (_) => const ProfileScreen(),
      AppRoutes.library: (_) => const LibraryScreen(),
      AppRoutes.myBag: (_) => const MyBagScreen(),
      AppRoutes.scan: (_) => const ScanScreen(),
      AppRoutes.shop: (_) => const ShopScreen(),
      AppRoutes.cart: (_) => const CartScreen(),
      AppRoutes.paymentSuccess: (_) => const PaymentSuccessScreen(),
    };
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.result) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const ResultScreen(),
      );
    }
    return null;
  }
}
