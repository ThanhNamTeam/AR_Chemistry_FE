
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labedu/presentation/ar_view/screens/ar_asset_loading_screen.dart';
import 'package:labedu/presentation/feedback/screens/my_feedbacks_screen.dart';
import 'package:labedu/presentation/home/screens/my_single_cards_screen.dart';
import 'package:labedu/presentation/inventory/screens/substance_detail_screen.dart';
import 'package:labedu/presentation/quiz/providers/student_quiz_provider.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';

import 'core/utils/app_snackbar.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import 'amplifyconfiguration.dart';

import 'core/config/env_config.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_provider.dart';
import 'presentation/admin/providers/admin_provider.dart';
import 'presentation/admin/screens/admin_home_screen.dart';
import 'presentation/auth/providers/role_session_provider.dart';
import 'presentation/home/providers/app_state.dart';
import 'presentation/home/providers/home_provider.dart';
import 'presentation/home/providers/theme_provider.dart';
import 'presentation/staff/providers/staff_provider.dart';
import 'presentation/staff/screens/staff_home_screen.dart';
import 'presentation/shared/screens/portal_profile_screen.dart';
import 'shared/styles/app_colors.dart';
import 'routes/app_routes.dart';
import 'core/navigation/app_navigator.dart';

// Screens
import 'presentation/auth/screens/onboarding_screen.dart';
import 'presentation/auth/screens/login_screen.dart';
import 'presentation/auth/screens/verify_otp_screen.dart';
import 'presentation/auth/screens/complete_profile_screen.dart';
import 'presentation/auth/screens/forgot_password_screen.dart';
import 'presentation/home/screens/home_screen.dart';
import 'presentation/packages/package_screen.dart';
import 'presentation/home/screens/profile_screen.dart';
import 'presentation/inventory/screens/library_screen.dart';
import 'presentation/inventory/screens/my_bag_screen.dart';
import 'presentation/ar_view/screens/scan_screen.dart';
import 'presentation/ar_view/screens/result_screen.dart';
import 'presentation/ar_view/widgets/ar_camera_view.dart';
import 'presentation/payment/screens/shop_screen.dart';
import 'presentation/payment/screens/cart_screen.dart';
import 'presentation/payment/screens/payment_page.dart';
import 'presentation/payment/screens/payment_success_screen.dart';
import 'presentation/feedback/screens/feedback_screen.dart';
import 'presentation/ai_chat/providers/ai_fab_visibility.dart';
import 'presentation/ai_chat/providers/chat_provider.dart';
import 'presentation/ai_chat/screens/ai_chat_screen.dart';
import 'presentation/shared/widgets/user_portal_ai_overlay.dart';
import 'presentation/mini_game/screens/mini_game_screen.dart';
import 'core/storage/experiment_progress_storage.dart';
import 'presentation/reaction_experiment/providers/reaction_experiment_session_provider.dart';
import 'presentation/reaction_experiment/screens/grade_selection_screen.dart';
import 'presentation/reaction_experiment/screens/reaction_category_screen.dart';
import 'presentation/reaction_experiment/screens/reaction_list_screen.dart';
import 'presentation/reaction_experiment/screens/reaction_experiment_hub_screen.dart';
import 'presentation/reaction_experiment/screens/reaction_experiment_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.instance.init();
  await EnvConfig.load();
  await _configureAmplify();

  AppColors.applyTheme(
    primaryColor: const Color(0xFF06B6D4),
    accentColor: const Color(0xFF3B82F6),
    light: false,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ARChemistryApp());
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());

    await Amplify.configure(amplifyconfig);

  } catch (e) {
    debugPrint('Amplify configure failed: $e');
  }
}

class ARChemistryApp extends StatefulWidget {
  const ARChemistryApp({super.key});

  @override
  State<ARChemistryApp> createState() => _ARChemistryAppState();
}

class _ARChemistryAppState extends State<ARChemistryApp> {
  final _navigatorKey = AppNavigator.key;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadThemes()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadLocales()),
        ChangeNotifierProvider(create: (_) => RoleSessionProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AiFabVisibility()),
        ChangeNotifierProvider(create: (_) => StudentQuizProvider()),
        ChangeNotifierProvider(
          create: (_) => StudentQuizProvider(),
        ),
        ChangeNotifierProxyProvider<
            StudentQuizProvider,
            ReactionExperimentSessionProvider>(
          create: (context) => ReactionExperimentSessionProvider(
            ExperimentProgressStorage(),
            context.read<StudentQuizProvider>(),
          )..loadProgress(),
          update: (
              context,
              studentQuizProvider,
              previous,
              ) {
            return previous ??
                ReactionExperimentSessionProvider(
                  ExperimentProgressStorage(),
                  studentQuizProvider,
                )..loadProgress();
          },
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            navigatorKey: _navigatorKey,
            title: 'AR Chemistry Lab',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: themeProvider.buildThemeData(),
            navigatorObservers: [appRouteObserver],
            initialRoute: AppRoutes.onboarding,
            routes: _buildRoutes(),
            onGenerateRoute: _onGenerateRoute,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ARUnityHost(
                    child: UserPortalAiOverlay(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),

                  const AppToastOverlay(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      AppRoutes.onboarding: (_) => const OnboardingScreen(),
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.completeProfile: (_) => const RegistrationScreen(),
      AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
      AppRoutes.verifyOtp: (_) => const VerifyOtpScreen(),
      AppRoutes.home: (_) => const HomeScreen(),
      AppRoutes.profile: (_) => const ProfileScreen(),
      AppRoutes.feedback: (_) => const FeedbackScreen(),
      AppRoutes.aiChat: (_) => const AiChatScreen(),
      AppRoutes.library: (_) => const LibraryScreen(),
      AppRoutes.myBag: (_) => const MyBagScreen(),
      AppRoutes.scan: (_) => const ScanScreen(),
      AppRoutes.shop: (_) => const ShopScreen(),
      AppRoutes.packages: (_) => const PackageScreen(),
      AppRoutes.cart: (_) => const CartScreen(),
      AppRoutes.payment: (_) => const PaymentPage(),
      AppRoutes.paymentSuccess: (_) => const PaymentSuccessScreen(),
      AppRoutes.staffHome: (_) => const StaffHomeScreen(),
      AppRoutes.adminHome: (_) => const AdminHomeScreen(),
      AppRoutes.portalProfile: (_) => const PortalProfileScreen(),
      AppRoutes.miniGame: (_) => const MiniGameScreen(),
      AppRoutes.mySingleCards: (_) => const MySingleCardsScreen(),
      AppRoutes.myFeedbacks: (_) => const MyFeedbacksScreen(),
      AppRoutes.arAssetLoading: (_) => const ArAssetLoadingScreen(),
      AppRoutes.gradeSelection: (_) => const GradeSelectionScreen(),
      AppRoutes.reactionCategory: (_) => const ReactionCategoryScreen(),
      AppRoutes.reactionList: (_) => const ReactionListScreen(),
      AppRoutes.reactionExperimentHub: (_) =>
          const ReactionExperimentHubScreen(),
      AppRoutes.reactionExperimentHistory: (_) =>
          const ReactionExperimentHistoryScreen(),
    };
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.result) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const ResultScreen(),
      );
    }

    if (settings.name == AppRoutes.substanceDetail) {
      final substanceId = settings.arguments as String;

      return MaterialPageRoute(
        settings: settings,
        builder: (_) => SubstanceDetailScreen(substanceId: substanceId),
      );
    }

    return null;
  }
}
