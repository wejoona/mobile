class FilteredPaginatedTransactionsState {
  final bool isLoading;
  final String? error;
  final List<dynamic> transactions;
  final bool hasMore;
  final int page;

  const FilteredPaginatedTransactionsState({this.isLoading = false, this.error, this.transactions = const [], this.hasMore = false, this.page = 1});

  FilteredPaginatedTransactionsState copyWith({bool? isLoading, String? error, List<dynamic>? transactions, bool? hasMore, int? page}) =>
    FilteredPaginatedTransactionsState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, transactions: transactions ?? this.transactions, hasMore: hasMore ?? this.hasMore, page: page ?? this.page);
}
