import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../../core/storage/avatar_storage_service.dart';
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
  String? _userPhone;
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

  /// Full name if set in profile; otherwise the part before @ in email.
  String get displayName {
    if (_userName != null && _userName!.trim().isNotEmpty) {
      return _userName!.trim();
    }
    final email = _userEmail;
    if (email == null || email.isEmpty) return 'Student';
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  static String displayNameFromEmail(String email, {String? fullName}) {
    if (fullName != null && fullName.trim().isNotEmpty) return fullName.trim();
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }
  String? get userPhone => _userPhone;
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
        _userEmail = email;
        await _loadUserProfileFields(email, sessionUser: user);
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

  Future<void> _loadUserProfileFields(
      String email, {
        Map<String, dynamic>? sessionUser,
      }) async {
    final registered = await _storage.getRegisteredUserByEmail(email);
    final storedName = registered?['fullname'] as String? ??
        sessionUser?['name'] as String?;
    _userName =
    storedName != null && storedName.trim().isNotEmpty ? storedName.trim() : null;
    _userPhone = registered?['phone'] as String?;
    final avatarPath =
        sessionUser?['avatar'] as String? ?? registered?['avatar'] as String?;
    _userAvatar =
    AvatarStorageService.avatarFileExists(avatarPath) ? avatarPath : null;
  }

  Future<void> _persistAuth() async {
    if (!_isLoggedIn || _userEmail == null) return;
    await _storage.setUser({
      'name': _userName,
      'email': _userEmail,
      if (_userPhone != null && _userPhone!.isNotEmpty) 'phone': _userPhone,
      if (_userAvatar != null) 'avatar': _userAvatar,
    });
  }

  Future<void> _persistRegisteredUser({String? passwordOverride}) async {
    final email = _userEmail;
    if (email == null) return;
    final existing = await _storage.getRegisteredUserByEmail(email);
    if (existing == null) return;

    await _storage.setRegisteredUser({
      'fullname': _userName ?? existing['fullname'],
      'email': email,
      'password': passwordOverride ?? existing['password'],
      'phone': _userPhone ?? existing['phone'] ?? '',
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

  /// Sau Amplify sign-in — lưu token + bật phiên user thường (student).
  Future<LoginResult> establishCognitoSession({
    required String email,
    required String idToken,
  }) async {
    final normalizedEmail = email.trim();
    final isFirstLogin =
    !await _storage.getUserHasLoggedInBefore(normalizedEmail);

    _isLoggedIn = true;
    _userEmail = normalizedEmail;
    await _storage.setAuthToken(idToken);
    await _loadUserProfileFields(normalizedEmail);
    await _loadShopStateForUser(normalizedEmail);
    await _persistAuth();
    await _storage.setUserHasLoggedInBefore(normalizedEmail, true);

    _initialized = true;
    notifyListeners();

    return LoginResult(
      isFirstLogin: isFirstLogin,
      displayName: displayName,
    );
  }

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
    final storedPassword = registered['password'] as String? ?? '';
    if (storedPassword.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return (
      error: 'Tài khoản Google. Vui lòng đăng nhập bằng Google.',
      result: null,
      );
    }
    if (storedPassword != password) {
      _isLoading = false;
      notifyListeners();
      return (error: 'Invalid email or password', result: null);
    }

    final isFirstLogin =
    !await _storage.getUserHasLoggedInBefore(normalizedEmail);

    _isLoggedIn = true;
    _userEmail = normalizedEmail;
    await _loadUserProfileFields(normalizedEmail);

    await _loadShopStateForUser(normalizedEmail);

    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.setAuthToken(token);
    await _persistAuth();
    await _storage.setUserHasLoggedInBefore(normalizedEmail, true);

    _isLoading = false;
    notifyListeners();
    return (
    error: null,
    result: LoginResult(
      isFirstLogin: isFirstLogin,
      displayName: displayName,
    ),
    );
  }

  /// Mock Google sign-in — goes straight to Home with Google profile data.
  Future<LoginResult> signInWithGoogle({
    required String name,
    required String email,
    String? avatar,
  }) async {
    final normalizedEmail = email.trim();
    final existing =
    await _storage.getRegisteredUserByEmail(normalizedEmail);
    final isFirstLogin =
    !await _storage.getUserHasLoggedInBefore(normalizedEmail);

    if (existing == null) {
      await _storage.setRegisteredUser({
        'fullname': name,
        'email': normalizedEmail,
        'password': '',
        'phone': '',
        'isGoogle': true,
      });
      await _storage.initNewUserShopData(normalizedEmail);
    } else {
      await _storage.setRegisteredUser({
        'fullname': name,
        'email': normalizedEmail,
        'password': existing['password'] ?? '',
        'phone': existing['phone'] ?? '',
        'isGoogle': true,
        if (existing['avatar'] != null) 'avatar': existing['avatar'],
      });
    }

    _isLoggedIn = true;
    _userName = name;
    _userEmail = normalizedEmail;
    _userAvatar = avatar;

    await _loadShopStateForUser(normalizedEmail);

    final token = 'google_token_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.setAuthToken(token);
    await _persistAuth();
    await _storage.setUserHasLoggedInBefore(normalizedEmail, true);
    notifyListeners();

    return LoginResult(isFirstLogin: isFirstLogin, displayName: name);
  }

  Future<void> logout() async {

    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    _userAvatar = null;

    await _storage.clearAuth();

    await _resetShopStateInMemory();

    notifyListeners();
  }

  Future<String?> updateProfile({
    required String fullName,
    required String phone,
    String? password,
    String? confirmPassword,
  }) async {
    if (!_isLoggedIn || _userEmail == null) {
      return 'Bạn cần đăng nhập để cập nhật.';
    }
    if (fullName.trim().isEmpty) {
      return 'Họ tên không được để trống.';
    }
    if (phone.trim().isEmpty) {
      return 'Số điện thoại không được để trống.';
    }

    final wantsPasswordChange = password != null && password.isNotEmpty;
    if (wantsPasswordChange) {
      if (password.length < 6) {
        return 'Mật khẩu tối thiểu 6 ký tự.';
      }
      if (password != confirmPassword) {
        return 'Mật khẩu xác nhận không khớp.';
      }
    }

    _userName = fullName.trim();
    _userPhone = phone.trim();
    await _persistRegisteredUser(
      passwordOverride: wantsPasswordChange ? password : null,
    );
    await _persistAuth();
    notifyListeners();
    return null;
  }

  Future<String?> updateAvatarFromPath(String pickedPath) async {
    if (!_isLoggedIn || _userEmail == null) {
      return 'Bạn cần đăng nhập để cập nhật ảnh.';
    }
    try {
      final saved = await AvatarStorageService.saveAvatar(
        pickedPath,
        _userEmail!,
      );
      _userAvatar = saved;
      await _persistRegisteredUser();
      await _persistAuth();
      notifyListeners();
      return null;
    } catch (_) {
      return 'Không thể lưu ảnh đại diện. Vui lòng thử lại.';
    }
  }

  /// Saves account credentials only — user must log in on the login screen.
  Future<String?> registerAccount(
      AccountSetupData data,
      ) async {

    try {

      await Amplify.Auth.signUp(
        username: data.email,
        password: data.password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: data.email,
          },
        ),
      );

      return null;

    } on AuthException catch (e) {

      return e.message;
    }
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
