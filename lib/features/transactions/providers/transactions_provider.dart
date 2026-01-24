import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/index.dart';
import '../../../domain/entities/index.dart';

/// Transactions List Provider
final transactionsProvider =
    FutureProvider.autoDispose<TransactionPage>((ref) async {
  final service = ref.watch(transactionsServiceProvider);
  return service.getTransactions();
});

/// Single Transaction Provider
final transactionProvider =
    FutureProvider.autoDispose.family<Transaction, String>((ref, id) async {
  final service = ref.watch(transactionsServiceProvider);
  return service.getTransaction(id);
});

/// Deposit Status Provider
final depositStatusProvider = FutureProvider.autoDispose
    .family<DepositStatusResponse, String>((ref, depositId) async {
  final service = ref.watch(transactionsServiceProvider);
  return service.getDepositStatus(depositId);
});

/// Paginated Transactions State
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

/// Paginated Transactions Notifier
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
