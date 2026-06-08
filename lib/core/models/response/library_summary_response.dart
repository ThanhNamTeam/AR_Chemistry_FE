class LibrarySummaryResponse {
  final int unlockedCards;
  final int totalCards;
  final double libraryProgress;

  const LibrarySummaryResponse({
    required this.unlockedCards,
    required this.totalCards,
    required this.libraryProgress,
  });

  factory LibrarySummaryResponse.fromJson(Map<String, dynamic> json) {
    return LibrarySummaryResponse(
      unlockedCards: _parseInt(json['unlockedCards']),
      totalCards: _parseInt(json['totalCards']),
      libraryProgress: _parseDouble(json['libraryProgress']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}