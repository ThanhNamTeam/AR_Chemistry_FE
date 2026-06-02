class CreatePaymentRequest {
  final String itemId;
  final String itemType;
  final String proofImageUrl;

  const CreatePaymentRequest({
    required this.itemId,
    required this.itemType,
    required this.proofImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemType': itemType,
      'proofImageUrl': proofImageUrl,
    };
  }
}