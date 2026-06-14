class KitSubstanceModel {
  final String id;
  final String formula;
  final String name;
  final String? vietnameseName;
  final bool active;

  const KitSubstanceModel({
    required this.id,
    required this.formula,
    required this.name,
    this.vietnameseName,
    required this.active,
  });

  factory KitSubstanceModel.fromJson(Map<String, dynamic> json) {
    return KitSubstanceModel(
      id: json['id']?.toString() ?? '',
      formula: json['formula']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      vietnameseName: json['vietnameseName']?.toString(),
      active: json['active'] == true,
    );
  }

  String get displayName {
    if (vietnameseName != null && vietnameseName!.trim().isNotEmpty) {
      return vietnameseName!;
    }
    return name;
  }
}

class KitModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final double? price;
  final bool active;
  final List<KitSubstanceModel> items;

  const KitModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.price,
    required this.active,
    required this.items,
  });

  factory KitModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return KitModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: _toDouble(json['price']),
      active: json['active'] == true,
      items: rawItems is List
          ? rawItems
          .whereType<Map<String, dynamic>>()
          .map(KitSubstanceModel.fromJson)
          .toList()
          : const [],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}