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
  static const String staffReactionsPath = '/staff/reactions';

  static String staffReactionQuizOverviewUrl({
    int page = 0,
    int size = 10,
  }) {
    final uri = Uri.parse(
      '$baseUrl$staffQuizManagementPath/reactions',
    ).replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    return uri.toString();
  }

  static String staffReactionQuizzesUrl({
    required String reactionCode,
    int page = 0,
    int size = 10,
  }) {
    final uri = Uri.parse(
      '$baseUrl$staffQuizManagementPath/reactions/$reactionCode/quizzes',
    ).replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    return uri.toString();
  }

  static String staffQuizDetailUrl({
    required String quizCode,
    int page = 0,
    int size = 10,
  }) {
    final uri = Uri.parse(
      '$baseUrl$staffQuizManagementPath/quizzes/$quizCode',
    ).replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    return uri.toString();
  }

  static String staffReactionQuizPromptUrl(String reactionCode) {
    return '$baseUrl$staffReactionsPath/$reactionCode/quiz-prompt';
  }

  static String get staffQuizImportUploadUrl {
    return '$baseUrl$staffQuizImportPath/upload-url';
  }

  static String get staffQuizImportStartUrl {
    return '$baseUrl$staffQuizImportPath/start';
  }

  static String staffQuizPublishUrl(String quizCode) {
    return '$baseUrl$staffQuizManagementPath/quizzes/$quizCode/publish';
  }

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

  static const String studentPath = '/student';

  static String studentReactionsUrl({
    required int grade,
    required String reactionCategory,
    String? keyword,
    int page = 0,
    int size = 10,
  }) {
    final uri = Uri.parse('$baseUrl$studentPath/reactions').replace(
      queryParameters: {
        'grade': grade.toString(),
        'reactionCategory': reactionCategory,
        if (keyword != null && keyword.trim().isNotEmpty)
          'keyword': keyword.trim(),
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    return uri.toString();
  }

  static String studentReactionDetailUrl(String reactionId) {
    return '$baseUrl$studentPath/reactions/$reactionId';
  }

  static String studentPublishedQuizByReactionUrl(String reactionId) {
    return '$baseUrl$studentPath/reactions/$reactionId/quiz';
  }

  static String studentStartAttemptUrl(String reactionId) {
    return '$baseUrl$studentPath/reactions/$reactionId/attempts';
  }

  static String studentCompleteArUrl(String attemptCode) {
    return '$baseUrl$studentPath/quiz-attempts/$attemptCode/complete-ar';
  }

  static String studentAttemptStateUrl(String attemptCode) {
    return '$baseUrl$studentPath/quiz-attempts/$attemptCode/state';
  }

  static String studentQuizContentUrl(String attemptCode) {
    return '$baseUrl$studentPath/quiz-attempts/$attemptCode/content';
  }

  static String studentSaveAnswerUrl({
    required String attemptCode,
    required String questionId,
  }) {
    return '$baseUrl$studentPath/quiz-attempts/'
        '$attemptCode/answers/$questionId';
  }

  static String studentSubmitAttemptUrl(String attemptCode) {
    return '$baseUrl$studentPath/quiz-attempts/$attemptCode/submit';
  }

  static String studentAttemptResultUrl(String attemptCode) {
    return '$baseUrl$studentPath/quiz-attempts/$attemptCode/result';
  }

  static String studentReactionHistoryUrl(
      String reactionId, {
        int page = 0,
        int size = 10,
      }) {
    final uri = Uri.parse(
      '$baseUrl$studentPath/reactions/$reactionId/attempt-history',
    ).replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    return uri.toString();
  }

  static String studentAbandonAttemptUrl(String attemptCode) {
    return '$baseUrl$studentPath/quiz-attempts/$attemptCode/abandon';
  }


  // ar assets
  static const String arAssetsPath = '/ar-assets';

  static String get latestArAssetsUrl {
    return '$baseUrl$arAssetsPath/latest';
  }

  //access ar
  static const String mePath = '/users';

  static String get myArAccessUrl {
    return '$baseUrl$mePath/ar-access';
  }

  static String get ar30DaysOwnershipUrl {
    return '$baseUrl$mePath/packages/ar-30-days/ownership';
  }

  // fake payment
  static const String devFakePurchasePath = '/dev/fake-purchase';

  static String get fakePurchaseAr30DaysUrl {
    return '$baseUrl$devFakePurchasePath/ar-30-days';
  }

  //notification
  static String get notificationTokensUrl {
    return '$baseUrl/notification-tokens';
  }


  static String get notificationTokenLogoutUrl {
    return '$baseUrl/notification-tokens/logout';
  }

  // knowledge points
  static String get knowledgePointsMeUrl {
    return '$baseUrl/knowledge-points/me';
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

  static String feedbacksUrl({
    int page = 0,
    int size = 10,
    String sort = 'createdAt,desc',
  }) {
    final uri = Uri.parse('$baseUrl$feedbackPath').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sort': sort,
      },
    );

    return uri.toString();
  }

  static String feedbackDetailUrl(String feedbackId) {
    final uri = Uri.parse('$baseUrl$feedbackPath/details').replace(
      queryParameters: {
        'feedbackId': feedbackId,
      },
    );

    return uri.toString();
  }

  static String handleFeedbackUrl(String feedbackId) {
    final uri = Uri.parse('$baseUrl$feedbackPath/handle').replace(
      queryParameters: {
        'feedbackId': feedbackId,
      },
    );

    return uri.toString();
  }

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


  static String staffLessonContentUrl(String lessonCode) {
    return '$baseUrl$staffQuizManagementPath/content/$lessonCode';
  }


  // single-cards
  static final String singleCardsUrl = '$baseUrl/single-cards';

  static String fakeBuySingleCardUrl =
      '$baseUrl/single-card-purchases/buy';

  static String mySingleCardPurchasesUrl =
      '$baseUrl/single-card-purchases/my';

  // admin chemical cards
  static const String adminChemicalCardsPath = '/chemical-cards';

  static String adminChemicalCardsUrl({
    int page = 0,
    int size = 20,
    String sort = 'cardCode,asc',
    bool? active,
    String? substanceId,
  }) {
    final uri = Uri.parse('$baseUrl$adminChemicalCardsPath').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sort': sort,
        if (active != null) 'active': active.toString(),
        if (substanceId != null && substanceId.isNotEmpty)
          'substanceId': substanceId,
      },
    );

    return uri.toString();
  }

  static String adminChemicalCardImageUploadUrl(String id) {
    return '$baseUrl$adminChemicalCardsPath/$id/images/upload-url';
  }

  static String adminChemicalCardActiveUrl(String id) {
    return '$baseUrl$adminChemicalCardsPath/$id/active';
  }

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

  static String get adminCreateKitsUrl {
    return '$baseUrl$adminKitsPath/full-kit';
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

  // google play billing
  static const String googlePlayPaymentPath = '/payments/google-play';

  static String get verifyGooglePlayPurchaseUrl {
    return '$baseUrl$googlePlayPaymentPath/verify';
  }

  // admin reactions
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
    return '$baseUrl/reactions';
  }

  static String adminReactionActiveUrl(String id) {
    return '$baseUrl/reactions/$id/active';
  }

  /// Khi chưa cấu hình BE, lưu feedback cục bộ.
  static bool get useLocalFallback => baseUrl.contains('hoaianstudio.com');
}