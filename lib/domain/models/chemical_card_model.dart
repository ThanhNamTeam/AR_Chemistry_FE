import 'package:flutter/material.dart';

class ChemicalCardModel {
  final String id;
  final String symbol;
  final String name;
  final int atomicNumber;
  final Color color;
  final int price;
  bool isUnlocked;

  ChemicalCardModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.atomicNumber,
    required this.color,
    required this.price,
    this.isUnlocked = false,
  });
}

class BundleModel {
  final String id;
  final String name;
  final List<String> cardIds;
  final int originalPrice;
  final int discountedPrice;

  BundleModel({
    required this.id,
    required this.name,
    required this.cardIds,
    required this.originalPrice,
    required this.discountedPrice,
  });
}

class ChemicalReaction {
  final String equation;
  final String name;
  final String description;
  final int points;

  ChemicalReaction({
    required this.equation,
    required this.name,
    required this.description,
    required this.points,
  });
}

// Mock data
class ChemicalData {
  static List<ChemicalCardModel> get cards => [
    ChemicalCardModel(
      id: 'H',
      symbol: 'H',
      name: 'Hydrogen',
      atomicNumber: 1,
      color: const Color(0xFF06B6D4),
      price: 50,
      isUnlocked: true,
    ),
    ChemicalCardModel(
      id: 'O',
      symbol: 'O',
      name: 'Oxygen',
      atomicNumber: 8,
      color: const Color(0xFF3B82F6),
      price: 50,
      isUnlocked: true,
    ),
    ChemicalCardModel(
      id: 'Na',
      symbol: 'Na',
      name: 'Sodium',
      atomicNumber: 11,
      color: const Color(0xFFF59E0B),
      price: 80,
      isUnlocked: false,
    ),
    ChemicalCardModel(
      id: 'Cl',
      symbol: 'Cl',
      name: 'Chlorine',
      atomicNumber: 17,
      color: const Color(0xFF22C55E),
      price: 80,
      isUnlocked: false,
    ),
    ChemicalCardModel(
      id: 'Fe',
      symbol: 'Fe',
      name: 'Iron',
      atomicNumber: 26,
      color: const Color(0xFFEF4444),
      price: 100,
      isUnlocked: false,
    ),
    ChemicalCardModel(
      id: 'Au',
      symbol: 'Au',
      name: 'Gold',
      atomicNumber: 79,
      color: const Color(0xFFFBBF24),
      price: 200,
      isUnlocked: false,
    ),
    ChemicalCardModel(
      id: 'C',
      symbol: 'C',
      name: 'Carbon',
      atomicNumber: 6,
      color: const Color(0xFF8B5CF6),
      price: 60,
      isUnlocked: false,
    ),
    ChemicalCardModel(
      id: 'N',
      symbol: 'N',
      name: 'Nitrogen',
      atomicNumber: 7,
      color: const Color(0xFF10B981),
      price: 60,
      isUnlocked: false,
    ),
  ];

  static List<BundleModel> get bundles => [
    BundleModel(
      id: 'bundle_starter',
      name: 'Starter Pack',
      cardIds: ['Na', 'Cl', 'Fe'],
      originalPrice: 260,
      discountedPrice: 200,
    ),
    BundleModel(
      id: 'bundle_organic',
      name: 'Organic Chemistry',
      cardIds: ['C', 'N', 'O'],
      originalPrice: 170,
      discountedPrice: 130,
    ),
  ];

  static ChemicalReaction getReaction(String symbol1, String symbol2) {
    if ((symbol1 == 'H' && symbol2 == 'O') ||
        (symbol1 == 'O' && symbol2 == 'H')) {
      return ChemicalReaction(
        equation: '2H₂ + O₂ → 2H₂O',
        name: 'Water Formation',
        description:
            'Hydrogen reacts with oxygen to form water. This is a synthesis reaction where two elements combine to form a compound.',
        points: 100,
      );
    } else if ((symbol1 == 'Na' && symbol2 == 'Cl') ||
        (symbol1 == 'Cl' && symbol2 == 'Na')) {
      return ChemicalReaction(
        equation: '2Na + Cl₂ → 2NaCl',
        name: 'Salt Formation',
        description:
            'Sodium reacts vigorously with chlorine gas to form sodium chloride (table salt). This is an exothermic synthesis reaction.',
        points: 100,
      );
    } else {
      return ChemicalReaction(
        equation: '$symbol1 + $symbol2 → $symbol1$symbol2',
        name: 'Chemical Combination',
        description:
            '$symbol1 reacts with $symbol2 to form a new compound. This demonstrates the fundamental principle of chemical bonding.',
        points: 100,
      );
    }
  }
}
