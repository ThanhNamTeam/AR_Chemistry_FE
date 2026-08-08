import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:labedu/core/storage/local_storage_service.dart';
import 'package:labedu/domain/models/app_portal.dart';

void main() {
  late LocalStorageService storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
  });

  // ─── Auth Token ──────────────────────────────────────────────────────────
  group('auth token', () {
    test('set and get auth token', () async {
      await storage.setAuthToken('test-token-123');
      expect(await storage.getAuthToken(), 'test-token-123');
    });

    test('getAuthToken returns null when not set', () async {
      expect(await storage.getAuthToken(), isNull);
    });

    test('clearAuth removes auth token', () async {
      await storage.setAuthToken('tok');
      await storage.clearAuth();
      expect(await storage.getAuthToken(), isNull);
    });
  });

  // ─── User ────────────────────────────────────────────────────────────────
  group('user', () {
    test('set and get user', () async {
      await storage.setUser({'id': '1', 'name': 'Nam'});
      final user = await storage.getUser();
      expect(user, isNotNull);
      expect(user!['name'], 'Nam');
    });

    test('getUser returns null when not set', () async {
      expect(await storage.getUser(), isNull);
    });

    test('clearAuth also removes user', () async {
      await storage.setUser({'id': '1'});
      await storage.clearAuth();
      expect(await storage.getUser(), isNull);
    });
  });

  // ─── Knowledge Points ────────────────────────────────────────────────────
  group('knowledge points', () {
    test('set and get knowledge points', () async {
      await storage.setKnowledgePoints(500);
      expect(await storage.getKnowledgePoints(), 500);
    });

    test('getKnowledgePoints returns null when not set', () async {
      expect(await storage.getKnowledgePoints(), isNull);
    });
  });

  // ─── Onboarding ──────────────────────────────────────────────────────────
  group('onboarding', () {
    test('isOnboardingCompleted returns false by default', () async {
      expect(await storage.isOnboardingCompleted(), false);
    });

    test('setOnboardingCompleted to true', () async {
      await storage.setOnboardingCompleted(true);
      expect(await storage.isOnboardingCompleted(), true);
    });
  });

  // ─── Theme ───────────────────────────────────────────────────────────────
  group('theme', () {
    test('set and get theme for user portal', () async {
      await storage.setTheme('dark');
      expect(await storage.getTheme(), 'dark');
    });

    test('set and get theme for admin portal', () async {
      await storage.setThemeForPortal(AppPortal.admin, 'light');
      expect(await storage.getThemeForPortal(AppPortal.admin), 'light');
    });

    test('getTheme returns null when not set', () async {
      expect(await storage.getTheme(), isNull);
    });
  });

  // ─── Locale ──────────────────────────────────────────────────────────────
  group('locale', () {
    test('set and get locale', () async {
      await storage.setLocale('vi');
      expect(await storage.getLocale(), 'vi');
    });

    test('set and get locale for portal', () async {
      await storage.setLocaleForPortal(AppPortal.admin, 'en');
      expect(await storage.getLocaleForPortal(AppPortal.admin), 'en');
    });

    test('getLocale returns null when not set', () async {
      expect(await storage.getLocale(), isNull);
    });
  });

  // ─── Unlocked Cards ──────────────────────────────────────────────────────
  group('unlocked card ids', () {
    test('set and get unlocked card ids', () async {
      await storage.setUnlockedCardIds(['H', 'O', 'Na']);
      expect(await storage.getUnlockedCardIds(), ['H', 'O', 'Na']);
    });

    test('returns empty list when not set', () async {
      expect(await storage.getUnlockedCardIds(), isEmpty);
    });
  });

  // ─── My Bag ──────────────────────────────────────────────────────────────
  group('my bag', () {
    test('set and get my bag items', () async {
      await storage.setMyBag([
        {'id': 'item1', 'type': 'card'},
        {'id': 'item2', 'type': 'bundle'},
      ]);
      final items = await storage.getMyBag();
      expect(items.length, 2);
      expect(items[0]['id'], 'item1');
    });

    test('returns empty list when not set', () async {
      expect(await storage.getMyBag(), isEmpty);
    });
  });

  // ─── Cart Items ──────────────────────────────────────────────────────────
  group('cart items', () {
    test('set and get cart items', () async {
      await storage.setCartItems([
        {'type': 'card', 'id': 'H'},
        {'type': 'bundle', 'id': 'bundle1'},
      ]);
      final items = await storage.getCartItems();
      expect(items.length, 2);
      expect(items[0]['type'], 'card');
      expect(items[1]['id'], 'bundle1');
    });

    test('returns empty list when not set', () async {
      expect(await storage.getCartItems(), isEmpty);
    });
  });

  // ─── User-scoped data ────────────────────────────────────────────────────
  group('user-scoped data', () {
    const email = 'test@example.com';

    test('set and get user knowledge points', () async {
      await storage.setUserKnowledgePoints(email, 1500);
      expect(await storage.getUserKnowledgePoints(email), 1500);
    });

    test('getUserKnowledgePoints returns null when not set', () async {
      expect(await storage.getUserKnowledgePoints(email), isNull);
    });

    test('set and get user unlocked card ids', () async {
      await storage.setUserUnlockedCardIds(email, ['H', 'O']);
      expect(await storage.getUserUnlockedCardIds(email), ['H', 'O']);
    });

    test('getUserUnlockedCardIds returns empty when not set', () async {
      expect(await storage.getUserUnlockedCardIds(email), isEmpty);
    });

    test('set and get user my bag', () async {
      await storage.setUserMyBag(email, [
        {'id': 'sub1', 'formula': 'H2O'},
      ]);
      final bag = await storage.getUserMyBag(email);
      expect(bag.length, 1);
      expect(bag[0]['formula'], 'H2O');
    });

    test('getUserMyBag returns empty when not set', () async {
      expect(await storage.getUserMyBag(email), isEmpty);
    });

    test('set and get user cart items', () async {
      await storage.setUserCartItems(email, [
        {'type': 'card', 'id': 'H'},
      ]);
      final items = await storage.getUserCartItems(email);
      expect(items.length, 1);
    });

    test('getUserCartItems returns empty when not set', () async {
      expect(await storage.getUserCartItems(email), isEmpty);
    });

    test('set and get has logged in before', () async {
      await storage.setUserHasLoggedInBefore(email, true);
      expect(await storage.getUserHasLoggedInBefore(email), true);
    });

    test('getUserHasLoggedInBefore defaults to false', () async {
      expect(await storage.getUserHasLoggedInBefore(email), false);
    });

    test('email is normalized (trimmed, lowercased)', () async {
      await storage.setUserKnowledgePoints('  TEST@EXAMPLE.COM  ', 200);
      expect(await storage.getUserKnowledgePoints('test@example.com'), 200);
    });
  });

  // ─── initNewUserShopData ─────────────────────────────────────────────────
  group('initNewUserShopData', () {
    test('sets initial values for new user', () async {
      const email = 'new@user.com';
      await storage.initNewUserShopData(email);
      expect(await storage.getUserKnowledgePoints(email), 15000);
      expect(await storage.getUserUnlockedCardIds(email), ['H', 'O']);
      expect(await storage.getUserMyBag(email), isEmpty);
      expect(await storage.getUserCartItems(email), isEmpty);
      expect(await storage.getUserHasLoggedInBefore(email), false);
    });
  });

  // ─── RegisteredUser ──────────────────────────────────────────────────────
  group('registered user', () {
    test('set and get registered user by email', () async {
      await storage.setRegisteredUser({
        'email': 'user@example.com',
        'fullname': 'Nguyen Nam',
        'password': 'secret',
        'phone': '0901234567',
      });
      final user = await storage.getRegisteredUserByEmail('user@example.com');
      expect(user, isNotNull);
      expect(user!['fullname'], 'Nguyen Nam');
    });

    test('getRegisteredUserByEmail is case-insensitive', () async {
      await storage.setRegisteredUser({
        'email': 'User@Example.COM',
        'fullname': 'Nam',
        'password': 'pass',
      });
      final user = await storage.getRegisteredUserByEmail('user@example.com');
      expect(user, isNotNull);
    });

    test('returns null for unregistered email', () async {
      expect(await storage.getRegisteredUserByEmail('nobody@example.com'), isNull);
    });
  });
}
