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

  // admin logs (ELK)
  static String adminLogsUrl({
    String? level,
    String? q,
    int minutes = 1440,
    int page = 0,
    int size = 50,
  }) {
    return Uri.parse('$baseUrl/admin/logs').replace(
      queryParameters: {
        if (level != null && level.isNotEmpty && level != 'ALL') 'level': level,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        'minutes': minutes.toString(),
        'page': page.toString(),
        'size': size.toString(),
      },
    ).toString();
  }

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
    // Contract mới: kết quả nằm ở /result (URL cũ không có suffix đã bị xoá).
    return '$baseUrl$studentPath/quiz-attempts/$attemptCode/result';
  }

  // ---- Luồng quiz theo PHẢN ỨNG (contract mới, thay cho quiz theo bài học) ----

  static String studentReactionsUrl({
    required int grade,
    required String reactionCategory,
    String keyword = '',
    int page = 0,
    int size = 10,
  }) {
    return Uri.parse('$baseUrl$studentPath/reactions').replace(
      queryParameters: {
        'grade': '$grade',
        'reactionCategory': reactionCategory,
        if (keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
        'page': '$page',
        'size': '$size',
      },
    ).toString();
  }

  static String studentStartAttemptUrl(String reactionId) =>
      '$baseUrl$studentPath/reactions/$reactionId/attempts';

  static String studentReactionHistoryUrl(
    String reactionId, {
    int page = 0,
    int size = 10,
  }) {
    return Uri.parse(
      '$baseUrl$studentPath/reactions/$reactionId/attempt-history',
    ).replace(queryParameters: {'page': '$page', 'size': '$size'}).toString();
  }

  static String studentAttemptStateUrl(String attemptCode) =>
      '$baseUrl$studentPath/quiz-attempts/$attemptCode/state';

  static String studentAttemptContentUrl(String attemptCode) =>
      '$baseUrl$studentPath/quiz-attempts/$attemptCode/content';

  static String studentCompleteArUrl(String attemptCode) =>
      '$baseUrl$studentPath/quiz-attempts/$attemptCode/complete-ar';

  static String studentSaveAnswerUrl(String attemptCode, String questionId) =>
      '$baseUrl$studentPath/quiz-attempts/$attemptCode/answers/$questionId';

  static String studentSubmitAttemptUrl(String attemptCode) =>
      '$baseUrl$studentPath/quiz-attempts/$attemptCode/submit';

  static String studentAbandonAttemptUrl(String attemptCode) =>
      '$baseUrl$studentPath/quiz-attempts/$attemptCode/abandon';

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

  /// Danh sách phản ứng đang bật (có phương trình) — nguồn cho thẻ ôn dạng
  /// "chất tham gia → ?".
  static String reactionsListUrl({int page = 0, int size = 100}) {
    return Uri.parse('$baseUrl/reactions').replace(queryParameters: {
      'active': 'true',
      'page': page.toString(),
      'size': size.toString(),
    }).toString();
  }

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
  static String aiMessageRatingUrl(String messageId) =>
      '$baseUrl$aiPath/messages/$messageId/rating';

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

  // admin users
  static const String adminUsersPath = '/admin/users';

  static String adminUsersUrl({int page = 0, int size = 20}) {
    return Uri.parse('$baseUrl$adminUsersPath')
        .replace(queryParameters: {'page': '$page', 'size': '$size'})
        .toString();
  }

  static String adminUserUrl(String id) => '$baseUrl$adminUsersPath/$id';

  static String adminUserStatusUrl(String id) =>
      '$baseUrl$adminUsersPath/$id/status';

  static String adminUserRolesUrl(String id) =>
      '$baseUrl$adminUsersPath/$id/roles';

  static String adminUserResetPasswordUrl(String id) =>
      '$baseUrl$adminUsersPath/$id/reset-password';

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