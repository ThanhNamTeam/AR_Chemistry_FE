import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../core/auth/cognito_password_policy.dart';
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
  String get reactionsAvailable =>
      isVi ? 'Phản ứng có thể làm' : 'Reactions available';
  String get libraryProgress =>
      isVi ? 'Tiến độ thư viện' : 'Library Progress';
  String get cardUnlockProgress =>
      isVi ? 'Tiến độ mở thẻ' : 'Card unlock progress';
  String get myLibrary => isVi ? 'Thẻ của tôi' : 'My Cards';
  String cardsUnlockedSubtitle(int count) => isVi
      ? '$count thẻ đã mở khóa'
      : '$count cards unlocked';

  // —— My Library screen ——
  String get libraryTabUnlocked => isVi ? 'Đã mở khóa' : 'Unlocked';
  String get libraryTabAllCards => isVi ? 'Tất cả thẻ' : 'All Cards';
  String get libraryNoUnlockedCards =>
      isVi ? 'Chưa có thẻ nào được mở khóa' : 'No unlocked cards yet';
  String get libraryActivateKitHint => isVi
      ? 'Kích hoạt bộ thí nghiệm để mở khóa thẻ trong thư viện'
      : 'Activate a kit to unlock cards in your library';
  String get libraryNoCardsFound =>
      isVi ? 'Không tìm thấy thẻ nào' : 'No cards found';
  String get libraryCardsAppearHere => isVi
      ? 'Thẻ thư viện sẽ hiển thị tại đây'
      : 'Library cards will appear here';
  String get cannotLoadLibrary =>
      isVi ? 'Không tải được thư viện' : 'Cannot load library';
  String get cardUnlockedLabel => isVi ? 'Đã mở khóa' : 'Unlocked';
  String get cardLockedLabel => isVi ? 'Đã khóa' : 'Locked';
  String get lockedCard => isVi ? 'Thẻ đã khóa' : 'Locked Card';
  String cardLockedSnackbar(String name) => isVi
      ? '$name đang bị khóa. Kích hoạt bộ thí nghiệm để mở khóa thẻ này.'
      : '$name is locked. Activate a kit to unlock this card.';

  String get myBag => isVi ? 'Túi đồ' : 'My Bag';
  String get myBagSubtitle =>
      isVi ? 'Xem thẻ đã mua' : 'View your purchased cards';
  String get cardPurchased => isVi ? 'Card AR đã mua' : 'AR Card purchased';
  String get cardPurchasedSubtitle => isVi ? 'Xem các card AR lẻ đã mua và tải lại QR' :
  'View your purchased individual AR cards and reload the QR code';
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
  String get navKits => isVi ? "Hộp kit" : "Kits";
  String get navActivationCode => isVi ? 'Mã kích hoạt' : 'Activation Code';
  String get navReactions => isVi ? 'PTHH' : 'Reactions';
  String get navTopSales => isVi ? 'Top bán' : 'Top sales';
  String get navRevenue => isVi ? 'Doanh thu' : 'Revenue';
  String get navCardsAr => isVi ? 'Thẻ AR' : 'AR Cards';
  String get navUsers => isVi ? 'Người dùng' : 'Users';
  String get navLogs => isVi ? 'Logs' : 'Logs';

  // —— Admin: doanh thu chuyển khoản (mock doanhthuAR) ——
  String get revenueTotal => isVi ? 'Tổng thu' : 'Total';
  String get revenueBillCount => isVi ? 'Số giao dịch' : 'Transactions';
  String get revenueEmpty =>
      isVi ? 'Chưa có giao dịch' : 'No transactions yet';
  String get revenueViewReceipt => isVi ? 'Xem biên lai' : 'View receipt';
  String get revenueReceiptMissing =>
      isVi ? 'Không tìm thấy ảnh biên lai' : 'Receipt image not found';
  String get revenueChartHint => isVi
      ? 'Biểu đồ từ bill chuyển khoản (mock)'
      : 'Chart from transfer bills (mock)';
  String get revenueColTxnId => isVi ? 'Mã giao dịch' : 'Txn ID';
  String get revenueColTime => isVi ? 'Thời gian' : 'Time';
  String get revenueColRecipient => isVi ? 'Người nhận' : 'Recipient';
  String get revenueColAccount => isVi ? 'Số TK' : 'Account';
  String get revenueColBank => isVi ? 'Ngân hàng' : 'Bank';
  String get revenueColMessage => isVi ? 'Nội dung' : 'Message';
  String get revenueNotShown => isVi ? 'Không hiển thị' : 'Not shown';
  String get periodYear => isVi ? 'Năm' : 'Year';
  String revenuePageLabel(int from, int to, int total) => isVi
      ? 'Hiển thị $from–$to / $total giao dịch'
      : 'Showing $from–$to of $total';
  /// Nhãn trục biểu đồ theo tháng (tránh hardcode "T8").
  String revenueMonthAxisLabel(int month, int year) => isVi
      ? 'T$month/${year % 100}'
      : '${month.toString().padLeft(2, '0')}/${year % 100}';

  // —— Admin: system logs (bảng system_logs trong DB) ——
  String get systemLogsTitle => isVi ? 'Log hệ thống' : 'System logs';
  String get searchLogsHint => isVi
      ? 'Tìm trong message, class, method...'
      : 'Search message, class, method...';
  String get allLevels => isVi ? 'Tất cả' : 'All';
  String get noLogsFound =>
      isVi ? 'Không có log trong khoảng thời gian này' : 'No logs in this window';
  String get loadMoreLogs => isVi ? 'Tải thêm' : 'Load more';
  String logCountLabel(int shown, int total) =>
      isVi ? 'Hiển thị $shown / $total log' : 'Showing $shown / $total logs';
  // —— Thông báo lỗi thân thiện (friendly_error.dart) ——
  String get errNetwork => isVi
      ? 'Không có kết nối mạng. Kiểm tra Wi-Fi/4G rồi thử lại.'
      : 'No internet connection. Check Wi-Fi/4G and try again.';
  String get errTimeout => isVi
      ? 'Máy chủ phản hồi quá chậm. Thử lại sau ít phút.'
      : 'The server is taking too long. Try again in a moment.';
  String get errServer => isVi
      ? 'Máy chủ đang gặp sự cố. Chúng mình đang xử lý, thử lại sau nhé.'
      : 'The server hit a problem. We are on it — try again soon.';
  String get errSession => isVi
      ? 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'
      : 'Your session expired. Please sign in again.';
  String get errGeneric => isVi
      ? 'Có lỗi xảy ra. Vui lòng thử lại.'
      : 'Something went wrong. Please try again.';

  // —— Quiz theo phản ứng (contract mới) ——
  String get quizBrowseTitle => isVi ? 'Luyện tập theo phản ứng' : 'Practice by reaction';
  String get quizBrowseSubtitle => isVi
      ? 'Chọn phản ứng, thực hiện AR rồi trả lời câu hỏi.'
      : 'Pick a reaction, perform it in AR, then answer the questions.';
  String get quizGradeLabel => isVi ? 'Lớp' : 'Grade';
  String quizCategoryLabel(String c) {
    switch (c) {
      case 'METAL':
        return isVi ? 'Kim loại' : 'Metal';
      case 'ACID':
        return isVi ? 'Axit' : 'Acid';
      case 'BASE':
        return isVi ? 'Bazơ' : 'Base';
      case 'SALT':
        return isVi ? 'Muối' : 'Salt';
      default:
        return c;
    }
  }
  String get quizSearchReactionHint =>
      isVi ? 'Tìm phản ứng...' : 'Search reactions...';
  String get quizNoReactions => isVi
      ? 'Không có phản ứng nào cho bộ lọc này'
      : 'No reactions for this filter';
  String get quizReactionsLoadFailed => isVi
      ? 'Không tải được danh sách phản ứng'
      : 'Failed to load reactions';
  String get quizStart => isVi ? 'Bắt đầu' : 'Start';
  String get quizContinue => isVi ? 'Tiếp tục' : 'Continue';
  String get quizRetry => isVi ? 'Làm lại' : 'Retry';
  String get quizHistoryAction => isVi ? 'Lịch sử' : 'History';
  String get quizCompletedBadge => isVi ? 'Đã hoàn thành' : 'Completed';
  String get quizInProgressBadge => isVi ? 'Đang làm dở' : 'In progress';
  String get quizStartFailed =>
      isVi ? 'Không bắt đầu được, thử lại sau' : 'Could not start, try again';
  String get quizWaitingArTitle =>
      isVi ? 'Thực hiện phản ứng AR để mở bài' : 'Perform the AR reaction to unlock';
  String get quizWaitingArDesc => isVi
      ? 'Quét đúng 2 thẻ hoá học của phản ứng này và thực hiện phản ứng trong AR. Khi phản ứng thành công, bài quiz sẽ tự mở và đồng hồ 7 phút bắt đầu chạy.'
      : 'Scan the 2 chemical cards of this reaction and perform it in AR. Once it succeeds, the quiz unlocks and the 7-minute timer starts.';
  String get quizOpenArScanner => isVi ? 'Mở máy quét AR' : 'Open AR scanner';
  String get quizCheckArStatus => isVi ? 'Kiểm tra lại' : 'Check again';
  String get quizWaitingArAutoCheck => isVi
      ? 'Tự động kiểm tra mỗi 5 giây'
      : 'Auto-checking every 5 seconds';
  String get quizScriptTitle =>
      isVi ? 'Kịch bản thí nghiệm' : 'Experiment script';
  String get quizSubmit => isVi ? 'Nộp bài' : 'Submit';
  String get quizSubmitConfirm =>
      isVi ? 'Nộp bài ngay bây giờ?' : 'Submit your answers now?';
  String quizSubmitConfirmUnanswered(int n) => isVi
      ? 'Còn $n câu chưa trả lời. Vẫn nộp bài?'
      : '$n questions are unanswered. Submit anyway?';
  String get quizSubmitFailed =>
      isVi ? 'Nộp bài thất bại, thử lại' : 'Submit failed, try again';
  String get quizAbandon => isVi ? 'Bỏ bài' : 'Abandon';
  String get quizAbandonConfirm => isVi
      ? 'Thoát bây giờ sẽ BỎ lần làm bài này (không tính điểm). Tiếp tục?'
      : 'Leaving now ABANDONS this attempt (no score). Continue?';
  String get quizAnswerSaveFailed => isVi
      ? 'Chưa lưu được đáp án, chọn lại giúp nhé'
      : 'Answer not saved, please pick again';
  String get quizStateLoadFailed => isVi
      ? 'Không tải được trạng thái bài làm'
      : 'Failed to load attempt state';

  // —— Admin: quản lý người dùng ——
  String get userMgmtTitle => isVi ? 'Quản lý người dùng' : 'User management';
  String get userMgmtSearchHint =>
      isVi ? 'Tìm theo email hoặc tên...' : 'Search by email or name...';
  String get userMgmtEmpty =>
      isVi ? 'Chưa có người dùng nào' : 'No users yet';
  String get userMgmtLoadMore => isVi ? 'Tải thêm' : 'Load more';
  String get userMgmtLoadFailed =>
      isVi ? 'Không tải được danh sách người dùng' : 'Failed to load users';
  String get userMgmtRetry => isVi ? 'Thử lại' : 'Retry';
  String get userMgmtStatusLabel => isVi ? 'Trạng thái' : 'Status';
  String get userMgmtRolesLabel => isVi ? 'Vai trò' : 'Roles';
  String get userMgmtResetPassword =>
      isVi ? 'Đặt lại mật khẩu' : 'Reset password';
  String get userMgmtResetPasswordConfirm => isVi
      ? 'Đặt lại mật khẩu của người dùng này? Mật khẩu tạm sẽ hiện ra sau khi đặt.'
      : 'Reset this user\'s password? A temporary password will be shown.';
  String get userMgmtDelete => isVi ? 'Xoá người dùng' : 'Delete user';
  String get userMgmtDeleteConfirm => isVi
      ? 'Xoá (mềm) người dùng này? Tài khoản sẽ bị vô hiệu hoá.'
      : 'Soft-delete this user? The account will be disabled.';
  String get userMgmtUpdated => isVi ? 'Đã cập nhật' : 'Updated';
  String get userMgmtDeleted => isVi ? 'Đã xoá người dùng' : 'User deleted';
  String get userMgmtActionFailed =>
      isVi ? 'Thao tác thất bại, thử lại sau' : 'Action failed, try again';
  String get userMgmtSelfWarning => isVi
      ? 'Không thể tự thao tác trên tài khoản của chính mình'
      : 'You cannot modify your own account';
  String get userMgmtSelfTag => isVi ? '(bạn)' : '(you)';
  String userStatusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return isVi ? 'Hoạt động' : 'Active';
      case 'INACTIVE':
        return isVi ? 'Ngưng hoạt động' : 'Inactive';
      case 'BLOCKED':
        return isVi ? 'Bị chặn' : 'Blocked';
      case 'DELETED':
        return isVi ? 'Đã xoá' : 'Deleted';
      case 'REJECTED':
        return isVi ? 'Bị từ chối' : 'Rejected';
      default:
        return status;
    }
  }

  String roleLabel(String role) {
    switch (role) {
      case 'ROLE_ADMIN':
        return 'Admin';
      case 'ROLE_STAFF':
        return isVi ? 'Nhân viên' : 'Staff';
      case 'ROLE_TEACHER':
        return isVi ? 'Giáo viên' : 'Teacher';
      case 'ROLE_STUDENT':
        return isVi ? 'Học sinh' : 'Student';
      default:
        return role;
    }
  }
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
  String get passwordResetSuccessLogin => isVi
      ? 'Đổi mật khẩu thành công! Vui lòng đăng nhập.'
      : 'Password changed successfully! Please sign in.';

  // —— Registration ——
  String get registerTitle =>
      isVi ? 'Đăng ký tài khoản' : 'Create account';
  String get registerSubtitle => isVi
      ? 'Nhập email và mật khẩu. Họ tên có thể thêm sau trong Profile.'
      : 'Enter email and password. You can add your name later in Profile.';
  String get confirmPasswordLabel =>
      isVi ? 'Xác nhận mật khẩu' : 'Confirm password';
  String get confirmPasswordHint =>
      isVi ? 'Nhập lại mật khẩu' : 'Re-enter password';
  String get passwordMismatch =>
      isVi ? 'Mật khẩu xác nhận không khớp' : 'Passwords do not match';
  String get requiredField => isVi ? 'Bắt buộc' : 'Required';
  String get invalidEmail =>
      isVi ? 'Email không hợp lệ' : 'Invalid email';
  String get passwordPolicyHint => isVi
      ? CognitoPasswordPolicy.hintVi
      : CognitoPasswordPolicy.hintEn;
  String passwordPolicyError(String code) {
    switch (code) {
      case 'min8':
        return isVi ? 'Mật khẩu tối thiểu 8 ký tự' : 'Password must be at least 8 characters';
      case 'upper':
        return isVi ? 'Cần ít nhất 1 chữ hoa' : 'Need at least one uppercase letter';
      case 'lower':
        return isVi ? 'Cần ít nhất 1 chữ thường' : 'Need at least one lowercase letter';
      case 'digit':
        return isVi ? 'Cần ít nhất 1 chữ số' : 'Need at least one number';
      case 'symbol':
        return isVi ? 'Cần ít nhất 1 ký tự đặc biệt' : 'Need at least one symbol';
      default:
        return isVi ? 'Mật khẩu không hợp lệ' : 'Invalid password';
    }
  }
  String get loggingIn => isVi ? 'Đang đăng nhập...' : 'Signing in...';
  String get forgotPassword =>
      isVi ? 'Quên mật khẩu?' : 'Forgot password?';

  // —— Forgot password ——
  String get forgotPasswordTitle =>
      isVi ? 'Quên mật khẩu' : 'Forgot password';
  String get forgotPasswordEmailHint => isVi
      ? 'Nhập email đã đăng ký. Chúng tôi sẽ gửi mã OTP.'
      : 'Enter your registered email. We will send an OTP code.';
  String get sendOtpButton => isVi ? 'Gửi mã OTP' : 'Send OTP';
  String get otpLabel => isVi ? 'Mã OTP' : 'OTP code';
  String get otpHint => isVi ? 'Nhập mã 6 số' : 'Enter 6-digit code';
  String get newPasswordLabel =>
      isVi ? 'Mật khẩu mới' : 'New password';
  String get confirmNewPasswordLabel =>
      isVi ? 'Xác nhận mật khẩu mới' : 'Confirm new password';
  String get confirmChangePassword => isVi
      ? 'Xác nhận đổi mật khẩu'
      : 'Confirm password change';
  String get otpSent =>
      isVi ? 'Đã gửi mã OTP tới email của bạn' : 'OTP sent to your email';
  String get backToLogin => isVi ? 'Quay lại đăng nhập' : 'Back to login';
  String get verifyOtpTitle => isVi ? 'Xác thực OTP' : 'Verify OTP';
  String get verifyOtpSubtitle => isVi
      ? 'Nhập mã OTP đã gửi tới email của bạn'
      : 'Enter the OTP code sent to your email';
  String get resendOtp => isVi ? 'Gửi lại mã' : 'Resend code';
  String get verifyButton => isVi ? 'Xác nhận' : 'Verify';
  String get nextStep => isVi ? 'Tiếp tục' : 'Continue';
  String get errorGeneric =>
      isVi ? 'Đã xảy ra lỗi. Vui lòng thử lại.' : 'Something went wrong. Please try again.';

  // —— Home screen ——
  String get welcomeBack => isVi ? 'Chào mừng trở lại,' : 'Welcome back,';
  String get upgrade => isVi ? 'Nâng cấp' : 'Upgrade';
  String get checkingAccess => isVi ? 'Đang kiểm tra...' : 'Checking access...';
  String get startArExperiment => isVi ? 'Bắt đầu thí nghiệm AR' : 'Start AR Experiment';
  String get homeArDescription => isVi
      ? 'Quét thẻ hóa học để xem phản ứng tuyệt vời trong thực tế ảo tăng cường'
      : 'Scan chemical flashcards to witness amazing reactions in augmented reality';
  String get cannotScanAr => isVi ? 'Không thể quét AR' : 'Cannot Scan AR';
  String get arAccessCheckFailed => isVi
      ? 'Không thể kiểm tra quyền quét AR. Vui lòng thử lại.'
      : 'Unable to check AR access. Please try again.';
  String get arAccessRequiredMessage => isVi
      ? 'Bạn cần kích hoạt mã kit hoặc mua gói AR 30 Days để quét AR.'
      : 'You need to activate a kit or purchase an AR 30 Days package to scan AR.';
  String get activateOrBuyPackage => isVi ? 'Kích hoạt / Mua gói' : 'Activate / Buy Package';
  String get navLibrary => isVi ? 'Thư viện' : 'Library';
  String get navCart => isVi ? 'Giỏ hàng' : 'Cart';
  String get navQuiz => isVi ? 'Quiz' : 'Quiz';
  String get navMiniGame => isVi ? 'Mini Game' : 'Mini Game';

  // —— Shop screen ——
  String get bundlePacks => isVi ? 'Gói combo' : 'Bundle Packs';
  String get upTo20PercentOff => isVi ? 'Giảm tới 20%' : 'Up to 20% off';
  String get singleCards => isVi ? 'Thẻ đơn' : 'Single Cards';
  String get owned => isVi ? 'Đã sở hữu' : 'Owned';
  String get available => isVi ? 'Khả dụng' : 'Available';
  String get buyNow => isVi ? 'Mua ngay' : 'Buy Now';
  String get buyWithPoints => isVi ? 'Mua bằng điểm' : 'Buy with Points';
  String get payWithBank => isVi ? 'Thanh toán ngân hàng' : 'Pay with Bank';
  String get addBundleToCart => isVi ? 'Thêm combo vào giỏ' : 'Add Bundle to Cart';
  String cardsIncluded(int n) => isVi ? '$n thẻ' : '$n cards included';
  String get qrImageNotAvailable => isVi ? 'Ảnh QR không khả dụng' : 'QR image is not available';
  String get saveQr => isVi ? 'Lưu QR' : 'Save QR';
  String get close => isVi ? 'Đóng' : 'Close';
  String get cancel => isVi ? 'Hủy' : 'Cancel';
  String get qrContentLabel => isVi ? 'Nội dung QR: ' : 'QR Content: ';
  String get expiresAtLabel => isVi ? 'Hết hạn: ' : 'Expires at: ';
  String get storagePermissionDenied => isVi ? 'Quyền lưu trữ bị từ chối' : 'Storage permission denied';
  String get qrSavedToGallery => isVi ? 'Đã lưu QR vào thư viện ảnh' : 'QR saved to gallery';
  String get saveQrFailed => isVi ? 'Lưu QR thất bại' : 'Save QR failed';
  String get buySingleCardFailed => isVi ? 'Mua thẻ thất bại' : 'Buy single card failed';
  String get cardPurchasedSuccess => isVi ? 'Mua thẻ thành công!' : 'Card purchased successfully!';
  String get notEnoughKnowledgePoints => isVi ? 'Không đủ điểm tri thức' : 'Not enough Knowledge Points';
  String get cardPurchasedCheckBag => isVi ? 'Đã mua thẻ! Kiểm tra túi đồ.' : 'Card purchased! Check your bag.';
  String get bundleAddedToBag => isVi ? 'Combo đã thêm vào túi đồ!' : 'Bundle added to your bag!';
  String get uploadProofImageFailed => isVi ? 'Tải ảnh minh chứng thất bại' : 'Upload proof image failed';
  String get proofImageUploadedSuccess => isVi ? 'Ảnh minh chứng đã tải lên' : 'Proof image uploaded successfully';
  String get uploadPaymentProofFirst => isVi ? 'Vui lòng tải ảnh minh chứng trước' : 'Please upload payment proof image first';
  String get createPaymentFailed => isVi ? 'Tạo thanh toán thất bại' : 'Create payment failed';
  String get paymentSubmittedWaitApproval => isVi
      ? 'Đã gửi thanh toán. Vui lòng chờ staff duyệt.'
      : 'Payment submitted. Please wait for staff approval.';
  String get bundleAddedToCart => isVi ? 'Combo đã thêm vào giỏ!' : 'Bundle added to cart!';
  String get vnpayPayment => isVi ? 'Thanh toán VNPay' : 'VNPay Payment';
  String get scanQrCodeToPay => isVi ? 'Quét mã QR để thanh toán' : 'Scan QR code to pay';
  String get receiver => isVi ? 'Người nhận' : 'Receiver';
  String get transferContent => isVi ? 'Nội dung' : 'Content';
  String get uploadPaymentProof => isVi ? 'Tải ảnh minh chứng' : 'Upload payment proof';
  String get paymentProofSelected => isVi ? 'Đã chọn ảnh minh chứng' : 'Payment proof selected';
  String get confirmPayment => isVi ? 'Xác nhận thanh toán' : 'Confirm Payment';

  // —— Cart screen ——
  String get cart => isVi ? 'Giỏ hàng' : 'Cart';
  String get cartCleared => isVi ? 'Đã xóa giỏ hàng' : 'Cart cleared';
  String get clear => isVi ? 'Xóa' : 'Clear';
  String get cartEmpty => isVi ? 'Giỏ hàng trống' : 'Your cart is empty';
  String get cartEmptyHint => isVi ? 'Thêm thẻ hoặc combo từ cửa hàng' : 'Add cards or bundles from the shop';
  String get goToShop => isVi ? 'Đến cửa hàng' : 'Go to Shop';
  String get total => isVi ? 'Tổng cộng' : 'Total';
  String get proceedToPayment => isVi ? 'Tiến hành thanh toán' : 'Proceed to Payment';
  String get remove => isVi ? 'Xóa' : 'Remove';
  String singleCardSubtitle(String symbol) => isVi ? 'Thẻ đơn · $symbol' : 'Single card · $symbol';
  String bundleCartSubtitle(int count) => isVi ? 'Combo · $count thẻ' : 'Bundle · $count card(s)';

  // —— Payment success ——
  String get paymentSuccessful => isVi ? 'Thanh toán thành công!' : 'Payment Successful!';
  String get paymentSuccessDescription => isVi
      ? 'Thẻ hóa học đã được thêm vào bộ sưu tập. Bắt đầu thí nghiệm ngay!'
      : 'Your chemical cards have been added to your collection. Start experimenting!';
  String get backToHome => isVi ? 'Về trang chủ' : 'Back to Home';
  String get goToBagNow => isVi ? 'Đi đến túi ngay' : 'Go to Bag Now';

  // —— My AR Cards screen ——
  String get myArCards => isVi ? 'Thẻ AR của tôi' : 'My AR Cards';
  String get noSingleArCardsPurchased => isVi ? 'Bạn chưa mua card AR lẻ nào.' : 'No individual AR cards purchased yet.';
  String get singleArCardsEmptyHint => isVi
      ? 'Các card AR lẻ đã mua sẽ xuất hiện tại đây để bạn xem hạn dùng và tải lại QR.'
      : 'Purchased individual AR cards will appear here for you to view expiry and reload QR.';
  String get expiryUnknown => isVi ? 'Không rõ hạn' : 'Unknown expiry';
  String get arCard => isVi ? 'Thẻ AR' : 'AR Card';
  String get stillActive => isVi ? 'Còn hạn' : 'Active';
  String get expired => isVi ? 'Đã hết hạn' : 'Expired';
  String activeUntil(String date) => isVi ? 'Đến $date' : 'Until $date';
  String expiredOn(String date) => isVi ? 'Hết hạn: $date' : 'Expired: $date';
  String get loadMore => isVi ? 'Tải thêm' : 'Load more';
  String get downloadQrFailed => isVi ? 'Tải QR thất bại' : 'Download QR failed';
  String get cannotLoadQrImage => isVi ? 'Không thể tải ảnh QR' : 'Cannot load QR image';

  // —— My Bag screen ——
  String get myBagOwnedSubstances => isVi ? 'Chất hóa học đã sở hữu' : 'Your owned substances';
  String itemCount(int n) => isVi ? '$n mục' : '$n items';
  String get activate => isVi ? 'Kích hoạt' : 'Activate';
  String get cannotLoadBag => isVi ? 'Không thể tải túi đồ' : 'Cannot load your bag';
  String get tryAgain => isVi ? 'Thử lại' : 'Try Again';
  String get bagEmpty => isVi ? 'Túi đồ trống' : 'Your bag is empty';
  String get bagEmptyActivateHint => isVi
      ? 'Kích hoạt kit để thêm chất vào túi đồ'
      : 'Activate a kit to add substances to your bag';
  String get activateKit => isVi ? 'Kích hoạt Kit' : 'Activate Kit';
  String get inactive => isVi ? 'Không hoạt động' : 'Inactive';
  String get enterActivationCode => isVi ? 'Vui lòng nhập mã kích hoạt' : 'Please enter activation code';
  String get kitActivatedSuccess => isVi ? 'Kích hoạt kit thành công' : 'Kit activated successfully';
  String get activateKitHint => isVi
      ? 'Nhập mã in trên kit vật lý của bạn.'
      : 'Enter the code printed on your physical kit.';
  String get activationCodeExample => isVi ? 'VD: CHEM-ABCD-1234' : 'Example: CHEM-ABCD-1234';

  // —— Substance detail screen ——
  String get substanceDetail => isVi ? 'Chi tiết chất' : 'Substance Detail';
  String get cannotLoadSubstanceDetail => isVi ? 'Không thể tải chi tiết chất' : 'Cannot load substance detail';
  String get noDetailFound => isVi ? 'Không tìm thấy chi tiết' : 'No detail found';
  String get basicInformation => isVi ? 'Thông tin cơ bản' : 'Basic Information';
  String get elementDetail => isVi ? 'Chi tiết nguyên tố' : 'Element Detail';
  String get compoundDetail => isVi ? 'Chi tiết hợp chất' : 'Compound Detail';
  String get name => isVi ? 'Tên' : 'Name';
  String get vietnameseName => isVi ? 'Tên tiếng Việt' : 'Vietnamese Name';
  String get formula => isVi ? 'Công thức' : 'Formula';
  String get chemicalGroup => isVi ? 'Nhóm hóa học' : 'Chemical Group';
  String get state => isVi ? 'Trạng thái' : 'State';
  String get atomicNumber => isVi ? 'Số hiệu nguyên tử' : 'Atomic Number';
  String get symbolLabel => isVi ? 'Ký hiệu' : 'Symbol';
  String get periodicCategory => isVi ? 'Phân loại tuần hoàn' : 'Periodic Category';
  String get atomicMass => isVi ? 'Khối lượng nguyên tử' : 'Atomic Mass';
  String get period => isVi ? 'Chu kỳ' : 'Period';
  String get groupLabel => isVi ? 'Nhóm' : 'Group';
  String get iupacName => isVi ? 'Tên IUPAC' : 'IUPAC Name';
  String get casNumber => isVi ? 'Số CAS' : 'CAS Number';
  String get compoundClass => isVi ? 'Lớp hợp chất' : 'Compound Class';
  String get usageNote => isVi ? 'Ghi chú sử dụng' : 'Usage Note';
  String get reactionProductOnly => isVi ? 'Chỉ là sản phẩm phản ứng' : 'Reaction Product Only';
  String get physicalInKit => isVi ? 'Có trong kit vật lý' : 'Physical In Kit';
  String get statusLabel => isVi ? 'Trạng thái' : 'Status';
  String get noDetailAvailable => isVi ? 'Không có chi tiết' : 'No detail available';
  String get yes => isVi ? 'Có' : 'Yes';
  String get no => isVi ? 'Không' : 'No';

  // —— AR Scan screen ——
  String get poweredByUnity => isVi ? 'Được hỗ trợ bởi Unity Engine' : 'Powered by Unity Engine';
  String get preparingArScanner => isVi ? 'Đang chuẩn bị máy quét AR...' : 'Preparing AR scanner...';
  String get back => isVi ? 'Quay lại' : 'Back';
  String get unableToStartAr => isVi ? 'Không thể khởi động AR' : 'Unable to start AR';
  String get unityInitFailed => isVi
      ? 'Unity Engine không thể khởi tạo trên thiết bị này.'
      : 'The Unity engine could not initialize on this device.';

  // —— AR Result screen ——
  String get noExperimentData => isVi ? 'Không tìm thấy dữ liệu thí nghiệm' : 'No experiment data found';
  String get goToScan => isVi ? 'Quay lại quét' : 'Go to Scan';
  String get experimentResult => isVi ? 'Kết quả thí nghiệm' : 'Experiment Result';
  String get newExperiment => isVi ? 'Thí nghiệm mới' : 'New Experiment';
  String get home => isVi ? 'Trang chủ' : 'Home';
  String get knowledgePointsEarned => isVi ? 'Điểm tri thức đạt được' : 'Knowledge Points Earned';
  String get keepExperimentingEarnMore => isVi
      ? 'Tiếp tục thí nghiệm để kiếm thêm điểm!'
      : 'Keep experimenting to earn more!';

  // —— Quiz screens ——
  String get publishedQuizzes => isVi ? 'Quiz đã xuất bản' : 'Published Quizzes';
  String get selectQuizToPractice => isVi ? 'Chọn một bài quiz để bắt đầu luyện tập.' : 'Select a quiz to start practicing.';
  String questionCountBadge(int n) => isVi ? '$n câu' : '$n questions';
  String get published => isVi ? 'Đã publish' : 'Published';
  String get historyLabel => isVi ? 'Lịch sử' : 'History';
  String get startQuiz => isVi ? 'Làm quiz' : 'Start Quiz';
  String get cannotLoadQuizList => isVi ? 'Không tải được danh sách quiz' : 'Cannot load quiz list';
  String get noQuizzesYet => isVi ? 'Chưa có quiz nào' : 'No quizzes yet';
  String get noPublishedQuizzesHint => isVi
      ? 'Hiện chưa có quiz nào được publish.'
      : 'No quizzes have been published yet.';
  String get lessonNotFound => isVi ? 'Không tìm thấy bài học' : 'Lesson not found';
  String get quizRequiresLessonCode => isVi
      ? 'Màn hình quiz cần lessonCode để tải quiz.'
      : 'Quiz screen requires a lessonCode to load.';
  String get goHome => isVi ? 'Về Home' : 'Go Home';
  String get cannotLoadQuiz => isVi ? 'Không tải được quiz' : 'Cannot load quiz';
  String get noQuiz => isVi ? 'Chưa có quiz' : 'No quiz';
  String get lessonNoPublishedQuiz => isVi
      ? 'Bài học này hiện chưa có quiz đã publish.'
      : 'This lesson has no published quiz yet.';
  String questionCount(int n) => isVi ? '$n câu hỏi' : '$n questions';
  String get loading => isVi ? 'Đang tải...' : 'Loading...';
  String get submitting => isVi ? 'Đang nộp...' : 'Submitting...';
  String get submitQuiz => isVi ? 'Nộp bài' : 'Submit Quiz';
  String questionNumber(int n) => isVi ? 'Câu $n' : 'Question $n';
  String get trueAnswer => isVi ? 'Đúng' : 'True';
  String get falseAnswer => isVi ? 'Sai' : 'False';
  String get enterYourAnswer => isVi ? 'Nhập đáp án của bạn' : 'Enter your answer';
  String get quizResult => isVi ? 'Kết quả bài làm' : 'Quiz Result';
  String get correct => isVi ? 'Đúng' : 'Correct';
  String get incorrect => isVi ? 'Sai' : 'Incorrect';
  String yourAnswer(String a) => isVi ? 'Bạn chọn: $a' : 'Your answer: $a';
  String correctAnswerLabel(String a) => isVi ? 'Đáp án đúng: $a' : 'Correct answer: $a';
  String answeredProgress(int answered, int total) => isVi
      ? 'Đã trả lời $answered/$total'
      : 'Answered $answered/$total';

  // —— Reaction experiment quiz flow ——
  String get selectYourGrade => isVi
      ? 'Chọn lớp bạn đang học để bắt đầu thí nghiệm AR + quiz.'
      : 'Select your grade to start AR experiment + quiz.';
  String gradeLabel(int grade) => isVi ? 'Lớp $grade' : 'Grade $grade';
  String get reactionCategoriesTitle => isVi
      ? 'Chọn nhóm phản ứng'
      : 'Choose reaction category';
  String get reactionCategoryMetal => isVi
      ? 'Phản ứng với kim loại'
      : 'Reactions with metals';
  String get reactionCategoryAcid => isVi
      ? 'Phản ứng với axit'
      : 'Reactions with acids';
  String get reactionCategoryBase => isVi
      ? 'Phản ứng với bazơ'
      : 'Reactions with bases';
  String get reactionCategorySalt => isVi
      ? 'Phản ứng với muối'
      : 'Reactions with salts';
  String get searchReactionsHint => isVi
      ? 'Tìm tên phản ứng...'
      : 'Search reaction name...';
  String get startExperiment => isVi ? 'Bắt đầu' : 'Start';
  String get retryExperiment => isVi ? 'Làm lại' : 'Retry';
  String get viewAttemptHistory => isVi ? 'Xem lịch sử' : 'View history';
  String get virtualExperimentAr => isVi
      ? 'Thí nghiệm ảo (AR flash card)'
      : 'Virtual experiment (AR flash card)';
  String get scanTwoCardsHint => isVi
      ? 'Quét đúng chất của phản ứng. Thời gian 7 phút chỉ bắt đầu sau khi bấm Quét AR.'
      : 'Scan the 2 correct substance cards. The 7-minute timer starts only after a successful Reaction.';
  String get openArScan => isVi ? 'Quét AR' : 'Scan AR';
  String get reactionButton => isVi ? 'Phản ứng' : 'Reaction';
  String get reactionScript => isVi ? 'Mô tả phản ứng' : 'Reaction script';
  String get experimentQuizSection => isVi ? 'Quiz (5 câu)' : 'Quiz (5 questions)';
  String get confirmSubmitTitle => isVi ? 'Nộp bài?' : 'Submit quiz?';
  String get confirmSubmitMessage => isVi
      ? 'Bạn có chắc chắn muốn nộp bài không?'
      : 'Are you sure you want to submit?';
  String get confirm => isVi ? 'Xác nhận' : 'Confirm';
  String get backToReactionList => isVi
      ? 'Danh sách phản ứng'
      : 'Reaction list';
  String get backToCategories => isVi
      ? 'Chọn nhóm phản ứng'
      : 'Reaction categories';
  String get experimentScoreTitle => isVi ? 'Kết quả làm bài' : 'Your score';
  String scoreOutOf(int score, int total) =>
      isVi ? '$score / $total điểm' : '$score / $total points';
  String get explanationLabel => isVi ? 'Giải thích' : 'Explanation';
  String get cardsReadyForReaction => isVi
      ? 'Đã quét đủ 2 thẻ — bấm Phản ứng để bắt đầu'
      : '2 cards scanned — tap Reaction to start';
  String get arStepCompleted => isVi ? 'Đã hoàn thành AR' : 'AR completed';
  String get noReactionsFound => isVi
      ? 'Không tìm thấy phản ứng'
      : 'No reactions found';
  String reactantsLabel(String labels) =>
      isVi ? 'Chất cần quét: $labels' : 'Scan: $labels';

  // —— Feedback screen ——
  String get feedbackSubmitSuccess => isVi
      ? 'Gửi phản hồi thành công. Cảm ơn bạn!'
      : 'Feedback submitted successfully. Thank you!';
  String get feedbackSubmitFailed => isVi
      ? 'Không gửi được phản hồi. Vui lòng thử lại.'
      : 'Could not submit feedback. Please try again.';
  String get feedbackType => isVi ? 'Loại phản hồi' : 'Feedback type';
  String get feedbackTitle => isVi ? 'Tiêu đề' : 'Title';
  String get feedbackTitleHint => isVi ? 'VD: Lỗi hiển thị quiz' : 'E.g: Quiz display error';
  String get feedbackContentLabel => isVi ? 'Nội dung' : 'Content';
  String get feedbackContentHint => isVi ? 'Mô tả chi tiết lỗi hoặc trải nghiệm...' : 'Describe the issue or your experience...';
  String get illustrationImageOptional => isVi ? 'Ảnh minh họa (tùy chọn)' : 'Illustration image (optional)';
  String get tapToUploadImage => isVi ? 'Chạm để tải ảnh lên' : 'Tap to upload image';
  String get sendAnonymously => isVi ? 'Gửi ẩn danh' : 'Send anonymously';
  String get anonymousOnHint => isVi ? 'Staff sẽ không thấy email/tên của bạn.' : 'Staff will not see your email/name.';
  String get anonymousOffHint => isVi ? 'Staff sẽ thấy thông tin tài khoản của bạn.' : 'Staff will see your account information.';
  String get submitFeedback => isVi ? 'Gửi phản hồi' : 'Submit Feedback';

  // —— Package / Upgrade screen ——
  String get upgradePackages => isVi ? 'Nâng cấp gói' : 'Upgrade Packages';
  String get noPackagesAvailable => isVi ? 'Chưa có gói nào' : 'No packages available';
  String get buyAr30Days => isVi ? 'Mua AR 30 ngày' : 'Buy AR 30 Days';
  String get lifetime => isVi ? 'Vĩnh viễn' : 'Lifetime';
  String durationDays(int n) => isVi ? '$n ngày' : '$n days';
  String get purchaseError => isVi ? 'Lỗi mua hàng' : 'Purchase error';
  String get googleProductIdEmpty => isVi ? 'Mã sản phẩm Google trống' : 'Google Product ID is empty';
  String get googlePlayBillingUnavailable => isVi
      ? 'Google Play Billing không khả dụng'
      : 'Google Play Billing is not available';
  String productNotFoundOnGooglePlay(String id) => isVi
      ? 'Không tìm thấy sản phẩm trên Google Play: $id'
      : 'Product not found on Google Play: $id';
  String get purchasePackageFailed => isVi ? 'Mua gói thất bại' : 'Package purchase failed';
  String get paymentFailed => isVi ? 'Thanh toán thất bại' : 'Payment failed';
  String get purchasePackageSuccess => isVi ? 'Mua gói thành công' : 'Package purchased successfully';
  String get verifyGooglePlayFailed => isVi ? 'Verify Google Play thất bại' : 'Google Play verification failed';

  // —— AI Chat panel ——
  String get aiChemistryTutor => isVi ? 'Gia sư Hóa học AI' : 'AI Chemistry Tutor';
  String get aiThinking => isVi ? 'Đang suy nghĩ...' : 'Thinking...';
  String get aiChatSubtitle => isVi
      ? 'Hỏi về hóa học, phản ứng, nguyên tố'
      : 'Ask about chemistry, reactions, elements';
  String get loadingConversation => isVi ? 'Đang tải hội thoại...' : 'Loading conversation...';
  String get aiWelcomeTitle => isVi ? 'Xin chào! Tôi là trợ lý hóa học' : 'Hello! I am your chemistry assistant';
  String get aiWelcomeSubtitle => isVi
      ? 'Hỏi về công thức, phản ứng, bảng tuần hoàn hoặc bài tập AR.'
      : 'Ask about formulas, reactions, periodic table, or AR exercises.';
  String get aiChatInputHint => isVi ? 'Nhập câu hỏi hóa học...' : 'Ask a chemistry question...';

  // —— Profile screen extras ——
  String get myFeedbacks => isVi ? 'Feedback của tôi' : 'My Feedbacks';
  String get myFeedbacksSubtitle => isVi ? 'Xem trạng thái phản hồi' : 'View feedback status';
  String get assistantSettings => isVi ? 'Cài đặt trợ lý' : 'Assistant Settings';
  String get aiAssistant => isVi ? 'Trợ lý AI' : 'AI Assistant';
  String get assistantFabVisible => isVi ? 'Nút trợ lý đang hiển thị trên màn hình' : 'Assistant button is visible on screen';
  String get assistantFabHidden => isVi ? 'Nút trợ lý đang bị ẩn' : 'Assistant button is hidden';

  String get myFeedbacksEmpty =>
      isVi ? 'Bạn chưa gửi feedback nào' : 'You have not submitted any feedback yet';
  String typeWithValue(String type) => isVi ? 'Loại: $type' : 'Type: $type';
  String get feedbackNotFound =>
      isVi ? 'Không tìm thấy feedback' : 'Feedback not found';
  String get systemReplyTitle =>
      isVi ? 'Phản hồi từ hệ thống' : 'System response';
  String get systemReplyPending => isVi
      ? 'Hệ thống sẽ phản hồi trong thời gian sớm nhất.'
      : 'The system will respond as soon as possible.';
  String get payWithKnowledgePoints => isVi
      ? 'Thanh toán bằng điểm tri thức'
      : 'Pay with Knowledge Points';
  String get payWithBankVnpay =>
      isVi ? 'Thanh toán ngân hàng (VNPay)' : 'Pay with Bank (VNPay)';

  String get quizColon => 'Quiz';

  // —— Quiz history & attempt detail ——
  String get quizHistoryTitle => isVi ? 'Lịch sử làm quiz' : 'Quiz history';
  String get quizHistorySection => isVi ? 'Lịch sử làm bài' : 'Attempt history';
  String get quizHistoryRecent => isVi
      ? 'Các lần làm quiz gần đây của bạn.'
      : 'Your recent quiz attempts.';
  String quizHistoryFor(String title) =>
      isVi ? 'Các lần làm quiz: $title' : 'Quiz attempts: $title';
  String get scoreLabel => isVi ? 'Điểm' : 'Score';
  String get correctLabel => isVi ? 'Đúng' : 'Correct';
  String get timeLabel => isVi ? 'Thời gian' : 'Time';
  String get cannotLoadHistory =>
      isVi ? 'Không tải được lịch sử' : 'Cannot load history';
  String get noHistoryYet => isVi ? 'Chưa có lịch sử' : 'No history yet';
  String get noQuizAttemptsYet => isVi
      ? 'Bạn chưa làm quiz này lần nào.'
      : 'You have not attempted this quiz yet.';
  String get attemptNotFound =>
      isVi ? 'Không tìm thấy bài làm' : 'Attempt not found';
  String get missingAttemptCode => isVi
      ? 'Thiếu attemptCode để tải chi tiết.'
      : 'Missing attemptCode to load detail.';
  String get noData => isVi ? 'Không có dữ liệu' : 'No data';
  String get attemptDetailNotFound => isVi
      ? 'Không tìm thấy chi tiết bài làm.'
      : 'Attempt detail not found.';
  String get attemptDetailTitle => isVi ? 'Chi tiết bài làm' : 'Attempt detail';
  String get yourChoiceLabel => isVi ? 'Bạn chọn' : 'Your choice';
  String get correctAnswerShort => isVi ? 'Đáp án đúng' : 'Correct answer';
  String get cannotLoadDetail =>
      isVi ? 'Không tải được chi tiết' : 'Cannot load detail';

  // —— Payment page ——
  String get paymentTitle => isVi ? 'Thanh toán' : 'Payment';
  String get paymentSuccessToast => isVi ? 'Thanh toán thành công!' : 'Payment successful!';
  String get paymentFailedToast => isVi
      ? 'Thanh toán thất bại. Vui lòng thử lại.'
      : 'Payment failed. Please try again.';
  String get copiedToClipboard => isVi ? 'Đã sao chép' : 'Copied';
  String get qrLoadFailed => isVi
      ? 'Không tải được mã QR.\nKiểm tra kết nối mạng.'
      : 'Could not load QR code.\nCheck your connection.';

  // —— Quiz guard ——
  String get quizLeaveTitle => isVi ? 'Thoát bài làm?' : 'Leave quiz?';
  String get quizLeaveMessage => isVi
      ? 'Bài làm chưa nộp sẽ bị mất. Bạn có chắc muốn thoát?'
      : 'Your unsubmitted answers will be lost. Leave anyway?';
  String get quizKeepDoing => isVi ? 'Tiếp tục làm' : 'Keep going';
  String get quizLeaveConfirm => isVi ? 'Thoát' : 'Leave';
  String get quizSubmitConfirmTitle => isVi ? 'Nộp bài?' : 'Submit quiz?';
  String quizSubmitConfirmMessage(int answered, int total) => isVi
      ? 'Bạn đã trả lời $answered/$total câu. Nộp bài sẽ không sửa lại được.'
      : 'You answered $answered/$total questions. Submission cannot be undone.';

  // —— Logout ——
  String get logoutConfirmTitle => isVi ? 'Đăng xuất?' : 'Log out?';
  String get logoutConfirmMessage => isVi
      ? 'Bạn sẽ cần đăng nhập lại để tiếp tục học.'
      : 'You will need to sign in again to continue.';

  // —— AI chat ——
  String get aiDisclaimer => isVi
      ? 'AI có thể trả lời sai — hãy đối chiếu với sách giáo khoa khi ôn thi.'
      : 'AI can make mistakes — double-check with your textbook when revising.';
  String aiMemoryBadge(String percent) => isVi
      ? 'Câu hỏi tương tự đã gặp ($percent%) — trả lời được dùng lại'
      : 'Similar question seen before ($percent%) — answer reused';
  String get aiMemoryBadgeNoScore => isVi
      ? 'Trả lời được dùng lại từ câu hỏi tương tự'
      : 'Answer reused from a similar question';
  String get aiCopyAnswer => isVi ? 'Sao chép câu trả lời' : 'Copy answer';
  String get aiRetry => isVi ? 'Thử lại' : 'Retry';
  String get aiRateHelpful => isVi ? 'Trả lời hữu ích' : 'Helpful answer';
  String get aiRateUnhelpful =>
      isVi ? 'Trả lời sai hoặc chưa hữu ích' : 'Wrong or unhelpful answer';

  // —— Shop confirm ——
  String buyConfirmMessage(int kp) => isVi
      ? 'Mua thẻ này với $kp KP? Điểm đã trừ không hoàn lại được.'
      : 'Buy this card for $kp KP? Spent points cannot be refunded.';
  String get buyConfirmAction => isVi ? 'Mua' : 'Buy';

  // —— Home dashboard ——
  String get todayStudyTitle => isVi ? 'Hôm nay học gì?' : "Today's study";
  String get streakDaysLabel => isVi ? 'Ngày liên tiếp' : 'Day streak';
  String get quizzesDoneLabel => isVi ? 'Quiz đã làm' : 'Quizzes done';
  String get latestQuizTitle => isVi ? 'Quiz gần nhất' : 'Latest quiz';
  String get recentScansTitle => isVi ? 'Thẻ vừa quét' : 'Recently scanned';
  String get doQuizNow => isVi ? 'Làm ngay' : 'Start';
  String get reviewNow => isVi ? 'Ôn lại' : 'Review';
  String get suggestFirstQuiz => isVi
      ? 'Bắt đầu hành trình với một bài quiz đầu tiên nhé!'
      : 'Start your journey with your first quiz!';
  String suggestReviewLesson(String lesson) => isVi
      ? 'Hôm nay ôn lại bài "$lesson" nhé? Lần trước điểm chưa cao đâu.'
      : 'Review "$lesson" today? Your last score has room to grow.';
  String get suggestNextQuiz => isVi
      ? 'Điểm lần trước tốt lắm! Thử một bài quiz mới hôm nay?'
      : 'Great score last time! Try a new quiz today?';

  // —— Flashcard review ——
  String get reviewTitle => isVi ? 'Ôn thẻ' : 'Card review';
  String get reviewFlip => isVi ? 'Lật thẻ' : 'Flip card';
  String get reviewKnown => isVi ? 'Đã thuộc' : 'I knew it';
  String get reviewUnknown => isVi ? 'Chưa thuộc' : 'Still learning';
  String get reviewAllDone => isVi
      ? 'Tuyệt! Không còn thẻ nào đến hạn ôn hôm nay.\nQuay lại vào ngày mai nhé.'
      : 'Great! No cards due today.\nCome back tomorrow.';
  String get reviewNoCards => isVi
      ? 'Chưa có thẻ để ôn.\nMở khóa thẻ trong Thư viện để bắt đầu.'
      : 'No cards to review yet.\nUnlock cards in your Library to start.';
  String get reviewOfflineBanner => isVi
      ? 'Đang ôn ngoại tuyến bằng dữ liệu đã lưu'
      : 'Reviewing offline with saved data';
  String reviewSummary(int known, int total) => isVi
      ? 'Bạn thuộc $known/$total thẻ!'
      : 'You knew $known/$total cards!';
  String get reviewSummaryPerfect => isVi
      ? 'Hoàn hảo! Các thẻ này sẽ giãn lịch ôn ra xa hơn.'
      : 'Perfect! These cards will come back less often.';
  String reviewSummaryRetry(int count) => isVi
      ? '$count thẻ chưa thuộc sẽ xuất hiện lại ở lượt ôn sau.'
      : '$count cards will show up again next session.';
  String get reviewAgain => isVi ? 'Ôn lượt mới' : 'New session';

  // —— Periodic table ——
  String get periodicTableTitle => isVi ? 'Bảng tuần hoàn' : 'Periodic Table';
  String get periodicSearchHint => isVi
      ? 'Tìm nguyên tố (Fe, Sắt, 26...)'
      : 'Search element (Fe, Iron, 26...)';
  String get atomicMassLabel =>
      isVi ? 'Khối lượng nguyên tử' : 'Atomic mass';
  String get electronegativityLabel =>
      isVi ? 'Độ âm điện (Pauling)' : 'Electronegativity (Pauling)';
  String get electronConfigLabel =>
      isVi ? 'Cấu hình electron' : 'Electron configuration';
  String get periodLabel => isVi ? 'Chu kỳ' : 'Period';
  // groupLabel dùng chung key đã có sẵn ở phần khai báo phía trên (dòng ~438).
  String get lanthanideRowLabel => isVi ? 'Họ Lantan' : 'Lanthanide';
  String get actinideRowLabel => isVi ? 'Họ Actini' : 'Actinide';
  String get arCardAvailable => isVi
      ? 'Nguyên tố này có thẻ AR trong bộ LABEDU!'
      : 'This element has an AR card in the LABEDU set!';
  String get scanArCard => isVi ? 'Quét thẻ AR' : 'Scan AR card';

  // —— AR asset loading ——
  String get arPreparingAssets =>
      isVi ? 'Đang chuẩn bị dữ liệu AR...' : 'Preparing AR assets...';
  String get arPrepareFailed => isVi
      ? 'Không chuẩn bị được dữ liệu AR. Kiểm tra kết nối mạng rồi thử lại.'
      : 'Could not prepare AR assets. Check your connection and try again.';
  String get arExtracting => isVi
      ? 'Đang giải nén dữ liệu AR, vui lòng chờ hoàn tất.'
      : 'Extracting AR data, please wait.';
  String get tryAgainAction => isVi ? 'Thử lại' : 'Try again';
  String knowledgePoints(int n) => '$n KP';

  // —— Feedback list & detail ——
  String cannotLoadFeedback(String e) =>
      isVi ? 'Không tải được feedback: $e' : 'Cannot load feedback: $e';
  String cannotLoadFeedbackDetail(String e) => isVi
      ? 'Không tải được chi tiết feedback: $e'
      : 'Cannot load feedback detail: $e';
  String get feedbackDetailTitle => isVi ? 'Chi tiết feedback' : 'Feedback detail';
  String get sender => isVi ? 'Người gửi' : 'Sender';
  String get typeLabel => isVi ? 'Loại' : 'Type';
  String get priorityLabel => isVi ? 'Độ ưu tiên' : 'Priority';
  String get appVersionLabel => 'App version';
  String get deviceLabel => isVi ? 'Thiết bị' : 'Device';
  String get sentDateLabel => isVi ? 'Ngày gửi' : 'Sent date';
  String get updatedDateLabel => isVi ? 'Cập nhật' : 'Updated';
  String get unknown => isVi ? 'Không rõ' : 'Unknown';

  // —— AI conversation drawer ——
  String get deleteConversationTitle =>
      isVi ? 'Xóa cuộc trò chuyện?' : 'Delete conversation?';
  String get deleteAction => isVi ? 'Xóa' : 'Delete';

  // —— Mini game ——
  String get miniGameChemistryTitle =>
      isVi ? 'Mini Game Hóa Học' : 'Chemistry Mini Game';
  String get testYourKnowledge => isVi
      ? 'Kiểm tra kiến thức\nHóa học của bạn!'
      : 'Test your chemistry\nknowledge!';
  String get gameMode => isVi ? 'Chế độ chơi' : 'Game mode';
  String get playQuiz => isVi ? 'Chơi Quiz' : 'Play Quiz';
  String get playQuizDesc => isVi
      ? 'Trả lời câu hỏi trắc nghiệm về bảng tuần hoàn'
      : 'Answer quiz questions about the periodic table';
  String get learnPoem => isVi ? 'Học Bài Thơ' : 'Learn Poems';
  String get learnPoemDesc => isVi
      ? 'Đọc bài thơ hóa học và khám phá bảng nguyên tố'
      : 'Read chemistry poems and explore the periodic table';
  String get chooseDifficulty => isVi ? 'Chọn độ khó' : 'Choose difficulty';
  String get questionsLabel => isVi ? 'Câu hỏi' : 'Questions';
  String get questionTypesLabel => isVi ? 'Loại câu hỏi' : 'Question types';
  String get elementsLabel => isVi ? 'Nguyên tố' : 'Elements';
  String get exitQuizTitle => isVi ? 'Thoát khỏi quiz?' : 'Exit quiz?';
  String get exitQuizMessage => isVi
      ? 'Tiến trình hiện tại sẽ không được lưu.'
      : 'Current progress will not be saved.';
  String get exit => isVi ? 'Thoát' : 'Exit';
  String get viewResults => isVi ? 'Xem kết quả' : 'View results';
  String get exactAnswer => isVi ? 'Chính xác!' : 'Correct!';
  String get wrongAnswer => isVi ? 'Chưa đúng!' : 'Not quite!';
  String get fillInPoem => isVi ? 'Điền vào bài thơ' : 'Fill in the poem';
  String get fillBlankInstruction => isVi
      ? 'Điền vào chỗ trống (___) trong đoạn thơ trên:'
      : 'Fill in the blank (___) in the poem above:';
  String get results => isVi ? 'Kết quả' : 'Results';
  String get excellent => isVi ? 'Xuất sắc! 🎉' : 'Excellent! 🎉';
  String get goodJob =>
      isVi ? 'Khá tốt! Cố gắng hơn nhé.' : 'Good job! Keep trying.';
  String get needReview => isVi ? 'Cần ôn tập thêm!' : 'Need more review!';
  String get backToMenu => isVi ? 'Về menu' : 'Back to menu';
  String get playAgain => isVi ? 'Chơi lại' : 'Play again';
  String get poemLabel => isVi ? 'Bài thơ:' : 'Poem:';
  String get skippedAnswer => isVi ? 'Bỏ qua' : 'Skipped';
  String get learnPoemTitle => isVi ? 'Học Bài Thơ' : 'Learn Poems';
  String get atomicMassTab => isVi ? 'Khối lượng' : 'Atomic mass';
  String get valenceTab => isVi ? 'Hóa trị' : 'Valence';
  String get elementsTab => isVi ? 'Nguyên tố' : 'Elements';
  String get atomicMassPoemTitle =>
      isVi ? 'Bài thơ Khối lượng Nguyên tử' : 'Atomic Mass Poem';
  String get valencePoemTitle => isVi ? 'Bài thơ Hóa trị' : 'Valence Poem';
  String get quickLookupTable => isVi ? 'Bảng tra cứu nhanh' : 'Quick lookup table';
  String get valenceLookupTable => isVi ? 'Bảng tra cứu hóa trị' : 'Valence lookup table';
  String get searchElementHint => isVi
      ? 'Tìm nguyên tố (tên, ký hiệu)…'
      : 'Search element (name, symbol)…';
  String get atomicMassShort => isVi ? 'Khối lượng NTK' : 'Atomic mass';
  String get valenceShort => isVi ? 'Hóa trị' : 'Valence';
  String get atomicMassPoemLabel =>
      isVi ? 'Bài thơ KL nguyên tử:' : 'Atomic mass poem:';
  String get valencePoemLabel => isVi ? 'Bài thơ Hóa trị:' : 'Valence poem:';

  String get miniGameHeroSubtitle => isVi
      ? '300+ câu hỏi • 10 loại câu hỏi\nKhối lượng nguyên tử & Hóa trị'
      : '300+ questions • 10 question types\nAtomic mass & Valence';
  String get difficultyEasy => isVi ? 'Dễ' : 'Easy';
  String get difficultyMedium => isVi ? 'Trung bình' : 'Medium';
  String get difficultyHard => isVi ? 'Khó' : 'Hard';
  String get difficultyEasyDesc => isVi ? '20 câu hỏi' : '20 questions';
  String get difficultyMediumDesc => isVi ? '30 câu hỏi' : '30 questions';
  String get difficultyHardDesc => isVi ? '40 câu hỏi' : '40 questions';

  // —— AR camera screen ——
  String get arCamera => isVi ? 'Camera AR' : 'AR Camera';
  String get arCoreReady => isVi
      ? 'ARCore/ARKit sẵn sàng tích hợp'
      : 'ARCore/ARKit integration ready';

  // —— Package subtitles ——
  String get premiumBasicSubtitle => isVi
      ? 'Mở khóa tính năng premium cơ bản'
      : 'Unlock basic premium features';
  String get premiumFullSubtitle => isVi
      ? 'Mở khóa tất cả tính năng premium'
      : 'Unlock all premium features';
  String get arLifetimeSubtitle =>
      isVi ? 'Truy cập AR vĩnh viễn' : 'Permanent AR access';

  // —— Common ——
  String get amount => isVi ? 'Số tiền' : 'Amount';

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
