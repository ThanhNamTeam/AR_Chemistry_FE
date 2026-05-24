class CreatePaymentRequest {
  final String packageId;
  final String proofImageUrl;

  CreatePaymentRequest({
    required this.packageId,
    required this.proofImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'proofImageUrl': proofImageUrl,
    };
  }
}