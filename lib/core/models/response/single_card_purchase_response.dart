// lib/core/models/response/single_card_purchase_response.dart

class SingleCardPurchaseResponse {
  final String purchaseId;
  final String singleCardId;
  final String singleCardName;
  final String substanceId;
  final String substanceName;
  final String? substanceFormula;
  final String qrContent;
  final String? qrImageUrl;
  final DateTime? purchasedAt;
  final DateTime? expiredAt;
  final String status;

  SingleCardPurchaseResponse({
    required this.purchaseId,
    required this.singleCardId,
    required this.singleCardName,
    required this.substanceId,
    required this.substanceName,
    this.substanceFormula,
    required this.qrContent,
    this.qrImageUrl,
    this.purchasedAt,
    this.expiredAt,
    required this.status,
  });

  factory SingleCardPurchaseResponse.fromJson(Map<String, dynamic> json) {
    return SingleCardPurchaseResponse(
      purchaseId: json['purchaseId'] ?? '',
      singleCardId: json['singleCardId'] ?? '',
      singleCardName: json['singleCardName'] ?? '',
      substanceId: json['substanceId'] ?? '',
      substanceName: json['substanceName'] ?? '',
      substanceFormula: json['substanceFormula'],
      qrContent: json['qrContent'] ?? '',
      qrImageUrl: json['qrImageUrl'],
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.tryParse(json['purchasedAt'])
          : null,
      expiredAt: json['expiredAt'] != null
          ? DateTime.tryParse(json['expiredAt'])
          : null,
      status: json['status'] ?? '',
    );
  }
}