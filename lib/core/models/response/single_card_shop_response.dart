// lib/core/models/response/single_card_shop_response.dart

class SingleCardShopResponse {
  final String id;
  final String code;
  final String name;
  final String? description;
  final int price;
  final int durationDays;
  final bool active;
  final String? googlePlayProductId;

  final String substanceId;
  final String substanceFormula;
  final String substanceName;
  final String? substanceVietnameseName;

  SingleCardShopResponse({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.price,
    required this.durationDays,
    required this.active,
    this.googlePlayProductId,
    required this.substanceId,
    required this.substanceFormula,
    required this.substanceName,
    this.substanceVietnameseName,
  });

  factory SingleCardShopResponse.fromJson(Map<String, dynamic> json) {
    return SingleCardShopResponse(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: _toInt(json['price']),
      durationDays: _toInt(json['durationDays']),
      active: json['active'] == true,
      googlePlayProductId: json['googlePlayProductId'],
      substanceId: json['substanceId'] ?? '',
      substanceFormula: json['substanceFormula'] ?? '',
      substanceName: json['substanceName'] ?? '',
      substanceVietnameseName: json['substanceVietnameseName'],
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return double.tryParse(value)?.round() ?? 0;
    return 0;
  }
}