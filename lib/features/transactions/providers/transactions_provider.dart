import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/index.dart';
import '../../../domain/entities/index.dart';

/// Transaction Filter Provider - Global filter state (using modern Notifier pattern)
final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
  TransactionFilterNotifier.new,
);

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setFilter(TransactionFilter filter) => state = filter;

  void setType(String? type) =>
      state = state.copyWith(type: type, clearType: type == null);

  void setStatus(String? status) =>
      state = state.copyWith(status: status, clearStatus: status == null);

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      clearDateRange: start == null && end == null,
    );
  }

  void setAmountRange(double? min, double? max) {
    state = state.copyWith(
      minAmount: min,
      maxAmount: max,
      clearAmountRange: min == null && max == null,
    );
  }

  void setSearch(String? query) =>
      state = state.copyWith(search: query, clearSearch: query == null || query.isEmpty);

  void setSorting(String sortBy, String sortOrder) =>
      state = state.copyWith(sortBy: sortBy, sortOrder: sortOrder);

  void clearAll() => state = const TransactionFilter();
}

/// Transactions List Provider with TTL-based caching
/// Cache duration: 1 minute
final transactionsProvider =
    FutureProvider<TransactionPage>((ref) async {
  final service = ref.watch(transactionsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 1 minute
  Timer(const Duration(minutes: 1), () {
    link.close();
  });

  return service.getTransactions();
});

/// Filtered Transactions Provider
/// Fetches transactions based on the current filter state
final filteredTransactionsProvider =
    FutureProvider<TransactionPage>((ref) async {
  final filter = ref.watch(transactionFilterProvider);
  final service = ref.watch(transactionsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 1 minute
  Timer(const Duration(minutes: 1), () {
    link.close();
  });

  return service.getTransactions(filter: filter);
});

/// Deposit Status Provider with TTL-based caching
/// Cache duration: 30 seconds (status changes frequently during deposit)
final depositStatusProvider = FutureProvider
    .family<DepositStatusResponse, String>((ref, depositId) async {
  final service = ref.watch(transactionsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 30 seconds
  Timer(const Duration(seconds: 30), () {
    link.close();
  });

  return service.getDepositStatus(depositId);
});

/// Paginated Transactions State with Filter Support
class FilteredPaginatedTransactionsState {
  final List<Transaction> transactions;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final int total;
  final String? error;
  final TransactionFilter filter;

  const FilteredPaginatedTransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.total = 0,
    this.error,
    this.filter = const TransactionFilter(),
  });

  FilteredPaginatedTransactionsState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    int? total,
    String? error,
    TransactionFilter? filter,
  }) {
    return FilteredPaginatedTransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      error: error,
      filter: filter ?? this.filter,
    );
  }
}

/// Paginated Transactions Notifier with Filter Support
class FilteredPaginatedTransactionsNotifier
    extends Notifier<FilteredPaginatedTransactionsState> {
  static const int _pageSize = 20;

  @override
  FilteredPaginatedTransactionsState build() {
    // Listen to filter changes and reload
    ref.listen(transactionFilterProvider, (previous, next) {
      if (previous != next) {
        loadInitial();
      }
    });

    // Load initial data when the notifier is created
    Future.microtask(() => loadInitial());
    return const FilteredPaginatedTransactionsState(isLoading: true);
  }

  TransactionsService get _service => ref.read(transactionsServiceProvider);
  TransactionFilter get _filter => ref.read(transactionFilterProvider);

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null, filter: _filter);

    try {
      final page = await _service.getTransactions(
        page: 1,
        pageSize: _pageSize,
        filter: _filter,
      );

      state = state.copyWith(
        transactions: page.transactions,
        isLoading: false,
        hasMore: page.hasMore,
        currentPage: 1,
        total: page.total,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final page = await _service.getTransactions(
        page: nextPage,
        pageSize: _pageSize,
        filter: _filter,
      );

      state = state.copyWith(
        transactions: [...state.transactions, ...page.transactions],
        isLoading: false,
        hasMore: page.hasMore,
        currentPage: nextPage,
        total: page.total,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> refresh() async {
    state = FilteredPaginatedTransactionsState(
      isLoading: true,
      filter: _filter,
    );
    await loadInitial();
  }
}

final filteredPaginatedTransactionsProvider = NotifierProvider<
    FilteredPaginatedTransactionsNotifier, FilteredPaginatedTransactionsState>(
  FilteredPaginatedTransactionsNotifier.new,
);

/// Legacy Paginated Transactions State (for backward compatibility)
class PaginatedTransactionsState {
  final List<Transaction> transactions;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const PaginatedTransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  PaginatedTransactionsState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return PaginatedTransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

/// Legacy Paginated Transactions Notifier (for backward compatibility)
class PaginatedTransactionsNotifier
    extends Notifier<PaginatedTransactionsState> {
  @override
  PaginatedTransactionsState build() {
    // Load initial data when the notifier is created
    Future.microtask(() => loadInitial());
    return const PaginatedTransactionsState(isLoading: true);
  }

  TransactionsService get _service => ref.read(transactionsServiceProvider);

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final page = await _service.getTransactions(page: 1);

      state = state.copyWith(
        transactions: page.transactions,
        isLoading: false,
        hasMore: page.hasMore,
        currentPage: 1,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final page = await _service.getTransactions(page: nextPage);

      state = state.copyWith(
        transactions: [...state.transactions, ...page.transactions],
        isLoading: false,
        hasMore: page.hasMore,
        currentPage: nextPage,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> refresh() async {
    state = const PaginatedTransactionsState(isLoading: true);
    await loadInitial();
  }
}

final paginatedTransactionsProvider = NotifierProvider.autoDispose<
    PaginatedTransactionsNotifier, PaginatedTransactionsState>(
  PaginatedTransactionsNotifier.new,
);
