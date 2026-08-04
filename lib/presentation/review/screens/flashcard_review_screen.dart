import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/inventory_api.dart';
import '../../../core/api/reaction_api.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/flashcard_review_service.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/app_state.dart';
import '../../home/providers/theme_provider.dart';

/// Chế độ Ôn thẻ (flashcard) — offline-first.
///
/// Dữ liệu: chất đã mở khoá (inventory) + phản ứng có sẵn của backend, cache
/// local sau mỗi lần tải thành công; không mạng thì ôn bằng cache. Trạng thái
/// thuộc/chưa thuộc chấm theo Leitner (0 → 3 → 7 → 21 ngày) lưu theo email.
class FlashcardReviewScreen extends StatefulWidget {
  const FlashcardReviewScreen({super.key});

  /// Mỗi lượt ôn tối đa bao nhiêu thẻ đến hạn.
  static const int sessionSize = 20;

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen> {
  final InventoryApi _inventoryApi = InventoryApi();
  final ReactionApi _reactionApi = ReactionApi();

  bool _loading = true;
  bool _offline = false;
  String _email = '';

  List<ReviewCard> _session = [];
  Map<String, CardMastery> _mastery = {};
  int _index = 0;
  bool _flipped = false;
  int _knownCount = 0;
  int _totalDeckSize = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    _email = context.read<AppState>().userEmail ?? '';

    // 1. Thử tải mới từ backend, thành công thì cache lại.
    var substances = <CachedSubstance>[];
    var reactions = <CachedReaction>[];
    var networkOk = true;

    try {
      final inventory = await _inventoryApi.getMyInventory(page: 0, size: 200);
      substances = inventory.items
          .map((item) => CachedSubstance(
                id: item.substanceId,
                formula: item.formula ?? '',
                vietnameseName: item.vietnameseName ?? item.name ?? '',
                englishName: item.name,
                chemicalGroup: item.chemicalGroup,
                state: item.state,
              ))
          .where((s) => s.formula.isNotEmpty)
          .toList();
      await FlashcardReviewService.saveSubstances(_email, substances);
    } catch (_) {
      networkOk = false;
    }

    try {
      reactions = await _reactionApi.getActiveReactions();
      await FlashcardReviewService.saveReactions(_email, reactions);
    } catch (_) {
      networkOk = false;
    }

    // 2. Mạng hỏng phần nào thì lấy phần đó từ cache (offline-first).
    if (substances.isEmpty) {
      substances = await FlashcardReviewService.loadSubstances(_email);
    }
    if (reactions.isEmpty) {
      reactions = await FlashcardReviewService.loadReactions(_email);
    }

    _mastery = await FlashcardReviewService.loadMastery(_email);

    final deck = FlashcardReviewService.buildDeck(
      substances: substances,
      reactions: reactions,
    );
    final due = FlashcardReviewService.dueCards(
      deck,
      _mastery,
      now: DateTime.now(),
    )..shuffle(Random());

    if (!mounted) return;
    setState(() {
      _totalDeckSize = deck.length;
      _session = due.take(FlashcardReviewScreen.sessionSize).toList();
      _offline = !networkOk && deck.isNotEmpty;
      _loading = false;
    });
  }

  Future<void> _mark(bool known) async {
    final card = _session[_index];
    _mastery = FlashcardReviewService.markResult(
      _mastery,
      card.key,
      known: known,
      now: DateTime.now(),
    );
    await FlashcardReviewService.saveMastery(_email, _mastery);

    if (!mounted) return;
    setState(() {
      if (known) _knownCount++;
      _flipped = false;
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(l10n),
              if (_offline) _buildOfflineBanner(l10n),
              Expanded(child: _buildBody(l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: l10n.back,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child:
                    Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.reviewTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
          if (!_loading && _session.isNotEmpty && _index < _session.length)
            Text(
              '${_index + 1}/${_session.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.reviewOfflineBanner,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_session.isEmpty) {
      // Không có thẻ đến hạn (hoặc chưa mở khoá thẻ nào).
      final hasDeck = _totalDeckSize > 0;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasDeck ? Icons.celebration_outlined : Icons.style_outlined,
                size: 56,
                color: hasDeck ? AppColors.success : AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                hasDeck ? l10n.reviewAllDone : l10n.reviewNoCards,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_index >= _session.length) {
      return _buildSummary(l10n);
    }

    final card = _session[_index];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        children: [
          Expanded(child: _buildFlipCard(card)),
          const SizedBox(height: 20),
          if (!_flipped)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _flipped = true),
                icon: const Icon(Icons.flip, size: 18),
                label: Text(l10n.reviewFlip),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _mark(false),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.reviewUnknown),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.error.withValues(alpha: 0.15),
                      foregroundColor: AppColors.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _mark(true),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l10n.reviewKnown),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(ReviewCard card) {
    return GestureDetector(
      onTap: () => setState(() => _flipped = !_flipped),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, animation) {
          // Lật quanh trục Y: nửa đầu thu nhỏ mặt cũ, nửa sau mở mặt mới.
          final rotate = Tween(begin: 1.0, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final angle = (1 - rotate.value) * 3.14159;
              final visible = angle < 3.14159 / 2 || angle > 3.14159 * 1.5;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(visible ? angle : angle - 3.14159),
                child: child,
              );
            },
          );
        },
        child: Container(
          key: ValueKey(_flipped ? 'back-${card.key}' : 'front-${card.key}'),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _flipped
                  ? AppColors.secondary.withValues(alpha: 0.5)
                  : AppColors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(color: AppColors.shadowSoft, blurRadius: 16),
            ],
          ),
          child: _flipped ? _buildBack(card) : _buildFront(card),
        ),
      ),
    );
  }

  Widget _buildFront(ReviewCard card) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            card.frontHint,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.accentText,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
        const SizedBox(height: 24),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            card.front,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: card.type == ReviewCardType.reaction ? 24 : 40,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBack(ReviewCard card) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < card.backLines.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Text(
            card.backLines[i],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: i == 0 ? 26 : 14,
              fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w500,
              color: i == 0 ? AppColors.textPrimary : AppColors.textSecondary,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummary(AppLocalizations l10n) {
    final total = _session.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _knownCount == total
                  ? Icons.emoji_events_outlined
                  : Icons.flag_outlined,
              size: 56,
              color: _knownCount == total
                  ? AppColors.amberLight
                  : AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.reviewSummary(_knownCount, total),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _knownCount == total
                  ? l10n.reviewSummaryPerfect
                  : l10n.reviewSummaryRetry(total - _knownCount),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _index = 0;
                    _knownCount = 0;
                    _flipped = false;
                  });
                  _load();
                },
                child: Text(l10n.reviewAgain),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }
}
