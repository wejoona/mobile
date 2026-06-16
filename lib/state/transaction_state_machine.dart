import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/services/index.dart';
import 'package:usdc_wallet/services/storage/sync_service.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Transaction State Machine - manages transaction list globally
/// Now supports server-side filtering via TransactionFilter
class TransactionStateMachine extends Notifier<TransactionListState> {
  static const _logger = AppLogger('TransactionState');

  @override
  TransactionListState build() {
    // Fetches are triggered explicitly after auth/unlock or by transaction views.
    // Auto-fetching on provider construction causes unauthenticated/background
    // network calls when the provider is created only to reset state on logout.
    return const TransactionListState();
  }

  TransactionsService get _service => ref.read(transactionsServiceProvider);
  TransactionFilter get _filter => const TransactionFilter();

  /// Fetch initial transactions
  Future<void> fetch() async {
    if (state.status == TransactionListStatus.loading) {
      return;
    }

    state = state.copyWith(status: TransactionListStatus.loading);

    try {
      final page = await _service
          .getTransactions(filter: _filter)
          .timeout(const Duration(seconds: 10));

      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(
        status: TransactionListStatus.loaded,
        transactions: page.transactions,
        total: page.total,
        page: 1,
        hasMore: page.hasMore,
        isCached: false,
      );

      // Cache locally for offline access
      ref
          .read(localSyncServiceProvider)
          .cacheTransactionsFromList(page.transactions);
    } on ApiException catch (e) {
      if (!ref.mounted) {
        return;
      }

      // Try cached data on error
      final cached = ref
          .read(localSyncServiceProvider)
          .cachedTransactionsToDomain();
      if (cached.isNotEmpty) {
        state = state.copyWith(
          status: TransactionListStatus.loaded,
          transactions: cached,
          total: cached.length,
          page: 1,
          hasMore: false,
          isCached: true,
        );
        _logger.debug('Loaded ${cached.length} from cache');
        return;
      }
      state = state.copyWith(
        status: TransactionListStatus.error,
        error: e.message,
      );
    } on Object catch (error) {
      if (!ref.mounted) {
        return;
      }

      final cached = ref
          .read(localSyncServiceProvider)
          .cachedTransactionsToDomain();
      if (cached.isNotEmpty) {
        state = state.copyWith(
          status: TransactionListStatus.loaded,
          transactions: cached,
          total: cached.length,
          page: 1,
          hasMore: false,
          isCached: true,
        );
        _logger.debug('Loaded ${cached.length} from cache');
        return;
      }
      state = state.copyWith(
        status: TransactionListStatus.error,
        error: error.toString(),
      );
    }
  }

  /// Refresh transactions
  Future<void> refresh({bool refreshWallet = true}) async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(status: TransactionListStatus.refreshing);

    try {
      final page = await _service
          .getTransactions(filter: _filter)
          .timeout(const Duration(seconds: 10));

      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(
        status: TransactionListStatus.loaded,
        transactions: page.transactions,
        total: page.total,
        page: 1,
        hasMore: page.hasMore,
        isCached: false,
      );

      ref
          .read(localSyncServiceProvider)
          .cacheTransactionsFromList(page.transactions);

      if (refreshWallet) {
        // Also refresh wallet balance when transactions refresh
        unawaited(ref.read(walletStateMachineProvider.notifier).refresh());
      }
    } on ApiException catch (e) {
      if (!ref.mounted) {
        return;
      }

      _completeFailedRefresh(e.message);
    } on Object catch (error) {
      if (!ref.mounted) {
        return;
      }

      _completeFailedRefresh(error.toString());
    }
  }

  void _completeFailedRefresh(String message) {
    if (state.transactions.isNotEmpty) {
      state = state.copyWith(
        status: TransactionListStatus.loaded,
        isCached: state.isCached,
      );
      return;
    }

    final cached = ref
        .read(localSyncServiceProvider)
        .cachedTransactionsToDomain();
    if (cached.isNotEmpty) {
      state = state.copyWith(
        status: TransactionListStatus.loaded,
        transactions: cached,
        total: cached.length,
        page: 1,
        hasMore: false,
        isCached: true,
      );
      _logger.debug('Loaded ${cached.length} from cache after refresh failure');
      return;
    }

    state = state.copyWith(status: TransactionListStatus.error, error: message);
  }

  /// Load more transactions (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) {
      return;
    }

    state = state.copyWith(status: TransactionListStatus.loadingMore);

    try {
      final nextPage = state.page + 1;
      final page = await _service.getTransactions(
        page: nextPage,
        filter: _filter,
      );

      state = state.copyWith(
        status: TransactionListStatus.loaded,
        transactions: [...state.transactions, ...page.transactions],
        total: page.total,
        page: nextPage,
        hasMore: page.hasMore,
      );
    } on Object {
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
          counterpartyName: tx.counterpartyName,
          counterpartyPhone: tx.counterpartyPhone,
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

final pendingTransactionCountProvider = Provider<int>(
  (ref) => ref.watch(pendingTransactionsProvider).length,
);
