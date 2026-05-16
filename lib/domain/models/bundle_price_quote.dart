import 'chemical_card_model.dart';

class BundlePriceQuote {
  final int totalPrice;
  final int discountPercent;
  /// Price shown with strikethrough before [totalPrice] when a sale applies.
  final int compareAtPrice;
  final List<String> ownedCardIds;
  final List<String> remainingCardIds;

  const BundlePriceQuote({
    required this.totalPrice,
    required this.discountPercent,
    required this.compareAtPrice,
    required this.ownedCardIds,
    required this.remainingCardIds,
  });

  bool get canPurchase => remainingCardIds.isNotEmpty;

  bool get hasSale => canPurchase && discountPercent > 0;

  String get saleLabel {
    if (!canPurchase) return '';
    if (discountPercent == 20) return 'Sale 20%';
    if (discountPercent == 10) return 'Sale 10%';
    return '';
  }
}

class BundlePricing {
  /// 0 owned → 20% off bundle total.
  /// 1 owned → 10% off remaining cards.
  /// 2 owned → last card at full single price.
  static BundlePriceQuote calculate(
    BundleModel bundle,
    bool Function(String cardId) isOwned,
    int Function(String cardId) cardPrice,
  ) {
    final owned = <String>[];
    final remaining = <String>[];
    var remainingSum = 0;

    for (final id in bundle.cardIds) {
      if (isOwned(id)) {
        owned.add(id);
      } else {
        remaining.add(id);
        remainingSum += cardPrice(id);
      }
    }

    if (remaining.isEmpty) {
      return BundlePriceQuote(
        totalPrice: 0,
        discountPercent: 0,
        compareAtPrice: 0,
        ownedCardIds: owned,
        remainingCardIds: remaining,
      );
    }

    int price;
    int discount;
    int compareAt;
    if (owned.isEmpty) {
      compareAt = bundle.originalPrice;
      price = (bundle.originalPrice * 0.8).round();
      discount = 20;
    } else if (remaining.length == 1) {
      compareAt = remainingSum;
      price = remainingSum;
      discount = 0;
    } else {
      compareAt = remainingSum;
      price = (remainingSum * 0.9).round();
      discount = 10;
    }

    return BundlePriceQuote(
      totalPrice: price,
      discountPercent: discount,
      compareAtPrice: compareAt,
      ownedCardIds: owned,
      remainingCardIds: remaining,
    );
  }
}
