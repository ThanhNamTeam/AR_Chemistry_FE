import 'package:flutter/material.dart';

import '../../domain/models/app_portal.dart';
import '../storage/local_storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  final Map<AppPortal, Locale> _locales = {
    for (final p in AppPortal.values) p: const Locale('vi'),
  };

  AppPortal _activePortal = AppPortal.auth;

  AppPortal get activePortal => _activePortal;

  /// Locale of the portal currently on screen (drives MaterialApp).
  Locale get locale => _locales[_activePortal]!;

  Locale localeFor(AppPortal portal) => _locales[portal]!;

  bool isEnglishFor(AppPortal portal) =>
      _locales[portal]!.languageCode == 'en';

  bool isVietnameseFor(AppPortal portal) =>
      _locales[portal]!.languageCode == 'vi';

  bool get isEnglish => locale.languageCode == 'en';
  bool get isVietnamese => locale.languageCode == 'vi';

  Future<void> loadLocales() async {
    final legacy = await _storage.getLocale();
    for (final portal in AppPortal.values) {
      var code = await _storage.getLocaleForPortal(portal);
      if (code == null &&
          portal == AppPortal.user &&
          legacy != null &&
          (legacy == 'en' || legacy == 'vi')) {
        code = legacy;
        await _storage.setLocaleForPortal(portal, legacy);
      }
      if (code == 'en') {
        _locales[portal] = const Locale('en');
      } else if (code == 'vi') {
        _locales[portal] = const Locale('vi');
      }
    }
    notifyListeners();
  }

  Future<void> setActivePortal(AppPortal portal) async {
    if (_activePortal == portal) return;
    _activePortal = portal;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale, {AppPortal? portal}) async {
    final target = portal ?? _activePortal;
    if (_locales[target] == locale) return;
    _locales[target] = locale;
    await _storage.setLocaleForPortal(target, locale.languageCode);
    notifyListeners();
  }
}
