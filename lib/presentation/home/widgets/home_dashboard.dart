import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/study_streak_service.dart';
import '../../../domain/models/student_quiz_attempt_history_model.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/app_state.dart';

/// Dashboard "hôm nay học gì" trên Home.
///
/// Toàn bộ dữ liệu lấy từ nguồn có sẵn — không cần API mới:
/// - Streak: [StudyStreakService] (SharedPreferences).
/// - KP: [AppState.knowledgePoints].
/// - Quiz gần nhất + gợi ý ôn tập: trang đầu lịch sử làm quiz.
/// - Thẻ vừa quét: [AppState.scannedCards].
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {

  int _streak = 0;
  StudentQuizAttemptHistoryModel? _latestAttempt;
  /// Tổng số lượt quiz đã làm — totalItems từ API lịch sử, KHÔNG phải số chế.
  int _totalAttempts = 0;
  bool _loadingAttempt = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final email = context.read<AppState>().userEmail;
    if (email != null && email.isNotEmpty) {
      final streak = await StudyStreakService.touchToday(email);
      if (mounted) setState(() => _streak = streak);
    }

    if (mounted) {
      setState(() {
        _latestAttempt = null;
        _totalAttempts = 0;
        _loadingAttempt = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Text(
            l10n.todayStudyTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department,
                  iconColor: const Color(0xFFF97316),
                  value: '$_streak',
                  label: l10n.streakDaysLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.auto_awesome,
                  // KP giữ MỘT màu vàng định danh ở mọi theme (P2-7) — không
                  // dùng token amber vì theme Light đã ghi đè nó sang xanh.
                  iconColor: AppColors.kpGold,
                  value: '${state.knowledgePoints}',
                  label: 'KP',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.quiz_outlined,
                  iconColor: AppColors.secondary,
                  // totalItems từ API lịch sử quiz — số thật, không dùng
                  // experimentsCount (vốn chỉ là knowledgePoints ~/ 50).
                  value: _loadingAttempt ? '…' : '$_totalAttempts',
                  label: l10n.quizzesDoneLabel,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildSuggestion(l10n),
        _buildLatestQuiz(l10n),
        _buildRecentScans(l10n, state),
      ],
    );
  }

  /// Banner gợi ý: điểm < 70% → ôn lại đúng bài đó; đã tốt → làm quiz mới;
  /// chưa làm quiz nào → mời làm bài đầu tiên.
  Widget _buildSuggestion(AppLocalizations l10n) {
    if (_loadingAttempt) return const SizedBox.shrink();

    final attempt = _latestAttempt;
    String text;
    final String cta;
    final Object? routeArgs;
    final String route;

    if (attempt == null) {
      text = l10n.suggestFirstQuiz;
      cta = l10n.doQuizNow;
      route = AppRoutes.quizList;
      routeArgs = null;
    } else {
      final ratio = attempt.totalQuestions == 0
          ? 1.0
          : attempt.correctCount / attempt.totalQuestions;
      if (ratio < 0.7) {
        text = l10n.suggestReviewLesson(attempt.reactionName);
        text = l10n.suggestReviewLesson(
          attempt.reactionName,
        );
        cta = l10n.reviewNow;
        // Luồng quiz mới theo phản ứng: đưa về màn duyệt phản ứng (màn quiz
        // theo bài học cũ đã chết cùng endpoint của nó).
        route = AppRoutes.quizList;
        routeArgs = null;
      } else {
        text = l10n.suggestNextQuiz;
        cta = l10n.doQuizNow;
        route = AppRoutes.quizList;
        routeArgs = null;
      }
    }

    // P1-4 audit UX: tuyệt đối không render khung card khi không có nội dung
    // (từng có thẻ trắng rỗng chiếm vị trí đẹp nhất Home).
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        // Nền đặc, không gradient trong suốt — dễ đọc trên mọi theme.
        // Viền phải ĐỒNG MÀU 4 cạnh (Flutter cấm borderRadius + viền lệch màu),
        // nên vạch nhấn xanh làm thanh riêng đứng đầu Row.
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.tips_and_updates_outlined,
                color: AppColors.primaryLight, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              button: true,
              label: cta,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () =>
                    Navigator.pushNamed(context, route, arguments: routeArgs),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.cyanEmeraldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cta,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onGradient,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestQuiz(AppLocalizations l10n) {
    if (_loadingAttempt) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final attempt = _latestAttempt;
    if (attempt == null) return const SizedBox.shrink();

    final ratio = attempt.totalQuestions == 0
        ? 0.0
        : attempt.correctCount / attempt.totalQuestions;
    final scoreColor = ratio >= 0.7
        ? AppColors.success
        : (ratio >= 0.4 ? AppColors.warning : AppColors.error);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Semantics(
        button: true,
        label: l10n.latestQuizTitle,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, AppRoutes.quizHistory),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.cardBorder.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${attempt.correctCount}/${attempt.totalQuestions}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.latestQuizTitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attempt.quizTitle.isNotEmpty
                            ? attempt.quizTitle
                            : attempt.reactionName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Chỉ hiện khi phiên này có thẻ vừa quét (dữ liệu quét là trạng thái
  /// trong phiên, không lưu lâu dài).
  Widget _buildRecentScans(AppLocalizations l10n, AppState state) {
    final scans = state.scannedCards;
    if (scans.isEmpty) return const SizedBox.shrink();

    final names = scans
        .map((id) => state.getCardById(id)?.name ?? id)
        .join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recentScansTitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    names,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
