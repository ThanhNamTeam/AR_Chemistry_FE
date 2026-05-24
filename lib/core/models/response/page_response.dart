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

  PageResponse({
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
      T Function(dynamic item) fromJsonT,
      ) {
    return PageResponse<T>(
      items: (json['items'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
      page: json['page'],
      size: json['size'],
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
      first: json['first'],
      last: json['last'],
      hasNext: json['hasNext'],
      hasPrevious: json['hasPrevious'],
    );
  }
}