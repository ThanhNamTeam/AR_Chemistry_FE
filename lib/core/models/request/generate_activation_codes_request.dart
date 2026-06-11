class GenerateActivationCodesRequest {
  final String kitCode;
  final int quantity;
  final DateTime? expiresAt;
  final String? note;

  const GenerateActivationCodesRequest({
    required this.kitCode,
    required this.quantity,
    this.expiresAt,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'kitCode': kitCode,
      'quantity': quantity,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      if (note != null && note!.trim().isNotEmpty) 'note': note,
    };
  }
}