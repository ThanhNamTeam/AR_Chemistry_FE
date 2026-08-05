import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/inventory_api.dart';
import '../../../core/api/library_api.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/models/response/library_card_response.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final LibraryApi _libraryApi = LibraryApi();
  final InventoryApi _inventoryApi = InventoryApi();
  final ScrollController _allCardsScrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 0;
  int _totalCards = 0;
  bool _hasNext = false;

  List<LibraryCardResponse> _cards = [];
  Set<String> _unlockedSubstanceIds = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _allCardsScrollController.addListener(_onAllCardsScroll);
    _loadLibrary(refresh: true);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _allCardsScrollController.dispose();
    super.dispose();
  }

  void _onAllCardsScroll() {
    if (!_allCardsScrollController.hasClients) return;

    final position = _allCardsScrollController.position;

    if (position.pixels >= position.maxScrollExtent - 160) {
      if (!_isLoading && !_isLoadingMore && _hasNext) {
        _loadLibrary(refresh: false);
      }
    }
  }

  Future<void> _loadLibrary({
    bool refresh = false,
  }) async {
    if (_isLoadingMore) return;

    if (refresh) {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _errorMessage = null;
        _currentPage = 0;
        _totalCards = 0;
        _hasNext = false;
        _cards = [];
        _unlockedSubstanceIds = {};
      });
    } else {
      setState(() {
        _isLoadingMore = true;
        _errorMessage = null;
      });
    }

    try {
      final nextPage = refresh ? 0 : _currentPage + 1;

      final results = await Future.wait([
        _libraryApi.getLibraryCards(
          page: nextPage,
          size: 10,
        ),
        if (refresh)
          _inventoryApi.getMyInventory(
            page: 0,
            size: 200,
          ),
      ]);

      final libraryPage = results[0] as dynamic;

      Set<String> unlockedIds = _unlockedSubstanceIds;

      if (refresh && results.length > 1) {
        final inventoryPage = results[1] as dynamic;

        unlockedIds = inventoryPage.items
            .map<String>((item) => item.substanceId.toString())
            .toSet();
      }

      if (!mounted) return;

      setState(() {
        _currentPage = libraryPage.page;
        _totalCards = libraryPage.totalItems;
        _hasNext = libraryPage.hasNext;
        _unlockedSubstanceIds = unlockedIds;

        if (refresh) {
          _cards = List<LibraryCardResponse>.from(libraryPage.items);
        } else {
          _cards = [
            ..._cards,
            ...List<LibraryCardResponse>.from(libraryPage.items),
          ];
        }

        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  List<LibraryCardResponse> get _unlockedCards {
    return _cards
        .where((card) => _unlockedSubstanceIds.contains(card.substanceId))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<LocaleProvider>();
    context.watch<ThemeProvider>();
    final unlockedCount = _unlockedSubstanceIds.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Expanded + ellipsis: tiêu đề co lại khi header chật,
                    // Text cứng + Spacer từng làm Row tràn 7px khi thêm nút Ôn thẻ.
                    Expanded(
                      child: Text(
                        l10n.myLibrary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Lối vào chế độ Ôn thẻ (flashcard, offline được).
                    Semantics(
                      button: true,
                      label: l10n.reviewTitle,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.flashcardReview,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.cyanEmeraldGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.style_outlined,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                l10n.reviewTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '$unlockedCount/$_totalCards',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.subtitleAccent,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    gradient: AppColors.cyanEmeraldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: [
                    Tab(text: l10n.libraryTabUnlocked),
                    Tab(text: l10n.libraryTabAllCards),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadLibrary(refresh: true),
                  child: _buildBody(l10n),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 140),
          Icon(
            Icons.error_outline,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cannotLoadLibrary,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
        ],
      );
    }

    return TabBarView(
      controller: _tabCtrl,
      children: [
        _buildCardsGrid(
          l10n: l10n,
          cards: _unlockedCards,
          emptyTitle: l10n.libraryNoUnlockedCards,
          emptySubtitle: l10n.libraryActivateKitHint,
          useScrollController: false,
        ),
        _buildCardsGrid(
          l10n: l10n,
          cards: _cards,
          emptyTitle: l10n.libraryNoCardsFound,
          emptySubtitle: l10n.libraryCardsAppearHere,
          useScrollController: true,
        ),
      ],
    );
  }

  Widget _buildCardsGrid({
    required AppLocalizations l10n,
    required List<LibraryCardResponse> cards,
    required String emptyTitle,
    required String emptySubtitle,
    required bool useScrollController,
  }) {
    if (cards.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 140),
          Icon(
            Icons.menu_book_outlined,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            emptyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            emptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      controller: useScrollController ? _allCardsScrollController : null,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: cards.length + (useScrollController && _isLoadingMore ? 1 : 0),
      itemBuilder: (ctx, index) {
        if (index >= cards.length) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final card = cards[index];
        final unlocked = _unlockedSubstanceIds.contains(card.substanceId);

        return _LibraryCardTile(
          card: card,
          unlocked: unlocked,
          onTap: () {
            if (unlocked) {
              Navigator.pushNamed(
                context,
                AppRoutes.substanceDetail,
                arguments: card.substanceId,
              );
              return;
            }

            _showLockedMessage(card, l10n);
          },
        );
      },
    );
  }

  void _showLockedMessage(LibraryCardResponse card, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.cardLockedSnackbar(card.displayName),
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: AppColors.backgroundMid,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _LibraryCardTile extends StatelessWidget {
  final LibraryCardResponse card;
  final bool unlocked;
  final VoidCallback onTap;

  const _LibraryCardTile({
    required this.card,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stateColor = AppColors.substanceStateColor(card.state);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: unlocked ? 1 : 0.48,
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unlocked
                  ? AppColors.substanceStateBorder(card.state)
                  : AppColors.cardBorder.withOpacity(0.35),
              width: 1.2,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      card.displayFormula,
                      style: TextStyle(
                        color: unlocked ? stateColor : AppColors.textSecondary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    unlocked ? card.displayName : l10n.lockedCard,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unlocked
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? stateColor.withOpacity(0.14)
                          : AppColors.textSecondary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: unlocked
                            ? stateColor.withOpacity(0.35)
                            : AppColors.textSecondary.withOpacity(0.22),
                      ),
                    ),
                    child: Text(
                      unlocked ? l10n.cardUnlockedLabel : l10n.cardLockedLabel,
                      style: TextStyle(
                        color: unlocked ? stateColor : AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
              if (!unlocked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
