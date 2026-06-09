class ApiConstants {
  /// Backend base URL — truyền bằng dart-define:
  /// --dart-define=API_BASE_URL=http://192.168.1.13:8080/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://172.18.193.225:8080/api/v1',
  );

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
  static const String singleCardsUrl = '$baseUrl/single-cards';

  static const String fakeBuySingleCardUrl =
      '$baseUrl/single-card-purchases/fake-buy';

  static const String mySingleCardPurchasesUrl =
      '$baseUrl/single-card-purchases/my';

  /// Khi chưa cấu hình BE, lưu feedback cục bộ.
  static bool get useLocalFallback => baseUrl.contains('example.com');
}