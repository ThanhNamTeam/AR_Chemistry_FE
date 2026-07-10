class PackageOwnershipResponse {
  final bool owned;
  final String accessType;
  final String? startAt;
  final String? expiredAt;
  final int remainingDays;
  final String message;

  const PackageOwnershipResponse({
    required this.owned,
    required this.accessType,
    required this.startAt,
    required this.expiredAt,
    required this.remainingDays,
    required this.message,
  });

  factory PackageOwnershipResponse.fromJson(Map<String, dynamic> json) {
    return PackageOwnershipResponse(
      owned: json['owned'] == true,
      accessType: json['accessType']?.toString() ?? '',
      startAt: json['startAt']?.toString(),
      expiredAt: json['expiredAt']?.toString(),
      remainingDays: json['remainingDays'] is int
          ? json['remainingDays'] as int
          : int.tryParse(json['remainingDays']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}