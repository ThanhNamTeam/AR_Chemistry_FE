import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../presentation/home/providers/theme_provider.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = [
    Locale('en'),
    Locale('vi'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      [
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isVi => locale.languageCode == 'vi';

  // —— Profile common ——
  String get profile => isVi ? 'Hồ sơ' : 'Profile';
  String get appTheme => isVi ? 'Giao diện ứng dụng' : 'App Theme';
  String get language => isVi ? 'Ngôn ngữ' : 'Language';
  String get english => 'English';
  String get vietnamese => 'Tiếng Việt';
  String get updateProfile =>
      isVi ? 'Cập nhật thông tin' : 'Update profile';
  String get tapAvatarHint =>
      isVi ? 'Chạm ảnh để đổi avatar' : 'Tap photo to change avatar';
  String get logout => isVi ? 'Đăng xuất' : 'Logout';
  String get avatarUpdated =>
      isVi ? 'Cập nhật ảnh đại diện thành công!' : 'Avatar updated successfully!';
  String get cannotOpenGallery =>
      isVi ? 'Không thể mở thư viện ảnh.' : 'Cannot open photo library.';

  // —— User profile ——
  String get cardsUnlocked => isVi ? 'Thẻ đã mở' : 'Cards Unlocked';
  String get experiments => isVi ? 'Thí nghiệm' : 'Experiments';
  String get libraryProgress =>
      isVi ? 'Tiến độ thư viện' : 'Library Progress';
  String get myLibrary => isVi ? 'Thư viện của tôi' : 'My Library';
  String cardsUnlockedSubtitle(int count) => isVi
      ? '$count thẻ đã mở khóa'
      : '$count cards unlocked';
  String get myBag => isVi ? 'Túi đồ' : 'My Bag';
  String get myBagSubtitle =>
      isVi ? 'Xem thẻ đã mua' : 'View your purchased cards';
  String get shop => isVi ? 'Cửa hàng' : 'Shop';
  String get shopSubtitle =>
      isVi ? 'Mua thẻ hóa học mới' : 'Buy new chemical cards';
  String get arScanner => isVi ? 'Quét AR' : 'AR Scanner';
  String get arScannerSubtitle =>
      isVi ? 'Quét thẻ hóa học của bạn' : 'Scan your chemical cards';
  String get feedback => isVi ? 'Phản hồi' : 'Feedback';
  String get feedbackSubtitle => isVi
      ? 'Báo lỗi hoặc chia sẻ trải nghiệm'
      : 'Report bugs or share your experience';

  // —— Portal profile ——
  String get roleStaff => isVi ? 'Nhân viên' : 'Staff';
  String get roleAdmin => isVi ? 'Quản trị' : 'Admin';
  String get manageFeedback =>
      isVi ? 'Quản lý Feedback' : 'Manage Feedback';
  String get manageFeedbackSubtitle => isVi
      ? 'Xem và phản hồi người dùng'
      : 'View and respond to users';
  String get quizPipeline => isVi ? 'Quiz pipeline' : 'Quiz pipeline';
  String get quizPipelineSubtitle => isVi
      ? 'Upload tài liệu & duyệt quiz'
      : 'Upload documents & approve quizzes';
  String get dashboard => isVi ? 'Bảng điều khiển' : 'Dashboard';
  String get dashboardSubtitle => isVi
      ? 'Thống kê & doanh thu hệ thống'
      : 'System stats & revenue';
  String get manageCatalog =>
      isVi ? 'Quản lý chất & combo' : 'Chemicals & combos';
  String get manageCatalogSubtitle => isVi
      ? 'Shop, phản ứng, top sales'
      : 'Shop, reactions, top sales';
  String get pendingQuizzes =>
      isVi ? 'Quiz chờ duyệt' : 'Pending quizzes';
  String get chemicals => isVi ? 'Chất' : 'Chemicals';
  String get users => isVi ? 'Người dùng' : 'Users';

  // —— Portal shell ——
  String get staffPortal => isVi ? 'Staff Portal' : 'Staff Portal';
  String get adminPortal => isVi ? 'Admin Portal' : 'Admin Portal';
  String get navOverview => isVi ? 'Tổng quan' : 'Overview';
  String get navChemicals => isVi ? 'Chất' : 'Chemicals';
  String get navReactions => isVi ? 'PTHH' : 'Reactions';
  String get navTopSales => isVi ? 'Top bán' : 'Top sales';
  String get navCombos => isVi ? 'Combo' : 'Combos';
  String get awaitingResponse =>
      isVi ? 'Chờ phản hồi' : 'Awaiting response';
  String get responded => isVi ? 'Đã phản hồi' : 'Responded';
  String get approvedQuizzes =>
      isVi ? 'Quiz đã duyệt' : 'Approved quizzes';
  String get feedbackTrend =>
      isVi ? 'Feedback theo tuần' : 'Weekly feedback';
  String get recentFeedback =>
      isVi ? 'Feedback gần đây' : 'Recent feedback';
  String get quickActions => isVi ? 'Thao tác nhanh' : 'Quick actions';
  String get goToFeedback =>
      isVi ? 'Xem tất cả feedback' : 'View all feedback';
  String get goToQuiz =>
      isVi ? 'Duyệt quiz pipeline' : 'Review quiz pipeline';
  String get uploadDocument =>
      isVi ? 'Upload tài liệu tạo quiz' : 'Upload document for quiz';
  String get uploadDocumentHint => isVi
      ? 'PDF, DOC, DOCX, TXT — AI sinh quiz chờ duyệt'
      : 'PDF, DOC, DOCX, TXT — AI generates quiz for review';
  String get processingDocument =>
      isVi ? 'Đang xử lý tài liệu...' : 'Processing document...';
  String get quizPipelineHint => isVi
      ? 'Quiz do AI sinh — staff duyệt trước khi lên cho người dùng'
      : 'AI-generated quizzes — staff approves before publishing';
  String get noFeedbackYet => isVi
      ? 'Chưa có feedback'
      : 'No feedback yet';
  String get noFeedbackSubtitle => isVi
      ? 'Người dùng gửi phản hồi sẽ hiện ở đây'
      : 'User submissions will appear here';
  String get statusPending => isVi ? 'Chờ duyệt' : 'Pending';
  String get statusApproved => isVi ? 'Đã duyệt' : 'Approved';
  String get statusRejected => isVi ? 'Từ chối' : 'Rejected';
  String get respondedBadge => isVi ? 'Đã phản hồi' : 'Responded';
  String get anonymous => isVi ? 'Ẩn danh' : 'Anonymous';
  String get reject => isVi ? 'Từ chối' : 'Reject';
  String get approve => isVi ? 'Duyệt' : 'Approve';
  String get activeToday => isVi ? 'Hoạt động hôm nay' : 'Active today';
  String get revenue => isVi ? 'Doanh thu' : 'Revenue';
  String get addChemical =>
      isVi ? 'Thêm chất mới' : 'Add chemical';
  String get addReaction =>
      isVi ? 'Thêm phản ứng' : 'Add reaction';
  String get createCombo =>
      isVi ? 'Tạo combo sale' : 'Create combo sale';
  String get topChemicalsPurchased =>
      isVi ? 'Top chất được mua' : 'Top purchased chemicals';
  String purchases(int n) => isVi ? '$n lượt' : '$n purchases';
  String topicLabel(String t) => isVi ? 'Chủ đề: $t' : 'Topic: $t';
  String get periodDay => isVi ? 'Ngày' : 'Day';
  String get periodWeek => isVi ? 'Tuần' : 'Week';
  String get periodMonth => isVi ? 'Tháng' : 'Month';
  String get revenueDay => isVi ? 'Doanh thu ngày' : 'Daily revenue';
  String get revenueMonth => isVi ? 'Tháng' : 'Month';

  // —— Auth flow (onboarding + login) ——
  String get appName => 'Chemistry AR';
  String get appTagline => isVi
      ? 'Học hóa học với thực tế ảo tăng cường'
      : 'Learn chemistry with augmented reality';
  String get appearanceSettings =>
      isVi ? 'Giao diện & ngôn ngữ' : 'Appearance & language';
  String get skip => isVi ? 'Bỏ qua' : 'Skip';
  String get next => isVi ? 'Tiếp theo' : 'Next';
  String get getStarted => isVi ? 'Bắt đầu' : 'Get Started';
  String get onboardingTitle1 =>
      isVi ? 'Quét thẻ hóa học' : 'Scan Chemical Cards';
  String get onboardingDesc1 => isVi
      ? 'Dùng AR để quét thẻ vật lý và xem phân tử 3D sống động'
      : 'Use AR to scan physical cards and view molecules in 3D';
  String get onboardingTitle2 =>
      isVi ? 'Xây bộ sưu tập' : 'Build Your Collection';
  String get onboardingDesc2 => isVi
      ? 'Mua thẻ tại cửa hàng, mở khóa nguyên tố và hợp chất mới'
      : 'Buy cards from the shop and unlock new elements and compounds';
  String get onboardingTitle3 =>
      isVi ? 'Thí nghiệm ảo' : 'Run Virtual Experiments';
  String get onboardingDesc3 => isVi
      ? 'Kết hợp chất trong AR, xem phản ứng và tích điểm kiến thức'
      : 'Combine chemicals in AR, trigger reactions and earn knowledge points';
  String get emailLabel => 'Email';
  String get emailHint => isVi ? 'Nhập email' : 'Enter your email';
  String get passwordLabel => isVi ? 'Mật khẩu' : 'Password';
  String get passwordHint =>
      isVi ? 'Nhập mật khẩu' : 'Enter your password';
  String get loginButton => isVi ? 'Đăng nhập' : 'Login';
  String get orContinueWith =>
      isVi ? 'Hoặc tiếp tục với' : 'Or continue with';
  String get continueWithGoogle =>
      isVi ? 'Tiếp tục với Google' : 'Continue with Google';
  String get noAccount => isVi ? 'Chưa có tài khoản? ' : "Don't have an account? ";
  String get signUp => isVi ? 'Đăng ký' : 'Sign Up';
  String get emailRequired =>
      isVi ? 'Vui lòng nhập email' : 'Email is required';
  String get passwordRequired =>
      isVi ? 'Vui lòng nhập mật khẩu' : 'Password is required';
  String get registrationSuccessLogin => isVi
      ? 'Đăng ký thành công! Vui lòng đăng nhập.'
      : 'Registration successful! Please sign in.';

  String themeName(AppThemeKey key) {
    switch (key) {
      case AppThemeKey.dark:
        return isVi ? 'Tối Cyber' : 'Dark Cyber';
      case AppThemeKey.light:
        return isVi ? 'Sáng' : 'Light Mode';
      case AppThemeKey.ocean:
        return isVi ? 'Đại dương' : 'Ocean Blue';
      case AppThemeKey.galaxy:
        return isVi ? 'Thiên hà' : 'Purple Galaxy';
      case AppThemeKey.forest:
        return isVi ? 'Rừng xanh' : 'Green Forest';
    }
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
