import '../config/env_config.dart';

class ApiConstants {
  /// Backend base URL — cấu hình trong `.env` hoặc `--dart-define=API_BASE_URL=...`
  static String get baseUrl => EnvConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 8);

  // paths
  static const String feedbackPath = '/feedbacks';
  static const String aiPath = '/ai';
  static const String chemicalCardsShopPath = '/chemical-cards';
  static const String cardBundlesShopPath = '/card-bundles';

  // staff quiz management
  static const String staffQuizManagementPath = '/staff/quiz-management';
  static const String staffQuizImportPath = '/staff/quiz-import';

  //staff quiz attempt
  static const String staffQuizAttemptsPath = '/staff/quiz-attempts';

  static String staffQuizAttemptsUrl({
    int page = 0,
    int size = 10,
  }) {
    final uri = Uri.parse('$baseUrl$staffQuizAttemptsPath').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    return uri.toString();
  }

  static String staffQuizAttemptDetailUrl(String attemptCode) {
    return '$baseUrl$staffQuizAttemptsPath/$attemptCode';
  }

  //student
  static const String studentPath = '/student';

  static String studentPublishedQuizByLessonUrl(String lessonCode) {
    return '$baseUrl$studentPath/lessons/$lessonCode/quiz';
  }

  static String studentQuizQuestionsUrl(String quizCode) {
    return '$baseUrl$studentPath/quizzes/$quizCode/questions';
  }

  static String studentSubmitQuizUrl(String quizCode) {
    return '$baseUrl$studentPath/quizzes/$quizCode/submit';
  }

  static String get studentPublishedQuizzesUrl {
    return '$baseUrl$studentPath/quizzes/published';
  }

  //access ar
  static const String mePath = '/users';

  static String get myArAccessUrl {
    return '$baseUrl$mePath/ar-access';
  }

  // fake payment
  static const String devFakePurchasePath = '/dev/fake-purchase';

  static String get fakePurchaseAr30DaysUrl {
    return '$baseUrl$devFakePurchasePath/ar-30-days';
  }

  // inventory
  static const String inventoryPath = '/inventory';

  static String inventorySubstanceDetailUrl(String substanceId) {
    return '$baseUrl$inventoryPath/substances/$substanceId/detail';
  }

  static String get activateKitUrl {
    return '$baseUrl$inventoryPath/activate-kit';
  }

  static String inventoryMeUrl({
    int page = 0,
    int size = 20,
  }) {
    final uri = Uri.parse('$baseUrl$inventoryPath/me').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sort': 'acquiredAt,desc',
      },
    );

    return uri.toString();
  }

  static String studentQuizAttemptsUrl({
    String? quizCode,
    int page = 0,
    int size = 10,
  }) {
    final uri = Uri.parse('$baseUrl$studentPath/quiz-attempts').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        if (quizCode != null && quizCode.isNotEmpty) 'quizCode': quizCode,
      },
    );

    return uri.toString();
  }

  static String studentQuizAttemptDetailUrl(String attemptCode) {
    return '$baseUrl$studentPath/quiz-attempts/$attemptCode';
  }

  // library
  static const String libraryPath = '/library';

  static String libraryCardsUrl({
    int page = 0,
    int size = 30,
  }) {
    final uri = Uri.parse('$baseUrl$libraryPath/cards').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sort': 'formula,asc',
      },
    );

    return uri.toString();
  }

  static String get librarySummaryUrl {
    return '$baseUrl$libraryPath/summary';
  }

// reactions
  static const String reactionsPath = '/reactions/definitions';

  static String get reactionSummaryUrl {
    return '$baseUrl$reactionsPath/summary';
  }

  // feedbacks
  static String get feedbackUrl => '$baseUrl$feedbackPath';

  // AI
  static String get aiChatUrl => '$baseUrl$aiPath/chat';
  static String get aiConversationsUrl => '$baseUrl$aiPath/conversations';

  static String aiConversationDetailUrl(String id) {
    return '$baseUrl$aiPath/conversations/$id';
  }

  // cards
  static String get chemicalCardsShopUrl => '$baseUrl$chemicalCardsShopPath';

  // staff quiz management
  static String get staffQuizOverviewUrl {
    return '$baseUrl$staffQuizManagementPath/lessons';
  }

  static String staffLessonQuizzesUrl(String lessonCode) {
    return '$baseUrl$staffQuizManagementPath/lessons/$lessonCode/quizzes';
  }

  static String staffQuizQuestionsUrl(String quizCode) {
    return '$baseUrl$staffQuizManagementPath/quizzes/$quizCode/questions';
  }

  // quiz import
  static String get staffQuizImportStartUrl {
    return '$baseUrl$staffQuizImportPath/start';
  }

  static String staffLessonContentUrl(String lessonCode) {
    return '$baseUrl$staffQuizManagementPath/content/$lessonCode';
  }

  static String staffQuizPublishUrl(String quizCode) {
    return '$baseUrl$staffQuizManagementPath/quizzes/$quizCode/publish';
  }

  // single-cards
  static final String singleCardsUrl = '$baseUrl/single-cards';

  static String fakeBuySingleCardUrl =
      '$baseUrl/single-card-purchases/fake-buy';

  static String mySingleCardPurchasesUrl =
      '$baseUrl/single-card-purchases/my';

  // admin substances
  static const String adminSubstancesPath = '/substances';

  static String adminSubstancesUrl({
    int page = 0,
    int size = 200,
    String sort = 'formula,asc',
    bool? active,
    String? chemicalGroup,
    String? type,
    bool? includedInFullKit,
  }) {
    final uri = Uri.parse('$baseUrl$adminSubstancesPath').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sort': sort,
        if (active != null) 'active': active.toString(),
        if (chemicalGroup != null && chemicalGroup.isNotEmpty)
          'chemicalGroup': chemicalGroup,
        if (type != null && type.isNotEmpty) 'type': type,
        if (includedInFullKit != null)
          'includedInFullKit': includedInFullKit.toString(),
      },
    );

    return uri.toString();
  }

  static String adminSubstanceActiveUrl(String id) {
    return '$baseUrl$adminSubstancesPath/$id/active';
  }

  static String adminSubstanceIncludedInFullKitUrl(String id) {
    return '$baseUrl$adminSubstancesPath/$id/included-in-full-kit';
  }

  static String adminSubstanceDetailUrl(String id) {
    return '$baseUrl$adminSubstancesPath/$id';
  }

  static String adminSubstanceByFormulaUrl(String formula) {
    return '$baseUrl$adminSubstancesPath/formula/$formula';
  }

  static String get createAdminSubstanceUrl {
    return '$baseUrl$adminSubstancesPath';
  }

  //Kits
  static const String adminKitsPath = '/kits';

  static String get adminKitsUrl {
    return '$baseUrl$adminKitsPath';
  }

  static String adminKitDetailUrl(String id) {
    return '$baseUrl$adminKitsPath/$id';
  }

  //generate activation code
  static const String activationCodesPath = '/activation-codes';

  static String get generateActivationCodesUrl {
    return '$baseUrl$activationCodesPath/generate';
  }

  static String activationCodesUrl({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,asc',
    String? kitId,
    String? status,
    String? usedByUserId,
  }) {
    final uri = Uri.parse('$baseUrl$activationCodesPath').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sort': sort,
        if (kitId != null && kitId.isNotEmpty) 'kitId': kitId,
        if (status != null && status.isNotEmpty) 'status': status,
        if (usedByUserId != null && usedByUserId.isNotEmpty)
          'usedByUserId': usedByUserId,
      },
    );

    return uri.toString();
  }

  static String activationCodeByCodeUrl(String code) {
    return '$baseUrl$activationCodesPath/code/$code';
  }

  static String kitByCodeUrl(String code) {
    return '$baseUrl$adminKitsPath/code/$code';
  }

  static String activationCodeStatusUrl(String id) {
    return '$baseUrl$activationCodesPath/$id/status';
  }

  // admin reactions
  static const String adminReactionsPath = '/admin';

  static String adminReactionsUrl({
    int page = 0,
    int size = 20,
    String sort = 'code,asc',
    bool? active,
  }) {
    final uri = Uri.parse('$baseUrl/reactions').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sort': sort,
        if (active != null) 'active': active.toString(),
      },
    );

    return uri.toString();
  }

  static String get createAdminReactionUrl {
    return '$baseUrl$adminReactionsPath/reactions';
  }

  static String adminReactionActiveUrl(String id) {
    return '$baseUrl$adminReactionsPath/reactions/$id/active';
  }




  /// Khi chưa cấu hình BE, lưu feedback cục bộ.
  static bool get useLocalFallback => baseUrl.contains('example.com');
}