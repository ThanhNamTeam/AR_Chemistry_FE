class ArScanRewardResponse {
  const ArScanRewardResponse({
    required this.rewarded,
    required this.kpEarned,
    required this.todayRewardedCount,
    required this.dailyLimit,
    required this.currentBalance,
    required this.message,
  });

  final bool rewarded;
  final int kpEarned;
  final int todayRewardedCount;
  final int dailyLimit;
  final int currentBalance;
  final String message;

  factory ArScanRewardResponse.fromJson(Map<String, dynamic> json) {
    return ArScanRewardResponse(
      rewarded: json['rewarded'] == true,
      kpEarned: (json['kpEarned'] as num?)?.toInt() ?? 0,
      todayRewardedCount: (json['todayRewardedCount'] as num?)?.toInt() ?? 0,
      dailyLimit: (json['dailyLimit'] as num?)?.toInt() ?? 5,
      currentBalance: (json['currentBalance'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, Object?> toBridgeJson() {
    return <String, Object?>{
      'rewarded': rewarded,
      'kpEarned': kpEarned,
      'todayRewardedCount': todayRewardedCount,
      'dailyLimit': dailyLimit,
      'currentBalance': currentBalance,
      'message': message,
    };
  }
}