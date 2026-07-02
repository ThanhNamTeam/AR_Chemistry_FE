// lib/core/models/response/single_card_shop_response.dart

class SingleCardShopResponse {
  final String id;
  final String code;
  final String name;
  final String? description;

  /// Giá card bằng Knowledge Point
  final int kpPrice;

  final int durationDays;
  final bool active;

  final String substanceId;
  final String substanceFormula;
  final String substanceName;
  final String? substanceVietnameseName;
  final String? frontImageUrl;
  final String? backImageUrl;

  SingleCardShopResponse({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.kpPrice,
    required this.durationDays,
    required this.active,
    required this.substanceId,
    required this.substanceFormula,
    required this.substanceName,
    this.substanceVietnameseName,
    this.frontImageUrl,
    this.backImageUrl,
  });

  factory SingleCardShopResponse.fromJson(Map<String, dynamic> json) {
    return SingleCardShopResponse(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      kpPrice: _toInt(json['kpPrice']),
      durationDays: _toInt(json['durationDays']),
      active: json['active'] == true,
      substanceId: json['substanceId']?.toString() ?? '',
      substanceFormula: json['substanceFormula']?.toString() ?? '',
      substanceName: json['substanceName']?.toString() ?? '',
      substanceVietnameseName: json['substanceVietnameseName']?.toString(),
      frontImageUrl: json['frontImageUrl'] as String?,
      backImageUrl: json['backImageUrl'] as String?,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) return double.tryParse(value)?.round() ?? 0;
    return 0;
  }
}