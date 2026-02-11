import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/services/index.dart';
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart' hide TransactionFilter;
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

/// Transaction State Machine - manages transaction list globally
/// Now supports server-side filtering via TransactionFilter
class TransactionStateMachine extends Notifier<TransactionListState> {
  static const int _pageSize = 20;

  @override
  TransactionListState build() {
    _autoFetch();
    return const TransactionListState();
  }

  TransactionsService get _service => ref.read(transactionsServiceProvider);
  TransactionFilter get _filter => const TransactionFilter();

  void _autoFetch() {
    Future.microtask(() => fetch());
  }

  /// Fetch initial transactions
  Future<void> fetch() async {
    if (state.status == TransactionListStatus.loading) return;

    state = state.copyWith(status: TransactionListStatus.loading);

    try {
      final page = await _service.getTransactions(
        page: 1,
        pageSize: _pageSize,
        filter: _filter,
      ).timeout(const Duration(seconds: 10));

      state = state.copyWith(
        status: TransactionListStatus.loaded,
        transactions: page.transactions,
        total: page.total,
        page: 1,
        hasMore: page.hasMore,
        error: null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: TransactionListStatus.error,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: TransactionListStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Refresh transactions
  Future<void> refresh() async {
    if (state.isLoading) return;

    state = state.copyWith(status: TransactionListStatus.refreshing);

    try {
      final page = await _service.getTransactions(
        page: 1,
        pageSize: _pageSize,
        filter: _filter,
      );

      state = state.copyWith(
        status: TransactionListStatus.loaded,
        transactions: page.transactions,
        total: page.total,
        page: 1,
        hasMore: page.hasMore,
        error: null,
      );

      // Also refresh wallet balance when transactions refresh
      ref.read(walletStateMachineProvider.notifier).refresh();
    } catch (e) {
      state = state.copyWith(status: TransactionListStatus.loaded);
    }
  }

  /// Load more transactions (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(status: TransactionListStatus.loadingMore);

    try {
      final nextPage = state.page + 1;
      final page = await _service.getTransactions(
        page: nextPage,
        pageSize: _pageSize,
        filter: _filter,
      );

      state = state.copyWith(
        status: TransactionListStatus.loaded,
        transactions: [...state.transactions, ...page.transactions],
        total: page.total,
        page: nextPage,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(status: TransactionListStatus.loaded);
    }
  }

  /// Add a new transaction to the list (after successful transfer/deposit)
  void addTransaction(Transaction transaction) {
    state = state.copyWith(
      transactions: [transaction, ...state.transactions],
      total: state.total + 1,
    );
  }

  /// Update a transaction status
  void updateTransaction(String id, TransactionStatus newStatus) {
    final updatedList = state.transactions.map((tx) {
      if (tx.id == id) {
        return Transaction(
          id: tx.id,
          walletId: tx.walletId,
          type: tx.type,
          status: newStatus,
          amount: tx.amount,
          currency: tx.currency,
          fee: tx.fee,
          description: tx.description,
          externalReference: tx.externalReference,
          failureReason: tx.failureReason,
          recipientPhone: tx.recipientPhone,
          recipientAddress: tx.recipientAddress,
          recipientWalletId: tx.recipientWalletId,
          metadata: tx.metadata,
          createdAt: tx.createdAt,
          completedAt: newStatus == TransactionStatus.completed
              ? DateTime.now()
              : tx.completedAt,
        );
      }
      return tx;
    }).toList();

    state = state.copyWith(transactions: updatedList);
  }

  /// Reset state (on logout)
  void reset() {
    state = const TransactionListState();
  }
}

final transactionStateMachineProvider =
    NotifierProvider<TransactionStateMachine, TransactionListState>(
  TransactionStateMachine.new,
);

/// Convenience providers
final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final state = ref.watch(transactionStateMachineProvider);
  return state.transactions.take(5).toList();
});

final pendingTransactionsProvider = Provider<List<Transaction>>((ref) {
  final state = ref.watch(transactionStateMachineProvider);
  return state.transactions.where((tx) => tx.isPending).toList();
});

final pendingTransactionCountProvider = Provider<int>((ref) {
  return ref.watch(pendingTransactionsProvider).length;
});
