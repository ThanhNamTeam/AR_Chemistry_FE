class ArAccessResponse {
  final bool canScanAR;
  final String accessType;
  final DateTime? startAt;
  final DateTime? expiredAt;
  final int remainingDays;
  final String message;

  ArAccessResponse({
    required this.canScanAR,
    required this.accessType,
    required this.startAt,
    required this.expiredAt,
    required this.remainingDays,
    required this.message,
  });

  factory ArAccessResponse.fromJson(Map<String, dynamic> json) {
    return ArAccessResponse(
      canScanAR: json['canScanAR'] == true,
      accessType: json['accessType'] ?? 'FREE',
      startAt: json['startAt'] != null
          ? DateTime.parse(json['startAt'])
          : null,
      expiredAt: json['expiredAt'] != null
          ? DateTime.parse(json['expiredAt'])
          : null,
      remainingDays: json['remainingDays'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}