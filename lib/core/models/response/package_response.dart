class PackageResponse {
  final String id;
  final String packageType;
  final String name;
  final int price;
  final int durationDays;

  PackageResponse({
    required this.id,
    required this.packageType,
    required this.name,
    required this.price,
    required this.durationDays,
  });

  factory PackageResponse.fromJson(Map<String, dynamic> json) {
    return PackageResponse(
      id: json['id']?.toString() ?? '',
      packageType: json['packageType']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: _parsePrice(json['price']),
      durationDays: json['durationDays'] ?? 0,
    );
  }

  static int _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return double.tryParse(value)?.round() ?? 0;
    }
    return 0;
  }
}