import 'package:flutter/material.dart';

enum CardCategory { element, compound }

class ChemicalCardModel {
  final String id;
  final String symbol;
  final String name;
  final int atomicNumber;
  final Color color;
  final int price;
  final CardCategory category;
  final String? frontImageUrl;
  final String? backImageUrl;
  bool isUnlocked;

  ChemicalCardModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.atomicNumber,
    required this.color,
    required this.price,
    this.category = CardCategory.element,
    this.frontImageUrl,
    this.backImageUrl,
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

class ChemicalData {
  static Color colorForCategory(String? category) {
    switch (category) {
      case 'Alkali metal':
        return const Color(0xFFF59E0B);
      case 'Alkaline earth metal':
        return const Color(0xFF84CC16);
      case 'Transition metal':
        return const Color(0xFFEF4444);
      case 'Post-transition metal':
        return const Color(0xFF0EA5E9);
      case 'Metalloid':
        return const Color(0xFF22C55E);
      case 'Diatomic nonmetal':
      case 'Polyatomic nonmetal':
        return const Color(0xFF06B6D4);
      case 'Noble gas':
        return const Color(0xFF8B5CF6);
      case 'Lanthanide':
        return const Color(0xFFEC4899);
      case 'Actinide':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  static List<ChemicalCardModel> get cards => [
        ChemicalCardModel(
          id: 'H',
          symbol: 'H',
          name: 'Hydrogen',
          atomicNumber: 1,
          color: const Color(0xFF06B6D4),
          price: 3000,
          isUnlocked: true,
        ),
        ChemicalCardModel(
          id: 'O',
          symbol: 'O',
          name: 'Oxygen',
          atomicNumber: 8,
          color: const Color(0xFF3B82F6),
          price: 3000,
          isUnlocked: true,
        ),
        ChemicalCardModel(
          id: 'Na',
          symbol: 'Na',
          name: 'Sodium',
          atomicNumber: 11,
          color: const Color(0xFFF59E0B),
          price: 3000,
        ),
        ChemicalCardModel(
          id: 'Mg',
          symbol: 'Mg',
          name: 'Magnesium',
          atomicNumber: 12,
          color: const Color(0xFF84CC16),
          price: 3000,
        ),
        ChemicalCardModel(
          id: 'Cl',
          symbol: 'Cl',
          name: 'Chlorine',
          atomicNumber: 17,
          color: const Color(0xFF22C55E),
          price: 3000,
        ),
        ChemicalCardModel(
          id: 'Ca',
          symbol: 'Ca',
          name: 'Calcium',
          atomicNumber: 20,
          color: const Color(0xFFA3E635),
          price: 3000,
        ),
        ChemicalCardModel(
          id: 'Fe',
          symbol: 'Fe',
          name: 'Iron',
          atomicNumber: 26,
          color: const Color(0xFFEF4444),
          price: 3500,
        ),
        ChemicalCardModel(
          id: 'Cu',
          symbol: 'Cu',
          name: 'Copper',
          atomicNumber: 29,
          color: const Color(0xFFF97316),
          price: 3500,
        ),
        ChemicalCardModel(
          id: 'H2O',
          symbol: 'H₂O',
          name: 'Water',
          atomicNumber: 0,
          color: const Color(0xFF0EA5E9),
          price: 6000,
          category: CardCategory.compound,
        ),
        ChemicalCardModel(
          id: 'NaCl',
          symbol: 'NaCl',
          name: 'Salt',
          atomicNumber: 0,
          color: const Color(0xFF94A3B8),
          price: 6000,
          category: CardCategory.compound,
        ),
        ChemicalCardModel(
          id: 'H2SO4',
          symbol: 'H₂SO₄',
          name: 'Sulfuric Acid',
          atomicNumber: 0,
          color: const Color(0xFFEAB308),
          price: 6500,
          category: CardCategory.compound,
        ),
      ];

  static List<BundleModel> get bundles => [
        BundleModel(
          id: 'bundle_starter',
          name: 'Starter Pack',
          cardIds: ['Na', 'Mg', 'Cl'],
          originalPrice: 9000,
          discountedPrice: 7200,
        ),
        BundleModel(
          id: 'bundle_metal',
          name: 'Metal Pack',
          cardIds: ['Fe', 'Cu', 'Ca'],
          originalPrice: 10000,
          discountedPrice: 8000,
        ),
        BundleModel(
          id: 'bundle_compound',
          name: 'Compound Pack',
          cardIds: ['H2O', 'NaCl', 'H2SO4'],
          originalPrice: 18500,
          discountedPrice: 14800,
        ),
      ];

  static ChemicalReaction getReaction(String symbol1, String symbol2) {
    final s1 = symbol1.replaceAll(RegExp(r'[₀-₉]'), '');
    final s2 = symbol2.replaceAll(RegExp(r'[₀-₉]'), '');
    if ((s1 == 'H' && s2 == 'O') || (s1 == 'O' && s2 == 'H')) {
      return ChemicalReaction(
        equation: '2H₂ + O₂ → 2H₂O',
        name: 'Water Formation',
        description:
            'Hydrogen reacts with oxygen to form water. This is a synthesis reaction where two elements combine to form a compound.',
        points: 100,
      );
    } else if ((s1 == 'Na' && s2 == 'Cl') || (s1 == 'Cl' && s2 == 'Na')) {
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
