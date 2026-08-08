import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:labedu/domain/models/bundle_price_quote.dart';
import 'package:labedu/domain/models/cart_item_model.dart';
import 'package:labedu/domain/models/chemical_card_model.dart';
import 'package:labedu/domain/models/knowledge_point_wallet.dart';

void main() {
  // ─── KnowledgePointWallet ────────────────────────────────────────────────
  group('KnowledgePointWallet.fromJson', () {
    test('parses all fields correctly', () {
      final wallet = KnowledgePointWallet.fromJson({
        'balance': 500,
        'totalEarned': 1200,
        'totalSpent': 700,
      });
      expect(wallet.balance, 500);
      expect(wallet.totalEarned, 1200);
      expect(wallet.totalSpent, 700);
    });

    test('defaults to 0 when fields are null', () {
      final wallet = KnowledgePointWallet.fromJson({});
      expect(wallet.balance, 0);
      expect(wallet.totalEarned, 0);
      expect(wallet.totalSpent, 0);
    });
  });

  // ─── CartItem ────────────────────────────────────────────────────────────
  group('CartItem', () {
    test('key is type:id for card type', () {
      final item = CartItem(type: CartItemType.card, id: 'H');
      expect(item.key, 'card:H');
    });

    test('key is type:id for bundle type', () {
      final item = CartItem(type: CartItemType.bundle, id: 'bundle1');
      expect(item.key, 'bundle:bundle1');
    });

    test('toJson encodes correctly', () {
      final item = CartItem(type: CartItemType.card, id: 'Na');
      final json = item.toJson();
      expect(json['type'], 'card');
      expect(json['id'], 'Na');
    });

    test('fromJson parses card type', () {
      final item = CartItem.fromJson({'type': 'card', 'id': 'Fe'});
      expect(item.type, CartItemType.card);
      expect(item.id, 'Fe');
    });

    test('fromJson parses bundle type', () {
      final item = CartItem.fromJson({'type': 'bundle', 'id': 'bundle_starter'});
      expect(item.type, CartItemType.bundle);
      expect(item.id, 'bundle_starter');
    });

    test('fromJson defaults to card for unknown type', () {
      final item = CartItem.fromJson({'type': 'unknown', 'id': 'x'});
      expect(item.type, CartItemType.card);
    });

    test('fromJson defaults to card when type is null', () {
      final item = CartItem.fromJson({'id': 'x'});
      expect(item.type, CartItemType.card);
    });
  });

  // ─── ChemicalData.colorForCategory ───────────────────────────────────────
  group('ChemicalData.colorForCategory', () {
    test('Alkali metal returns amber color', () {
      final color = ChemicalData.colorForCategory('Alkali metal');
      expect(color, const Color(0xFFF59E0B));
    });

    test('Alkaline earth metal returns lime color', () {
      expect(ChemicalData.colorForCategory('Alkaline earth metal'),
          const Color(0xFF84CC16));
    });

    test('Transition metal returns red', () {
      expect(ChemicalData.colorForCategory('Transition metal'),
          const Color(0xFFEF4444));
    });

    test('Post-transition metal returns sky blue', () {
      expect(ChemicalData.colorForCategory('Post-transition metal'),
          const Color(0xFF0EA5E9));
    });

    test('Metalloid returns green', () {
      expect(ChemicalData.colorForCategory('Metalloid'),
          const Color(0xFF22C55E));
    });

    test('Diatomic nonmetal returns cyan', () {
      expect(ChemicalData.colorForCategory('Diatomic nonmetal'),
          const Color(0xFF06B6D4));
    });

    test('Polyatomic nonmetal returns cyan', () {
      expect(ChemicalData.colorForCategory('Polyatomic nonmetal'),
          const Color(0xFF06B6D4));
    });

    test('Noble gas returns purple', () {
      expect(ChemicalData.colorForCategory('Noble gas'),
          const Color(0xFF8B5CF6));
    });

    test('Lanthanide returns pink', () {
      expect(ChemicalData.colorForCategory('Lanthanide'),
          const Color(0xFFEC4899));
    });

    test('Actinide returns orange', () {
      expect(ChemicalData.colorForCategory('Actinide'),
          const Color(0xFFF97316));
    });

    test('null returns slate gray', () {
      expect(ChemicalData.colorForCategory(null),
          const Color(0xFF94A3B8));
    });

    test('unknown category returns slate gray', () {
      expect(ChemicalData.colorForCategory('Unknown'),
          const Color(0xFF94A3B8));
    });
  });

  // ─── ChemicalData.getReaction ─────────────────────────────────────────────
  group('ChemicalData.getReaction', () {
    test('H + O yields water formation', () {
      final r = ChemicalData.getReaction('H', 'O');
      expect(r.name, 'Water Formation');
      expect(r.equation, contains('H₂O'));
      expect(r.points, 100);
    });

    test('O + H also yields water formation', () {
      final r = ChemicalData.getReaction('O', 'H');
      expect(r.name, 'Water Formation');
    });

    test('Na + Cl yields salt formation', () {
      final r = ChemicalData.getReaction('Na', 'Cl');
      expect(r.name, 'Salt Formation');
      expect(r.equation, contains('NaCl'));
    });

    test('Cl + Na also yields salt formation', () {
      final r = ChemicalData.getReaction('Cl', 'Na');
      expect(r.name, 'Salt Formation');
    });

    test('unknown combination yields generic reaction', () {
      final r = ChemicalData.getReaction('Fe', 'Cu');
      expect(r.name, 'Chemical Combination');
      expect(r.equation, contains('Fe'));
      expect(r.equation, contains('Cu'));
    });
  });

  // ─── BundlePricing.calculate ──────────────────────────────────────────────
  group('BundlePricing.calculate', () {
    final bundle = BundleModel(
      id: 'b1',
      name: 'Starter Pack',
      cardIds: ['Na', 'Mg', 'Cl'],
      originalPrice: 9000,
      discountedPrice: 7200,
    );

    test('0 owned → 20% off original price', () {
      final quote = BundlePricing.calculate(
        bundle,
        (_) => false,
        (_) => 3000,
      );
      expect(quote.discountPercent, 20);
      expect(quote.totalPrice, (9000 * 0.8).round());
      expect(quote.compareAtPrice, 9000);
      expect(quote.canPurchase, true);
      expect(quote.hasSale, true);
      expect(quote.saleLabel, 'Sale 20%');
      expect(quote.ownedCardIds, isEmpty);
      expect(quote.remainingCardIds.length, 3);
    });

    test('2 owned, 1 remaining → full single price', () {
      final ownedCards = {'Na', 'Mg'};
      final quote = BundlePricing.calculate(
        bundle,
        (id) => ownedCards.contains(id),
        (_) => 3000,
      );
      expect(quote.discountPercent, 0);
      expect(quote.totalPrice, 3000);
      expect(quote.ownedCardIds.length, 2);
      expect(quote.remainingCardIds.length, 1);
      expect(quote.saleLabel, '');
    });

    test('1 owned, 2 remaining → 10% off remaining', () {
      final quote = BundlePricing.calculate(
        bundle,
        (id) => id == 'Na',
        (_) => 3000,
      );
      expect(quote.discountPercent, 10);
      expect(quote.totalPrice, (6000 * 0.9).round());
      expect(quote.saleLabel, 'Sale 10%');
      expect(quote.hasSale, true);
    });

    test('all owned → canPurchase false', () {
      final quote = BundlePricing.calculate(
        bundle,
        (_) => true,
        (_) => 3000,
      );
      expect(quote.canPurchase, false);
      expect(quote.hasSale, false);
      expect(quote.saleLabel, '');
      expect(quote.totalPrice, 0);
    });
  });

  // ─── BundlePriceQuote getters ─────────────────────────────────────────────
  group('BundlePriceQuote', () {
    test('saleLabel for 20% discount', () {
      const q = BundlePriceQuote(
        totalPrice: 8000,
        discountPercent: 20,
        compareAtPrice: 10000,
        ownedCardIds: [],
        remainingCardIds: ['x'],
      );
      expect(q.saleLabel, 'Sale 20%');
      expect(q.hasSale, true);
    });

    test('saleLabel for 10% discount', () {
      const q = BundlePriceQuote(
        totalPrice: 5400,
        discountPercent: 10,
        compareAtPrice: 6000,
        ownedCardIds: ['a'],
        remainingCardIds: ['b', 'c'],
      );
      expect(q.saleLabel, 'Sale 10%');
    });

    test('saleLabel empty when no purchase remaining', () {
      const q = BundlePriceQuote(
        totalPrice: 0,
        discountPercent: 0,
        compareAtPrice: 0,
        ownedCardIds: ['x', 'y', 'z'],
        remainingCardIds: [],
      );
      expect(q.saleLabel, '');
      expect(q.canPurchase, false);
    });

    test('saleLabel empty when discountPercent is other value', () {
      const q = BundlePriceQuote(
        totalPrice: 3000,
        discountPercent: 5,
        compareAtPrice: 3200,
        ownedCardIds: [],
        remainingCardIds: ['a'],
      );
      expect(q.saleLabel, '');
    });
  });
}
