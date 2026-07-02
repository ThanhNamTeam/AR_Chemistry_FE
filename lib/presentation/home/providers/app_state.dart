import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;


import '../../../core/api/chemical_card_api.dart';
import '../../../core/api/single_card_api.dart';
import '../../../core/models/response/card_bundle_response.dart';
import '../../../core/models/response/chemical_card_response.dart';
import '../../../core/models/response/my_single_card_purchase_response.dart';
import '../../../core/models/response/single_card_purchase_response.dart';
import '../../../core/models/response/single_card_shop_response.dart';
import '../../../core/storage/avatar_storage_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../domain/models/account_setup_model.dart';
import '../../../domain/models/bundle_price_quote.dart';
import '../../../domain/models/cart_item_model.dart';
import '../../../domain/models/chemical_card_model.dart';
import '../../../domain/models/login_route_args.dart';
import '../../../domain/models/my_bag_item_model.dart';
import '../../../core/api/profile_api.dart';

import '../../../core/api/payment_api.dart';
import '../../../core/models/request/create_payment_request.dart';

import '../../../core/api/upload_api.dart';
import '../../../core/models/request/generate_upload_url_request.dart';
import '../../../core/api/package_api.dart';
import '../../../core/models/response/package_response.dart';




class AppState extends ChangeNotifier {
  static const appDisplayName = 'Chemistry AR';
  static const defaultKnowledgePoints = 15000;
  static const defaultStarterUnlocked = ['H', 'O'];

  final LocalStorageService _storage = LocalStorageService();
  final PaymentApi _paymentApi = PaymentApi();
  final UploadApi _uploadApi = UploadApi();
  final PackageApi _packageApi = PackageApi();
  final ProfileApi _profileApi = ProfileApi();
  final ChemicalCardApi _chemicalCardApi = ChemicalCardApi();

  final SingleCardApi _singleCardApi = SingleCardApi();
  final List<MySingleCardPurchaseResponse> _mySingleCards = [];
  bool _loadingMySingleCards = false;
  String? _mySingleCardsError;
  int _mySingleCardsPage = 0;
  bool _mySingleCardsLast = false;

  List<MySingleCardPurchaseResponse> get mySingleCards =>
      List.unmodifiable(_mySingleCards);

  bool get loadingMySingleCards => _loadingMySingleCards;

  String? get mySingleCardsError => _mySingleCardsError;

  bool get mySingleCardsLast => _mySingleCardsLast;
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

  final List<PackageResponse> _packages = [];
  List<PackageResponse> get packages => List.unmodifiable(_packages);

  final List<ChemicalCardResponse> _shopChemicalCards = [];
  bool _loadingShopChemicalCards = false;
  String? _shopChemicalCardsError;
  int _shopChemicalCardsPage = 0;
  bool _shopChemicalCardsLast = false;

  final List<SingleCardShopResponse> _shopSingleCards = [];
  bool _loadingShopSingleCards = false;
  String? _shopSingleCardsError;
  int _shopSingleCardsPage = 0;
  bool _shopSingleCardsLast = false;

  SingleCardPurchaseResponse? _lastSingleCardPurchase;

  final List<CardBundleResponse> _shopCardBundles = [];
  bool _loadingShopCardBundles = false;
  String? _shopCardBundlesError;
  int _shopCardBundlesPage = 0;
  bool _shopCardBundlesLast = false;

  //cards
  List<ChemicalCardResponse> get shopChemicalCards =>
      List.unmodifiable(_shopChemicalCards);

  bool get loadingShopChemicalCards => _loadingShopChemicalCards;

  String? get shopChemicalCardsError => _shopChemicalCardsError;

  bool get shopChemicalCardsLast => _shopChemicalCardsLast;

  List<SingleCardShopResponse> get shopSingleCards =>
      List.unmodifiable(_shopSingleCards);

  bool get loadingShopSingleCards => _loadingShopSingleCards;

  String? get shopSingleCardsError => _shopSingleCardsError;

  bool get shopSingleCardsLast => _shopSingleCardsLast;

  SingleCardPurchaseResponse? get lastSingleCardPurchase =>
      _lastSingleCardPurchase;

  //bundle
  List<CardBundleResponse> get shopCardBundles =>
      List.unmodifiable(_shopCardBundles);

  bool get loadingShopCardBundles => _loadingShopCardBundles;

  String? get shopCardBundlesError => _shopCardBundlesError;

  bool get shopCardBundlesLast => _shopCardBundlesLast;

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
        await loadProfileFromBackend();
      } else {
        await _resetShopStateInMemory();
      }
    } else {
      await _resetShopStateInMemory();
    }

    _initialized = true;
    notifyListeners();
  }

  Future<bool> loadMySingleCards({
    bool refresh = false,
  }) async {
    if (_loadingMySingleCards) return false;

    if (refresh) {
      _mySingleCards.clear();
      _mySingleCardsPage = 0;
      _mySingleCardsLast = false;
      _mySingleCardsError = null;
      notifyListeners();
    }

    if (_mySingleCardsLast) return true;

    _loadingMySingleCards = true;
    _mySingleCardsError = null;
    notifyListeners();

    try {
      final page = await _singleCardApi.getMySingleCardPurchases(
        page: _mySingleCardsPage,
        size: 20,
      );

      _mySingleCards.addAll(page.items);
      _mySingleCardsPage = page.page + 1;
      _mySingleCardsLast = page.last;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Load my single cards error: $e');
      _mySingleCardsError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loadingMySingleCards = false;
      notifyListeners();
    }
  }

  Future<void> loadProfileFromBackend() async {
    try {
      final profile = await _profileApi.getProfile();

      _userName = profile['fullName'] as String?;
      _userEmail = profile['email'] as String? ?? _userEmail;
      _userPhone = profile['phoneNumber'] as String?;
      _userAvatar = profile['avatarUrl'] as String?;

      await _persistAuth();
      notifyListeners();
    } catch (e) {
      debugPrint('Load profile from backend error: $e');
    }
  }

  Future<bool> loadPackages() async {
    try {
      final packages = await _packageApi.getPackages();

      _packages
        ..clear()
        ..addAll(
          packages.where((p) => p.packageType != 'FREE'),
        );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Load packages error: $e');
      return false;
    }
  }

  Future<bool> loadShopChemicalCards({
    bool refresh = false,
  }) async {
    if (_loadingShopChemicalCards) return false;

    if (refresh) {
      _shopChemicalCards
        .clear();
      _shopChemicalCardsPage = 0;
      _shopChemicalCardsLast = false;
      _shopChemicalCardsError = null;
      notifyListeners();
    }

    if (_shopChemicalCardsLast) return true;

    _loadingShopChemicalCards = true;
    _shopChemicalCardsError = null;
    notifyListeners();

    try {
      final page = await _chemicalCardApi.getShopCards(
        page: _shopChemicalCardsPage,
        size: 20,
      );

      _shopChemicalCards.addAll(page.items);
      _shopChemicalCardsPage = page.page + 1;
      _shopChemicalCardsLast = page.last;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Load shop chemical cards error: $e');
      _shopChemicalCardsError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loadingShopChemicalCards = false;
      notifyListeners();
    }
  }

  Future<bool> loadShopSingleCards({
    bool refresh = false,
  }) async {
    if (_loadingShopSingleCards) return false;

    if (refresh) {
      _shopSingleCards.clear();
      _shopSingleCardsPage = 0;
      _shopSingleCardsLast = false;
      _shopSingleCardsError = null;
      notifyListeners();
    }

    if (_shopSingleCardsLast) return true;

    _loadingShopSingleCards = true;
    _shopSingleCardsError = null;
    notifyListeners();

    try {
      final page = await _singleCardApi.getSingleCards(
        page: _shopSingleCardsPage,
        size: 20,
      );

      _shopSingleCards.addAll(page.items);
      _shopSingleCardsPage = page.page + 1;
      _shopSingleCardsLast = page.last;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Load shop single cards error: $e');
      _shopSingleCardsError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loadingShopSingleCards = false;
      notifyListeners();
    }
  }

  Future<SingleCardPurchaseResponse?> fakeBuySingleCard(String singleCardId) async {
    try {
      final purchase = await _singleCardApi.fakeBuySingleCard(singleCardId);

      _lastSingleCardPurchase = purchase;
      await loadMySingleCards(refresh: true);

      notifyListeners();
      return purchase;
    } catch (e) {
      debugPrint('Fake buy single card error: $e');
      return null;
    }
  }

  Future<bool> loadShopCardBundles({
    bool refresh = false,
  }) async {
    if (_loadingShopCardBundles) return false;

    if (refresh) {
      _shopCardBundles.clear();
      _shopCardBundlesPage = 0;
      _shopCardBundlesLast = false;
      _shopCardBundlesError = null;
      notifyListeners();
    }

    if (_shopCardBundlesLast) return true;

    _loadingShopCardBundles = true;
    _shopCardBundlesError = null;
    notifyListeners();

    try {
      final page = await _chemicalCardApi.getShopCardBundles(
        page: _shopCardBundlesPage,
        size: 20,
      );

      _shopCardBundles.addAll(page.items);
      _shopCardBundlesPage = page.page + 1;
      _shopCardBundlesLast = page.last;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Load shop card bundles error: $e');
      _shopCardBundlesError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loadingShopCardBundles = false;
      notifyListeners();
    }
  }

  void _applyUnlockedIds(List<String> unlockedIds) {
    for (final card in _cards) {
      card.isUnlocked = unlockedIds.contains(card.id) ||
          defaultStarterUnlocked.contains(card.id);
    }
  }

  Future<void> _resetShopStateInMemory() async {
    _knowledgePoints = defaultKnowledgePoints;
    _shopSingleCards.clear();
    _shopSingleCardsPage = 0;
    _shopSingleCardsLast = false;
    _shopSingleCardsError = null;
    _loadingShopSingleCards = false;
    _lastSingleCardPurchase = null;
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
    await loadProfileFromBackend();
    await _persistAuth();
    await _storage.setUserHasLoggedInBefore(normalizedEmail, true);

    _initialized = true;
    notifyListeners();

    return LoginResult(
      isFirstLogin: isFirstLogin,
      displayName: displayName,
    );
  }

  Future<String?> uploadPaymentProof({
    required String fileName,
    required String contentType,
    required int fileSize,
    required Uint8List bytes,
  }) async {
    try {
      final presigned = await _uploadApi.generateUploadUrl(
        GenerateUploadUrlRequest(
          purposeCode: 'PAYMENT_PROOF',
          fileName: fileName,
          contentType: contentType,
          fileSize: fileSize,
        ),
      );

      await _uploadApi.uploadFileToS3(
        uploadUrl: presigned.uploadUrl,
        bytes: bytes,
        contentType: contentType,
      );

      return presigned.fileUrl;
    } catch (e) {
      debugPrint('Upload payment proof error: $e');
      return null;
    }
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

    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      safePrint('Amplify signOut error: $e');
    }
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

    try {
      await _profileApi.updateProfile(
        fullName: fullName.trim(),
        phoneNumber: phone.trim(),
      );

      _userName = fullName.trim();
      _userPhone = phone.trim();

      await _persistRegisteredUser(
        passwordOverride: wantsPasswordChange ? password : null,
      );
      await _persistAuth();

      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Update profile API error: $e');
      return 'Cập nhật hồ sơ thất bại. Vui lòng thử lại.';
    }
  }

  Future<String?> updateAvatarFromPath(String pickedPath) async {
    if (!_isLoggedIn || _userEmail == null) {
      return 'Bạn cần đăng nhập để cập nhật ảnh.';
    }

    try {
      final file = File(pickedPath);
      final bytes = await file.readAsBytes();
      final fileSize = bytes.length;
      final ext = p.extension(pickedPath).toLowerCase();

      final contentType = ext == '.png' ? 'image/png' : 'image/jpeg';

      final presigned = await _uploadApi.generateUploadUrl(
        GenerateUploadUrlRequest(
          purposeCode: 'AVATAR',
          fileName: p.basename(pickedPath),
          contentType: contentType,
          fileSize: fileSize,
        ),
      );

      await _uploadApi.uploadFileToS3(
        uploadUrl: presigned.uploadUrl,
        bytes: bytes,
        contentType: contentType,
      );

      final avatarUrl = presigned.fileUrl;

      await _profileApi.updateAvatar(avatarUrl: avatarUrl);

      _userAvatar = avatarUrl;

      await _persistAuth();
      notifyListeners();

      return null;
    } catch (e) {
      debugPrint('Update avatar error: $e');
      return 'Không thể cập nhật ảnh đại diện. Vui lòng thử lại.';
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

  bool isSingleCardOwned(String singleCardId) {
    return _mySingleCards.any(
          (p) => p.singleCardId == singleCardId && p.active,
    );
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

  Future<bool> createBankPayment({
    required String itemId,
    required String itemType,
    required String proofImageUrl,
  }) async {
    try {
      final request = CreatePaymentRequest(
        itemId: itemId,
        itemType: itemType,
        proofImageUrl: proofImageUrl,
      );

      await _paymentApi.createPayment(request);

      return true;
    } catch (e) {
      debugPrint('Create bank payment error: $e');
      return false;
    }
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
