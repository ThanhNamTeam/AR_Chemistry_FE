import 'package:flutter/foundation.dart';

import '../../../domain/models/chemical_card_model.dart';

enum StatsPeriod { day, week, month }

class TopSaleItem {
  final String cardId;
  final String symbol;
  final String name;
  final int purchases;

  const TopSaleItem({
    required this.cardId,
    required this.symbol,
    required this.name,
    required this.purchases,
  });
}

class RevenuePoint {
  final String label;
  final double amount;

  const RevenuePoint({required this.label, required this.amount});
}

class AdminProvider extends ChangeNotifier {
  StatsPeriod _period = StatsPeriod.day;
  bool _initialized = false;

  StatsPeriod get period => _period;

  int get totalUsers => 1284;
  int get activeToday => 312;

  double get revenueDay => 2450000;
  double get revenueWeek => 18200000;
  double get revenueMonth => 74500000;

  double get currentRevenue {
    switch (_period) {
      case StatsPeriod.day:
        return revenueDay;
      case StatsPeriod.week:
        return revenueWeek;
      case StatsPeriod.month:
        return revenueMonth;
    }
  }

  List<RevenuePoint> get revenueChartData {
    switch (_period) {
      case StatsPeriod.day:
        return const [
          RevenuePoint(label: '6h', amount: 120000),
          RevenuePoint(label: '9h', amount: 340000),
          RevenuePoint(label: '12h', amount: 520000),
          RevenuePoint(label: '15h', amount: 410000),
          RevenuePoint(label: '18h', amount: 680000),
          RevenuePoint(label: '21h', amount: 380000),
        ];
      case StatsPeriod.week:
        return const [
          RevenuePoint(label: 'T2', amount: 2100000),
          RevenuePoint(label: 'T3', amount: 2450000),
          RevenuePoint(label: 'T4', amount: 1980000),
          RevenuePoint(label: 'T5', amount: 3120000),
          RevenuePoint(label: 'T6', amount: 2890000),
          RevenuePoint(label: 'T7', amount: 3560000),
          RevenuePoint(label: 'CN', amount: 2210000),
        ];
      case StatsPeriod.month:
        return const [
          RevenuePoint(label: 'T1', amount: 18200000),
          RevenuePoint(label: 'T2', amount: 21500000),
          RevenuePoint(label: 'T3', amount: 19800000),
          RevenuePoint(label: 'T4', amount: 15000000),
        ];
    }
  }

  List<TopSaleItem> get topSales {
    final cards = ChemicalData.cards.where((c) => c.id != 'H' && c.id != 'O');
    final list = cards
        .map((c) => TopSaleItem(
              cardId: c.id,
              symbol: c.symbol,
              name: c.name,
              purchases: _mockPurchases(c.id, _period),
            ))
        .toList()
      ..sort((a, b) => b.purchases.compareTo(a.purchases));
    return list.take(5).toList();
  }

  int _mockPurchases(String id, StatsPeriod p) {
    final base = id.hashCode.abs() % 50;
    switch (p) {
      case StatsPeriod.day:
        return 5 + base % 12;
      case StatsPeriod.week:
        return 20 + base % 40;
      case StatsPeriod.month:
        return 80 + base % 120;
    }
  }

  List<ChemicalCardModel> get catalogCards => ChemicalData.cards;
  List<BundleModel> get bundles => ChemicalData.bundles;

  final List<Map<String, String>> _reactions = [
    {
      'id': 'r1',
      'name': 'H₂ + O₂ → H₂O',
      'topic': 'Tổng hợp nước',
    },
    {
      'id': 'r2',
      'name': 'Na + Cl₂ → NaCl',
      'topic': 'Muối ăn',
    },
    {
      'id': 'r3',
      'name': 'CH₄ + O₂ → CO₂ + H₂O',
      'topic': 'Đốt cháy',
    },
  ];

  List<Map<String, String>> get reactions => List.unmodifiable(_reactions);

  void setPeriod(StatsPeriod p) {
    _period = p;
    notifyListeners();
  }

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    notifyListeners();
  }

  void addReaction(String name, String topic) {
    _reactions.add({
      'id': 'r_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'topic': topic,
    });
    notifyListeners();
  }

  void addBundleSale({
    required String name,
    required List<String> cardIds,
    required int originalPrice,
    required int discountPercent,
  }) {
    notifyListeners();
  }
}
