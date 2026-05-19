import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_portal.dart';

class LocalStorageService {
  static const authTokenKey = 'auth_token';
  static const userKey = 'user';
  static const knowledgePointsKey = 'knowledge_points';
  static const registeredUserKey = 'registeredUser';
  static const themeKey = 'chemistry-ar-theme';
  static const localeKey = 'app-locale';
  static const onboardingCompletedKey = 'onboarding_completed_v1';
  static const unlockedCardsKey = 'unlocked_cards';
  static const myBagKey = 'my_bag';
  static const registeredUsersKey = 'registered_users_v2';
  /// Legacy key — may be StringList or JSON String on older installs.
  static const cartKey = 'cart';
  /// Current cart format (JSON array of {type, id}).
  static const cartItemsKey = 'cart_items_v2';

  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey);
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> setKnowledgePoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(knowledgePointsKey, points);
  }

  Future<int?> getKnowledgePoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(knowledgePointsKey);
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _userScopedKey(String email, String suffix) =>
      'user_${_normalizeEmail(email)}_$suffix';

  Future<void> setRegisteredUser(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final email = _normalizeEmail(data['email'] as String);
    final all = await _getRegisteredUsersMap(prefs);
    final previous = all[email];
    all[email] = {
      'fullname': data['fullname'] ?? previous?['fullname'],
      'email': data['email'],
      'password': data['password'] ?? previous?['password'],
      'phone': data['phone'] ?? previous?['phone'] ?? '',
      if (data['avatar'] != null)
        'avatar': data['avatar']
      else if (previous?['avatar'] != null)
        'avatar': previous!['avatar'],
    };
    await prefs.setString(registeredUsersKey, jsonEncode(all));
    // Legacy single-user key (migrate away).
    await prefs.remove(registeredUserKey);
  }

  Future<Map<String, dynamic>?> getRegisteredUserByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _getRegisteredUsersMap(prefs);
    return all[_normalizeEmail(email)];
  }

  Future<Map<String, Map<String, dynamic>>> _getRegisteredUsersMap(
      SharedPreferences prefs) async {
    final raw = prefs.getString(registeredUsersKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
      );
    }
    final legacy = prefs.getString(registeredUserKey);
    if (legacy == null) return {};
    final user = Map<String, dynamic>.from(jsonDecode(legacy) as Map);
    final email = _normalizeEmail(user['email'] as String);
    final map = {email: user};
    await prefs.setString(registeredUsersKey, jsonEncode(map));
    await prefs.remove(registeredUserKey);
    return map;
  }

  Future<void> setUserHasLoggedInBefore(String email, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userScopedKey(email, 'has_logged_in'), value);
  }

  Future<bool> getUserHasLoggedInBefore(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userScopedKey(email, 'has_logged_in')) ?? false;
  }

  Future<void> setUserKnowledgePoints(String email, int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userScopedKey(email, 'kp'), points);
  }

  Future<int?> getUserKnowledgePoints(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userScopedKey(email, 'kp'));
  }

  Future<void> setUserUnlockedCardIds(String email, List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_userScopedKey(email, 'unlocked'), ids);
  }

  Future<List<String>> getUserUnlockedCardIds(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_userScopedKey(email, 'unlocked')) ?? [];
  }

  Future<void> setUserMyBag(String email, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userScopedKey(email, 'my_bag'), jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> getUserMyBag(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userScopedKey(email, 'my_bag'));
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> setUserCartItems(
      String email, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _userScopedKey(email, 'cart'), jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> getUserCartItems(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userScopedKey(email, 'cart'));
    return _parseCartJson(raw) ?? [];
  }

  /// Seeds default shop data for a newly registered account.
  Future<void> initNewUserShopData(String email) async {
    await setUserKnowledgePoints(email, 15000);
    await setUserUnlockedCardIds(email, ['H', 'O']);
    await setUserMyBag(email, []);
    await setUserCartItems(email, []);
    await setUserHasLoggedInBefore(email, false);
  }

  String _themeKeyForPortal(AppPortal portal) =>
      'chemistry-ar-theme-${portal.storageSuffix}';

  Future<void> setTheme(String theme) async {
    await setThemeForPortal(AppPortal.user, theme);
  }

  Future<String?> getTheme() async {
    return getThemeForPortal(AppPortal.user);
  }

  Future<void> setThemeForPortal(AppPortal portal, String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKeyForPortal(portal), theme);
  }

  Future<String?> getThemeForPortal(AppPortal portal) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKeyForPortal(portal));
  }

  String _localeKeyForPortal(AppPortal portal) =>
      'app-locale-${portal.storageSuffix}';

  Future<void> setLocale(String languageCode) async {
    await setLocaleForPortal(AppPortal.user, languageCode);
  }

  Future<String?> getLocale() async {
    return getLocaleForPortal(AppPortal.user);
  }

  Future<void> setLocaleForPortal(AppPortal portal, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKeyForPortal(portal), languageCode);
  }

  Future<String?> getLocaleForPortal(AppPortal portal) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKeyForPortal(portal));
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompletedKey, value);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingCompletedKey) ?? false;
  }

  Future<void> setUnlockedCardIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(unlockedCardsKey, ids);
  }

  Future<List<String>> getUnlockedCardIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(unlockedCardsKey) ?? [];
  }

  Future<void> setMyBag(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(myBagKey, jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> getMyBag() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(myBagKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> setCartItems(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cartItemsKey, jsonEncode(items));
    await prefs.remove(cartKey);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();

    final current = _parseCartJson(prefs.getString(cartItemsKey));
    if (current != null) return current;

    final migrated = await _readLegacyCart(prefs);
    if (migrated.isNotEmpty) {
      await setCartItems(migrated);
    }
    return migrated;
  }

  List<Map<String, dynamic>>? _parseCartJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Reads old `cart` key without assuming String vs StringList (Android type clash).
  Future<List<Map<String, dynamic>>> _readLegacyCart(
      SharedPreferences prefs) async {
    List<Map<String, dynamic>>? fromJson;
    List<Map<String, dynamic>>? fromList;

    try {
      fromJson = _parseCartJson(prefs.getString(cartKey));
    } catch (_) {}

    try {
      final ids = prefs.getStringList(cartKey);
      if (ids != null && ids.isNotEmpty) {
        fromList = ids.map((id) => {'type': 'card', 'id': id}).toList();
      }
    } catch (_) {}

    await prefs.remove(cartKey);

    if (fromJson != null && fromJson.isNotEmpty) return fromJson;
    if (fromList != null && fromList.isNotEmpty) return fromList;
    return [];
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(authTokenKey);
    await prefs.remove(userKey);
  }
}
