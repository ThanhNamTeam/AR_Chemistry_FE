class ChemicalCardResponse {
  final String id;
  final int atomicNumber;
  final String symbol;
  final String name;
  final String? category;
  final num? atomicMass;
  final int? period;
  final int? groupNumber;
  final int price;
  final bool active;
  final bool purchasable;

  const ChemicalCardResponse({
    required this.id,
    required this.atomicNumber,
    required this.symbol,
    required this.name,
    this.category,
    this.atomicMass,
    this.period,
    this.groupNumber,
    required this.price,
    required this.active,
    required this.purchasable,
  });

  factory ChemicalCardResponse.fromJson(Map<String, dynamic> json) {
    return ChemicalCardResponse(
      id: json['id'] as String,
      atomicNumber: json['atomicNumber'] as int,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      atomicMass: json['atomicMass'] as num?,
      period: json['period'] as int?,
      groupNumber: json['groupNumber'] as int?,
      price: _parseInt(json['price']),
      active: json['active'] == true,
      purchasable: json['purchasable'] == true,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}