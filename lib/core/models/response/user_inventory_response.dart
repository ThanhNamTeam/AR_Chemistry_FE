class UserInventoryResponse {
  final String id;
  final String userId;
  final String substanceId;

  final String? formula;
  final String? name;
  final String? vietnameseName;

  final String? chemicalGroup;
  final String? state;
  final String? source;
  final String? sourceRef;

  final int quantity;
  final bool active;

  final DateTime? acquiredAt;
  final DateTime? expiresAt;

  UserInventoryResponse({
    required this.id,
    required this.userId,
    required this.substanceId,
    this.formula,
    this.name,
    this.vietnameseName,
    this.chemicalGroup,
    this.state,
    this.source,
    this.sourceRef,
    required this.quantity,
    required this.active,
    this.acquiredAt,
    this.expiresAt,
  });

  factory UserInventoryResponse.fromJson(Map<String, dynamic> json) {
    return UserInventoryResponse(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      substanceId: json['substanceId']?.toString() ?? '',
      formula: json['formula']?.toString(),
      name: json['name']?.toString(),
      vietnameseName: json['vietnameseName']?.toString(),
      chemicalGroup: json['chemicalGroup']?.toString(),
      state: json['state']?.toString(),
      source: json['source']?.toString(),
      sourceRef: json['sourceRef']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      active: json['active'] == true,
      acquiredAt: json['acquiredAt'] == null
          ? null
          : DateTime.tryParse(json['acquiredAt'].toString()),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'].toString()),
    );
  }

  String get displayName {
    if (vietnameseName != null && vietnameseName!.isNotEmpty) {
      return vietnameseName!;
    }

    if (name != null && name!.isNotEmpty) {
      return name!;
    }

    return formula ?? 'Unknown substance';
  }

  String get displayFormula {
    return formula ?? '';
  }

  String get displayQuantity {
    return 'x$quantity';
  }
}