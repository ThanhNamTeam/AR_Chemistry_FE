import 'package:flutter/foundation.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../../domain/models/account_setup_model.dart';
import '../../../domain/models/bundle_price_quote.dart';
import '../../../domain/models/cart_item_model.dart';
import '../../../domain/models/chemical_card_model.dart';
import '../../../domain/models/login_route_args.dart';
import '../../../domain/models/my_bag_item_model.dart';

class AppState extends ChangeNotifier {
  static const appDisplayName = 'Chemistry AR';
  static const defaultKnowledgePoints = 15000;
  static const defaultStarterUnlocked = ['H', 'O'];

  final LocalStorageService _storage = LocalStorageService();

  bool _initialized = false;
  bool _isLoading = false;

  // Auth state
  String? _userName;
  String? _userEmail;
  String? _userAvatar;
  bool _isLoggedIn = false;
  int _knowledgePoints = defaultKnowledgePoints;

  // Cards state
  final List<ChemicalCardModel> _cards =
      ChemicalData.cards.map((c) => ChemicalCardModel(
            id: c.id,
            symbol: c.symbol,
            name: c.name,
            atomicNumber: c.atomicNumber,
            color: c.color,
            price: c.price,
            category: c.category,
            isUnlocked: c.isUnlocked,
          )).toList();
  final List<CartItem> _cart = [];
  final List<MyBagItem> _myBag = [];
  final List<String> _scannedCards = [];

  bool get initialized => _initialized;
  bool get isLoading => _isLoading;

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userAvatar => _userAvatar;
  bool get isLoggedIn => _isLoggedIn;
  int get knowledgePoints => _knowledgePoints;
  List<ChemicalCardModel> get cards => List.unmodifiable(_cards);
  List<CartItem> get cart => List.unmodifiable(_cart);
  List<MyBagItem> get myBag => List.unmodifiable(_myBag);
  List<String> get scannedCards => List.unmodifiable(_scannedCards);
  List<ChemicalCardModel> get unlockedCards =>
      _cards.where((c) => c.isUnlocked).toList();
  List<ChemicalCardModel> get lockedCards =>
      _cards.where((c) => !c.isUnlocked).toList();
  List<MyBagItem> get pendingBagItems =>
      _myBag.where((i) => i.isPendingActivation).toList();

  int get totalCards => _cards.length;
  int get unlockedCount => unlockedCards.length;
  int get experimentsCount => _knowledgePoints ~/ 50;
  double get libraryProgress =>
      totalCards == 0 ? 0 : unlockedCount / totalCards;

  Future<void> initialize() async {
    if (_initialized) return;
    final token = await _storage.getAuthToken();
    final user = await _storage.getUser();

    if (token != null && user != null) {
      final email = user['email'] as String?;
      if (email != null) {
        _isLoggedIn = true;
        _userName = user['name'] as String?;
        _userEmail = email;
        _userAvatar = user['avatar'] as String?;
        await _loadShopStateForUser(email);
      } else {
        await _resetShopStateInMemory();
      }
    } else {
      await _resetShopStateInMemory();
    }

    _initialized = true;
    notifyListeners();
  }

  void _applyUnlockedIds(List<String> unlockedIds) {
    for (final card in _cards) {
      card.isUnlocked = unlockedIds.contains(card.id) ||
          defaultStarterUnlocked.contains(card.id);
    }
  }

  Future<void> _resetShopStateInMemory() async {
    _knowledgePoints = defaultKnowledgePoints;
    _applyUnlockedIds(defaultStarterUnlocked);
    _myBag.clear();
    _cart.clear();
    _scannedCards.clear();
  }

  Future<void> _loadShopStateForUser(String email) async {
    final kp = await _storage.getUserKnowledgePoints(email);
    final unlockedIds = await _storage.getUserUnlockedCardIds(email);
    final bagRaw = await _storage.getUserMyBag(email);
    final cartRaw = await _storage.getUserCartItems(email);

    _knowledgePoints = kp ?? defaultKnowledgePoints;
    _applyUnlockedIds(
      unlockedIds.isEmpty ? defaultStarterUnlocked : unlockedIds,
    );

    _myBag
      ..clear()
      ..addAll(bagRaw.map(MyBagItem.fromJson));

    _cart
      ..clear()
      ..addAll(cartRaw.map(CartItem.fromJson));
  }

  Future<void> _persistAuth() async {
    if (!_isLoggedIn || _userEmail == null) return;
    await _storage.setUser({
      'name': _userName,
      'email': _userEmail,
      if (_userAvatar != null) 'avatar': _userAvatar,
    });
  }

  Future<void> _persistShop() async {
    final email = _userEmail;
    if (email == null || !_isLoggedIn) return;
    await _storage.setUserUnlockedCardIds(
      email,
      _cards.where((c) => c.isUnlocked).map((c) => c.id).toList(),
    );
    await _storage.setUserMyBag(
      email,
      _myBag.map((e) => e.toJson()).toList(),
    );
    await _storage.setUserCartItems(
      email,
      _cart.map((e) => e.toJson()).toList(),
    );
    await _storage.setUserKnowledgePoints(email, _knowledgePoints);
  }

  // ── Auth ──────────────────────────────────────────────────────────

  Future<({String? error, LoginResult? result})> login(
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    final normalizedEmail = email.trim();
    final registered =
        await _storage.getRegisteredUserByEmail(normalizedEmail);
    if (registered == null) {
      _isLoading = false;
      notifyListeners();
      return (
        error: 'No account found. Please sign up first.',
        result: null,
      );
    }
    if (registered['password'] != password) {
      _isLoading = false;
      notifyListeners();
      return (error: 'Invalid email or password', result: null);
    }

    final fullName =
        registered['fullname'] as String? ?? normalizedEmail.split('@').first;
    final isFirstLogin =
        !await _storage.getUserHasLoggedInBefore(normalizedEmail);

    _isLoggedIn = true;
    _userName = fullName;
    _userEmail = normalizedEmail;
    _userAvatar = null;

    await _loadShopStateForUser(normalizedEmail);

    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.setAuthToken(token);
    await _persistAuth();
    await _storage.setUserHasLoggedInBefore(normalizedEmail, true);

    _isLoading = false;
    notifyListeners();
    return (
      error: null,
      result: LoginResult(isFirstLogin: isFirstLogin, fullName: fullName),
    );
  }

  Future<void> loginWithGoogle({
    required String name,
    required String email,
    String? avatar,
  }) async {
    _isLoggedIn = true;
    _userName = name;
    _userEmail = email.trim();
    _userAvatar = avatar;

    final hasData =
        await _storage.getUserKnowledgePoints(_userEmail!) != null;
    if (!hasData) {
      await _storage.initNewUserShopData(_userEmail!);
    }
    await _loadShopStateForUser(_userEmail!);

    final token = 'google_token_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.setAuthToken(token);
    await _persistAuth();
    await _storage.setUserHasLoggedInBefore(_userEmail!, true);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _userAvatar = null;
    await _storage.clearAuth();
    await _resetShopStateInMemory();
    notifyListeners();
  }

  /// Saves account credentials only — user must log in on the login screen.
  Future<void> registerAccount(AccountSetupData data) async {
    await _storage.setRegisteredUser({
      'fullname': data.fullName,
      'email': data.email,
      'password': data.password,
    });
    await _storage.initNewUserShopData(data.email);

    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _userAvatar = null;
    await _storage.clearAuth();
    await _resetShopStateInMemory();
    notifyListeners();
  }

  /// Google sign-up: profile saved and user is signed in.
  Future<LoginResult> completeGoogleAccountSetup(AccountSetupData data) async {
    await _storage.setRegisteredUser({
      'fullname': data.fullName,
      'email': data.email,
      'password': data.password,
    });

    final isFirstLogin =
        !await _storage.getUserHasLoggedInBefore(data.email);
    if (isFirstLogin) {
      await _storage.initNewUserShopData(data.email);
    }

    _isLoggedIn = true;
    _userName = data.fullName;
    _userEmail = data.email.trim();

    await _loadShopStateForUser(_userEmail!);

    final token = 'google_token_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.setAuthToken(token);
    await _persistAuth();
    await _storage.setUserHasLoggedInBefore(_userEmail!, true);
    notifyListeners();

    return LoginResult(isFirstLogin: isFirstLogin, fullName: data.fullName);
  }

  // ── Knowledge Points ────────────────────────────────────────────────

  Future<void> addKnowledgePoints(int points) async {
    _knowledgePoints += points;
    await _persistShop();
    notifyListeners();
  }

  bool deductKnowledgePoints(int points) {
    if (_knowledgePoints >= points) {
      _knowledgePoints -= points;
      _persistShop();
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── Shop helpers ────────────────────────────────────────────────────

  bool isCardOwned(String cardId) {
    final card = getCardById(cardId);
    if (card == null) return false;
    return card.isUnlocked || isInMyBag(cardId);
  }

  List<ChemicalCardModel> get shopCatalogCards =>
      _cards.where((c) => c.id != 'H' && c.id != 'O').toList();

  BundlePriceQuote getBundleQuote(String bundleId) {
    final bundle = ChemicalData.bundles.firstWhere(
      (b) => b.id == bundleId,
      orElse: () => throw Exception('Bundle not found'),
    );
    return BundlePricing.calculate(
      bundle,
      isCardOwned,
      (id) => getCardById(id)?.price ?? 0,
    );
  }

  bool isBundleInCart(String bundleId) =>
      _cart.any((i) => i.type == CartItemType.bundle && i.id == bundleId);

  // ── Cart ────────────────────────────────────────────────────────────

  bool isInMyBag(String cardId) => _myBag.any((i) => i.cardId == cardId);

  bool canAddCardToCart(String cardId) {
    if (!canPurchaseCard(cardId)) return false;
    return !_cart.any((i) => i.type == CartItemType.card && i.id == cardId);
  }

  bool canAddBundleToCart(String bundleId) {
    final quote = getBundleQuote(bundleId);
    if (!quote.canPurchase) return false;
    return !isBundleInCart(bundleId);
  }

  bool canPurchaseCard(String cardId) {
    final card = getCardById(cardId);
    if (card == null) return false;
    return !isCardOwned(cardId);
  }

  Future<bool> addCardToCart(String cardId) async {
    if (!canAddCardToCart(cardId)) return false;
    _cart.add(CartItem(type: CartItemType.card, id: cardId));
    await _persistShop();
    notifyListeners();
    return true;
  }

  Future<bool> addBundleToCart(String bundleId) async {
    if (!canAddBundleToCart(bundleId)) return false;
    _cart.add(CartItem(type: CartItemType.bundle, id: bundleId));
    await _persistShop();
    notifyListeners();
    return true;
  }

  Future<void> removeCartItem(CartItem item) async {
    _cart.removeWhere((i) => i.key == item.key);
    await _persistShop();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cart.clear();
    await _persistShop();
    notifyListeners();
  }

  int getCartItemPrice(CartItem item) {
    if (item.type == CartItemType.card) {
      return getCardById(item.id)?.price ?? 0;
    }
    return getBundleQuote(item.id).totalPrice;
  }

  int get cartTotalPrice =>
      _cart.fold<int>(0, (sum, item) => sum + getCartItemPrice(item));

  // ── Purchase → My Bag (pending) ─────────────────────────────────────

  Future<bool> purchaseCard(String cardId, {bool deductPoints = true}) async {
    final card = getCardById(cardId);
    if (card == null || !canPurchaseCard(cardId)) return false;

    if (deductPoints) {
      if (_knowledgePoints < card.price) return false;
      _knowledgePoints -= card.price;
    }

    _myBag.add(MyBagItem(cardId: cardId));
    await _persistShop();
    notifyListeners();
    return true;
  }

  Future<bool> purchaseBundle(String bundleId,
      {bool deductPoints = true}) async {
    final quote = getBundleQuote(bundleId);
    if (!quote.canPurchase) return false;

    if (deductPoints) {
      if (_knowledgePoints < quote.totalPrice) return false;
      _knowledgePoints -= quote.totalPrice;
    }

    for (final cardId in quote.remainingCardIds) {
      if (!isInMyBag(cardId)) {
        _myBag.add(MyBagItem(cardId: cardId));
      }
    }
    await _persistShop();
    notifyListeners();
    return true;
  }

  Future<bool> checkoutCart(String method) async {
    if (_cart.isEmpty) return false;
    final total = cartTotalPrice;

    if (method == 'points') {
      if (_knowledgePoints < total) return false;
      _knowledgePoints -= total;
    }

    for (final item in List<CartItem>.from(_cart)) {
      if (item.type == CartItemType.card) {
        if (!isInMyBag(item.id)) {
          _myBag.add(MyBagItem(cardId: item.id));
        }
      } else {
        final quote = getBundleQuote(item.id);
        for (final cardId in quote.remainingCardIds) {
          if (!isInMyBag(cardId)) {
            _myBag.add(MyBagItem(cardId: cardId));
          }
        }
      }
    }
    _cart.clear();
    await _persistShop();
    notifyListeners();
    return true;
  }

  Future<bool> activateCard(String cardId) async {
    final idx = _myBag.indexWhere((i) => i.cardId == cardId);
    if (idx < 0) return false;

    final cardIdx = _cards.indexWhere((c) => c.id == cardId);
    if (cardIdx < 0) return false;

    _myBag.removeAt(idx);
    _cards[cardIdx].isUnlocked = true;
    await _persistShop();
    notifyListeners();
    return true;
  }

  // ── Scan ────────────────────────────────────────────────────────────

  void addScannedCard(String cardId) {
    if (_scannedCards.length < 2 && !_scannedCards.contains(cardId)) {
      _scannedCards.add(cardId);
      notifyListeners();
    }
  }

  void clearScannedCards() {
    _scannedCards.clear();
    notifyListeners();
  }

  ChemicalCardModel? getCardById(String id) {
    try {
      return _cards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
