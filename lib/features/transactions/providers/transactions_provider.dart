import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/entities/transaction_filter.dart';
import 'package:usdc_wallet/services/transactions/transactions_service.dart';

export 'package:usdc_wallet/domain/entities/transaction_filter.dart';

/// Transaction filter state with convenience methods.
final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
      TransactionFilterNotifier.new,
    );

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setType(String? type) =>
      state = state.copyWith(type: type, clearType: type == null);
  void setStatus(String? status) =>
      state = state.copyWith(status: status, clearStatus: status == null);
  void setDateRange(DateTime? start, DateTime? end) => state = state.copyWith(
    startDate: start,
    endDate: end,
    clearDateRange: start == null && end == null,
  );
  void setAmountRange(double? min, double? max) => state = state.copyWith(
    minAmount: min,
    maxAmount: max,
    clearAmountRange: min == null && max == null,
  );
  void setSearch(String? search) =>
      state = state.copyWith(search: search, clearSearch: search == null);
  void setFilter(TransactionFilter filter) => state = filter;
  void clearAll() => state = const TransactionFilter();
}

/// Paginated transactions provider — wired to GET /wallet/transactions.
final transactionsProvider = FutureProvider<TransactionPage>((ref) async {
  final filter = ref.watch(transactionFilterProvider);
  final service = ref.watch(transactionsServiceProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 1), () => link.close());
  ref.onDispose(() => timer.cancel());

  return service.getTransactions(page: 1, pageSize: 20, filter: filter);
});
