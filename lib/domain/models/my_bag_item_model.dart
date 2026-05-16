class MyBagItem {
  final String cardId;
  final bool isPendingActivation;

  const MyBagItem({
    required this.cardId,
    this.isPendingActivation = true,
  });

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'isPendingActivation': isPendingActivation,
      };

  factory MyBagItem.fromJson(Map<String, dynamic> json) => MyBagItem(
        cardId: json['cardId'] as String,
        isPendingActivation: json['isPendingActivation'] as bool? ?? true,
      );
}
