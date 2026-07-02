class KnowledgePointWallet {
  final int balance;
  final int totalEarned;
  final int totalSpent;

  const KnowledgePointWallet({
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
  });

  factory KnowledgePointWallet.fromJson(Map<String, dynamic> json) {
    return KnowledgePointWallet(
      balance: (json['balance'] ?? 0) as int,
      totalEarned: (json['totalEarned'] ?? 0) as int,
      totalSpent: (json['totalSpent'] ?? 0) as int,
    );
  }
}