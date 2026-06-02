class PaymentResponse {
  final String id;
  final String email;
  final String packageName;
  final double amount;
  final String proofImageUrl;
  final String status;

  PaymentResponse({
    required this.id,
    required this.email,
    required this.packageName,
    required this.amount,
    required this.proofImageUrl,
    required this.status,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      id: json['id'],
      email: json['email'],

      // packageEntity.name bên backend
      packageName: json['packageEntity']['name'] ?? '',

      amount: (json['amount'] as num).toDouble(),

      proofImageUrl: json['proofImageUrl'] ?? '',

      // enum -> string
      status: json['status'].toString(),
    );
  }
}