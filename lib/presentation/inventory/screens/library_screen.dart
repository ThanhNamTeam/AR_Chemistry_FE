import 'package:flutter/material.dart';

import '../../../core/api/inventory_api.dart';
import '../../../core/api/library_api.dart';
import '../../../core/models/response/library_card_response.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';

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
                    Text(
                      'My Library',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'Unlocked'),
                    Tab(text: 'All Cards'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadLibrary(refresh: true),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
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
            'Cannot load library',
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
          cards: _unlockedCards,
          emptyTitle: 'No unlocked cards yet',
          emptySubtitle: 'Activate a kit to unlock cards in your library',
          useScrollController: false,
        ),
        _buildCardsGrid(
          cards: _cards,
          emptyTitle: 'No cards found',
          emptySubtitle: 'Library cards will appear here',
          useScrollController: true,
        ),
      ],
    );
  }

  Widget _buildCardsGrid({
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

            _showLockedMessage(card);
          },
        );
      },
    );
  }

  void _showLockedMessage(LibraryCardResponse card) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${card.displayName} is locked. Activate a kit to unlock this card.',
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
    final stateColor = AppColors.substanceStateColor(card.state);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: unlocked ? 1 : 0.48,
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(18),
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
                    unlocked ? card.displayName : 'Locked Card',
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
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: unlocked
                            ? stateColor.withOpacity(0.35)
                            : AppColors.textSecondary.withOpacity(0.22),
                      ),
                    ),
                    child: Text(
                      unlocked ? 'Unlocked' : 'Locked',
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