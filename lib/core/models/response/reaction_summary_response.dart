class ReactionSummaryResponse {
  final int totalReactions;

  const ReactionSummaryResponse({
    required this.totalReactions,
  });

  factory ReactionSummaryResponse.fromJson(Map<String, dynamic> json) {
    return ReactionSummaryResponse(
      totalReactions: _parseInt(json['totalReactions']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}