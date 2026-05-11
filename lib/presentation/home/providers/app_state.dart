import 'package:flutter/foundation.dart';
import '../../../domain/models/chemical_card_model.dart';

class AppState extends ChangeNotifier {
  // Auth state
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;
  int _knowledgePoints = 300;

  // Cards state
  final List<ChemicalCardModel> _cards = ChemicalData.cards;
  final List<String> _cart = [];
  final List<String> _scannedCards = [];

  // Getters
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  int get knowledgePoints => _knowledgePoints;
  List<ChemicalCardModel> get cards => List.unmodifiable(_cards);
  List<String> get cart => List.unmodifiable(_cart);
  List<String> get scannedCards => List.unmodifiable(_scannedCards);
  List<ChemicalCardModel> get unlockedCards =>
      _cards.where((c) => c.isUnlocked).toList();
  List<ChemicalCardModel> get lockedCards =>
      _cards.where((c) => !c.isUnlocked).toList();

  // Auth actions
  void login(String email, String password) {
    _isLoggedIn = true;
    _userName = 'Trần Thanh Nam';
    _userEmail = email;
    notifyListeners();
  }

  void loginWithGoogle() {
    _isLoggedIn = true;
    _userName = 'Trần Thanh Nam';
    _userEmail = 'trannam@gmail.com';
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }

  void register(String fullName, String email, String password) {
    _isLoggedIn = true;
    _userName = fullName;
    _userEmail = email;
    notifyListeners();
  }

  // Knowledge Points
  void addKnowledgePoints(int points) {
    _knowledgePoints += points;
    notifyListeners();
  }

  void deductKnowledgePoints(int points) {
    if (_knowledgePoints >= points) {
      _knowledgePoints -= points;
      notifyListeners();
    }
  }

  // Cart actions
  void addToCart(String cardId) {
    if (!_cart.contains(cardId)) {
      _cart.add(cardId);
      notifyListeners();
    }
  }

  void removeFromCart(String cardId) {
    _cart.remove(cardId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Purchase
  bool purchaseCard(String cardId) {
    final card = _cards.firstWhere(
      (c) => c.id == cardId,
      orElse: () => throw Exception('Card not found'),
    );
    if (_knowledgePoints >= card.price) {
      _knowledgePoints -= card.price;
      card.isUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool purchaseBundle(String bundleId) {
    final bundle = ChemicalData.bundles.firstWhere(
      (b) => b.id == bundleId,
      orElse: () => throw Exception('Bundle not found'),
    );
    if (_knowledgePoints >= bundle.discountedPrice) {
      _knowledgePoints -= bundle.discountedPrice;
      for (final cardId in bundle.cardIds) {
        final idx = _cards.indexWhere((c) => c.id == cardId);
        if (idx >= 0) {
          _cards[idx].isUnlocked = true;
        }
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Scan actions
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
