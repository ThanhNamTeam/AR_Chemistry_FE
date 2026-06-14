class MySingleCardPurchaseResponse {
  final String purchaseId;
  final String singleCardId;
  final String? singleCardCode;
  final String? singleCardName;

  final String? substanceId;
  final String? substanceFormula;
  final String? substanceName;
  final String? substanceVietnameseName;

  final String? qrContent;
  final String? qrImageUrl;

  final DateTime? purchasedAt;
  final DateTime? startAt;
  final DateTime? expiredAt;

  final String? purchaseStatus;
  final String? accessStatus;
  final bool active;

  MySingleCardPurchaseResponse({
    required this.purchaseId,
    required this.singleCardId,
    this.singleCardCode,
    this.singleCardName,
    this.substanceId,
    this.substanceFormula,
    this.substanceName,
    this.substanceVietnameseName,
    this.qrContent,
    this.qrImageUrl,
    this.purchasedAt,
    this.startAt,
    this.expiredAt,
    this.purchaseStatus,
    this.accessStatus,
    required this.active,
  });

  factory MySingleCardPurchaseResponse.fromJson(Map<String, dynamic> json) {
    return MySingleCardPurchaseResponse(
      purchaseId: json['purchaseId'] ?? '',
      singleCardId: json['singleCardId'] ?? '',
      singleCardCode: json['singleCardCode'],
      singleCardName: json['singleCardName'],
      substanceId: json['substanceId'],
      substanceFormula: json['substanceFormula'],
      substanceName: json['substanceName'],
      substanceVietnameseName: json['substanceVietnameseName'],
      qrContent: json['qrContent'],
      qrImageUrl: json['qrImageUrl'],
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.tryParse(json['purchasedAt'])
          : null,
      startAt: json['startAt'] != null
          ? DateTime.tryParse(json['startAt'])
          : null,
      expiredAt: json['expiredAt'] != null
          ? DateTime.tryParse(json['expiredAt'])
          : null,
      purchaseStatus: json['purchaseStatus'],
      accessStatus: json['accessStatus'],
      active: json['active'] == true,
    );
  }
}