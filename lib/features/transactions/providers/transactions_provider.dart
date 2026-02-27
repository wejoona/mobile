import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/domain/entities/transaction_filter.dart';

export 'package:usdc_wallet/domain/entities/transaction_filter.dart';

/// Transaction filter state with convenience methods.
final transactionFilterProvider = NotifierProvider<TransactionFilterNotifier, TransactionFilter>(TransactionFilterNotifier.new);

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setType(String? type) => state = state.copyWith(type: type, clearType: type == null);
  void setStatus(String? status) => state = state.copyWith(status: status, clearStatus: status == null);
  void setDateRange(DateTime? start, DateTime? end) => state = state.copyWith(startDate: start, endDate: end, clearDateRange: start == null && end == null);
  void setAmountRange(double? min, double? max) => state = state.copyWith(minAmount: min, maxAmount: max, clearAmountRange: min == null && max == null);
  void setSearch(String? search) => state = state.copyWith(search: search, clearSearch: search == null);
  void setFilter(TransactionFilter filter) => state = filter;
  void clearAll() => state = const TransactionFilter();
}

/// Paginated transactions provider — wired to GET /wallet/transactions.
final transactionsProvider = FutureProvider<TransactionPage>((ref) async {
  final filter = ref.watch(transactionFilterProvider);
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 1), () => link.close());
  ref.onDispose(() => timer.cancel());

  final response = await dio.get('/wallet/transactions', queryParameters: filter.toQueryParams());
  return TransactionPage.fromJson(response.data as Map<String, dynamic>);
});

/// Transaction page model.
class TransactionPage {
  final List<TransactionItem> items;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const TransactionPage({this.items = const [], this.total = 0, this.page = 1, this.limit = 20, this.hasMore = false});

  factory TransactionPage.fromJson(Map<String, dynamic> json) => TransactionPage(
    // Backend returns { transactions: [...] } — also check 'data' and 'items' for compat
    items: ((json['transactions'] ?? json['data'] ?? json['items']) as List?)?.map((e) => TransactionItem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    // ignore: avoid_dynamic_calls
    total: json['total'] as int? ?? json['meta']?['total'] as int? ?? 0,
    // ignore: avoid_dynamic_calls
    page: json['page'] as int? ?? json['meta']?['page'] as int? ?? 1,
    // ignore: avoid_dynamic_calls
    limit: json['limit'] as int? ?? json['meta']?['limit'] as int? ?? 20,
    hasMore: json['hasMore'] as bool? ?? false,
  );
}

/// Transaction item model.
class TransactionItem {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String? description;
  final String? counterpartyName;
  final String? counterpartyPhone;
  final DateTime createdAt;

  const TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    this.currency = 'USDC',
    required this.status,
    this.description,
    this.counterpartyName,
    this.counterpartyPhone,
    required this.createdAt,
  });

  /// Whether this transaction is a credit (money in).
  /// Backend types: deposit, transfer_internal (with positive amount)
  bool get isCredit => type == 'deposit' || type == 'received' || (type == 'transfer_internal' && amount > 0);

  /// Whether this transaction is a debit (money out).
  /// Backend types: withdrawal, transfer_internal (with negative amount), transfer_external
  bool get isDebit => type == 'withdrawal' || type == 'sent' || type == 'transfer_external' || (type == 'transfer_internal' && amount < 0);

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
    id: json['id'] as String,
    type: json['type'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'USDC',
    status: json['status'] as String? ?? 'completed',
    description: json['description'] as String?,
    counterpartyName: json['counterpartyName'] as String?,
    counterpartyPhone: json['counterpartyPhone'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
