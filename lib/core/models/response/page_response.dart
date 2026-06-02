class PageResponse<T> {
  final List<T> items;
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;
  final bool first;
  final bool last;
  final bool hasNext;
  final bool hasPrevious;

  const PageResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PageResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    final rawItems = json['items'];

    return PageResponse<T>(
      items: rawItems is List
          ? rawItems
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(fromJson)
          .toList()
          : [],
      page: _parseInt(json['page']),
      size: _parseInt(json['size']),
      totalItems: _parseInt(json['totalItems']),
      totalPages: _parseInt(json['totalPages']),
      first: json['first'] == true,
      last: json['last'] == true,
      hasNext: json['hasNext'] == true,
      hasPrevious: json['hasPrevious'] == true,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}