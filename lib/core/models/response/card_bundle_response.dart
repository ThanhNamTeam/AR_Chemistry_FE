// models/response/card_bundle_response.dart

import 'chemical_card_response.dart';

class CardBundleResponse {
  final String id;
  final String name;
  final String description;
  final int originalPrice;
  final int discountedPrice;
  final bool active;
  final bool purchasable;
  final List<ChemicalCardResponse> cards;

  CardBundleResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.active,
    required this.purchasable,
    required this.cards,
  });

  factory CardBundleResponse.fromJson(Map<String, dynamic> json) {
    return CardBundleResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      originalPrice: _toIntPrice(json['originalPrice']),
      discountedPrice: _toIntPrice(json['discountedPrice']),
      active: json['active'] == true,
      purchasable: json['purchasable'] == true,
      cards: ((json['cards'] as List?) ?? [])
          .map((e) => ChemicalCardResponse.fromJson(e))
          .toList(),
    );
  }

  bool get hasSale => originalPrice > discountedPrice;

  int get salePercent {
    if (!hasSale || originalPrice <= 0) return 0;
    return (((originalPrice - discountedPrice) / originalPrice) * 100).round();
  }

  static int _toIntPrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return double.tryParse(value.toString())?.round() ?? 0;
  }
}