import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/transactions/transactions_service.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/entities/transaction_filter.dart';

/// Repository for transaction operations.
///
/// Wraps [TransactionsService] with pagination and filtering.
class TransactionsRepository {
  final TransactionsService _service;

  TransactionsRepository(this._service);

  /// Get paginated transactions.
  Future<List<Transaction>> getTransactions({
    int page = 1,
    int pageSize = 20,
    TransactionFilter? filter,
  }) async {
    return _service.getTransactions(
      page: page,
      pageSize: pageSize,
      filter: filter,
    );
  }

  /// Get a single transaction by ID.
  Future<Transaction> getTransaction(String id) async {
    return _service.getTransaction(id);
  }
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final service = ref.watch(transactionsServiceProvider);
  return TransactionsRepository(service);
});
