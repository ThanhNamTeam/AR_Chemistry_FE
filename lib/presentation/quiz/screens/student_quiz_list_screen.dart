import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/api/student_reaction_quiz_api.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/student_reaction_quiz_models.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import 'quiz_attempt_flow_screen.dart';

/// Màn Quiz theo contract MỚI: duyệt PHẢN ỨNG theo lớp + nhóm, thay cho
/// danh sách "quiz đã xuất bản" theo bài học (endpoint cũ đã bị backend gỡ).
///
/// Backend trả sẵn cờ hành động cho từng phản ứng (canStart / canContinue /
/// canViewHistory / canRetry) — UI chỉ tuân theo, không tự suy diễn.
class StudentQuizListScreen extends StatefulWidget {
  const StudentQuizListScreen({super.key});

  @override
  State<StudentQuizListScreen> createState() => _StudentQuizListScreenState();
}

class _StudentQuizListScreenState extends State<StudentQuizListScreen> {
  final _api = StudentReactionQuizApi();
  final _searchCtrl = TextEditingController();

  static const _grades = [8, 9, 10, 11, 12];
  static const _categories = ['METAL', 'ACID', 'BASE', 'SALT'];

  int _grade = 8;
  String _category = 'METAL';
  String _keyword = '';
  Timer? _debounce;

  final List<StudentReactionModel> _reactions = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasNext = false;
  int _page = 0;
  String? _error;

  /// Chống bấm đúp "Bắt đầu" tạo 2 attempt.
  String? _startingReactionId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getReactions(
        grade: _grade,
        reactionCategory: _category,
        keyword: _keyword,
        page: 0,
      );
      if (!mounted) return;
      setState(() {
        _reactions
          ..clear()
          ..addAll(data.items);
        _hasNext = data.hasNext;
        _page = 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasNext) return;
    setState(() => _loadingMore = true);
    try {
      final data = await _api.getReactions(
        grade: _grade,
        reactionCategory: _category,
        keyword: _keyword,
        page: _page + 1,
      );
      if (!mounted) return;
      setState(() {
        _reactions.addAll(data.items);
        _hasNext = data.hasNext;
        _page += 1;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _keyword = value;
      _reload();
    });
  }

  Future<void> _openFlow(String attemptCode, StudentReactionModel r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizAttemptFlowScreen(
          attemptCode: attemptCode,
          reactionName: r.reactionName,
          equation: r.equation,
        ),
      ),
    );
    if (mounted) _reload(); // trạng thái phản ứng đổi sau khi làm bài
  }

  Future<void> _start(StudentReactionModel r) async {
    if (_startingReactionId != null) return;
    setState(() => _startingReactionId = r.reactionId);
    try {
      final started = await _api.startAttempt(r.reactionId);
      if (!mounted) return;
      setState(() => _startingReactionId = null);
      await _openFlow(started.attemptCode, r);
    } catch (_) {
      if (!mounted) return;
      setState(() => _startingReactionId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).quizStartFailed,
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openHistory(StudentReactionModel r) {
    Navigator.pushNamed(
      context,
      AppRoutes.quizHistory,
      arguments: {
        'reactionId': r.reactionId,
        'reactionName': r.reactionName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('quiz_list_screen'),
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _Header(l10n: l10n),
              _buildFilters(l10n),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _reload,
                  child: _buildList(l10n),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: l10n.quizSearchReactionHint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 13,
              ),
              prefixIcon:
                  Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              isDense: true,
              filled: true,
              fillColor: AppColors.cardSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.cardBorder.withValues(alpha: .5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.cardBorder.withValues(alpha: .5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  '${l10n.quizGradeLabel}: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
                ..._grades.map((g) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('$g'),
                        selected: _grade == g,
                        onSelected: (_) {
                          if (_grade == g) return;
                          setState(() => _grade = g);
                          _reload();
                        },
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(l10n.quizCategoryLabel(c)),
                          selected: _category == c,
                          onSelected: (_) {
                            if (_category == c) return;
                            setState(() => _category = c);
                            _reload();
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 40),
          Icon(Icons.wifi_off, size: 40, color: AppColors.error),
          const SizedBox(height: 10),
          Text(
            l10n.quizReactionsLoadFailed,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton(
              onPressed: _reload,
              child: Text(l10n.userMgmtRetry),
            ),
          ),
        ],
      );
    }
    if (_reactions.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 60),
          Center(
            child: Text(
              l10n.quizNoReactions,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        ..._reactions.map((r) => _ReactionCard(
              reaction: r,
              starting: _startingReactionId == r.reactionId,
              onStart: () => _start(r),
              onContinue: r.activeAttemptCode == null
                  ? null
                  : () => _openFlow(r.activeAttemptCode!, r),
              onHistory: () => _openHistory(r),
            )),
        if (_hasNext)
          Center(
            child: TextButton(
              onPressed: _loadingMore ? null : _loadMore,
              child: _loadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.userMgmtLoadMore),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quizBrowseTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.quizBrowseSubtitle,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionCard extends StatelessWidget {
  const _ReactionCard({
    required this.reaction,
    required this.starting,
    required this.onStart,
    required this.onContinue,
    required this.onHistory,
  });

  final StudentReactionModel reaction;
  final bool starting;
  final VoidCallback onStart;
  final VoidCallback? onContinue;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = reaction;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: .55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.reactionName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (r.hasRunningAttempt)
                _Badge(
                  text: l10n.quizInProgressBadge,
                  color: AppColors.warning,
                )
              else if (r.completed)
                _Badge(
                  text: l10n.quizCompletedBadge,
                  color: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            r.equation,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.subtitleAccent,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (r.canContinue && onContinue != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onContinue,
                    child: Text(l10n.quizContinue),
                  ),
                )
              else if (r.canStart || r.canRetry)
                Expanded(
                  child: ElevatedButton(
                    onPressed: starting ? null : onStart,
                    child: starting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(r.canRetry && r.completed
                            ? l10n.quizRetry
                            : l10n.quizStart),
                  ),
                ),
              if (r.canViewHistory) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onHistory,
                  child: Text(l10n.quizHistoryAction),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
