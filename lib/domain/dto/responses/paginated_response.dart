/// Generic paginated response wrapper.
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItemJson,
  ) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => fromItemJson(e as Map<String, dynamic>))
            .toList() ??
        <T>[];
    final total = json['total'] as int? ?? itemsList.length;
    final page = json['page'] as int? ?? 1;
    final pageSize = json['pageSize'] as int? ?? 20;
    return PaginatedResponse(
      items: itemsList,
      total: total,
      page: page,
      pageSize: pageSize,
      hasMore: (page * pageSize) < total,
    );
  }
}
