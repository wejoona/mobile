import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';

/// Transaction list filter.
class TransactionFilter {
  final String? type; // all, sent, received, deposit, withdrawal
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int limit;

  const TransactionFilter({this.type, this.from, this.to, this.page = 1, this.limit = 20});

  TransactionFilter copyWith({String? type, DateTime? from, DateTime? to, int? page, int? limit}) => TransactionFilter(
    type: type ?? this.type,
    from: from ?? this.from,
    to: to ?? this.to,
    page: page ?? this.page,
    limit: limit ?? this.limit,
  );

  Map<String, dynamic> toQuery() => {
    if (type != null && type != 'all') 'type': type,
    if (from != null) 'from': from!.toIso8601String(),
    if (to != null) 'to': to!.toIso8601String(),
    'page': page,
    'limit': limit,
  };
}

/// Transaction filter state.
final transactionFilterProvider = StateProvider<TransactionFilter>((ref) => const TransactionFilter());

/// Paginated transactions provider — wired to GET /wallet/transactions.
final transactionsProvider = FutureProvider<TransactionPage>((ref) async {
  final filter = ref.watch(transactionFilterProvider);
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 1), () => link.close());

  final response = await dio.get('/wallet/transactions', queryParameters: filter.toQuery());
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
    items: ((json['data'] ?? json['items']) as List?)?.map((e) => TransactionItem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    total: json['total'] as int? ?? json['meta']?['total'] as int? ?? 0,
    page: json['page'] as int? ?? json['meta']?['page'] as int? ?? 1,
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

  bool get isCredit => type == 'deposit' || type == 'received';
  bool get isDebit => type == 'withdrawal' || type == 'sent';

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
