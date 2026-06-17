import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/domain/entities/transaction_filter.dart';

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
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 1), () => link.close());
  ref.onDispose(() => timer.cancel());

  final response = await dio.get(
    ApiEndpoints.walletTransactions,
    queryParameters: {...filter.toQueryParams(), 'limit': 20, 'offset': 0},
  );
  return TransactionPage.fromJson(_asStringMap(response.data));
});

/// Transaction page model.
class TransactionPage {
  final List<TransactionItem> items;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const TransactionPage({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.hasMore = false,
  });

  factory TransactionPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : dataMap?['meta'] is Map
        ? Map<String, dynamic>.from(dataMap?['meta'] as Map)
        : null;
    final rawItems =
        json['transactions'] ??
        json['items'] ??
        dataMap?['transactions'] ??
        dataMap?['items'] ??
        (data is List ? data : null);
    final items = (rawItems as List<dynamic>? ?? [])
        .map((e) => TransactionItem.fromJson(_asStringMap(e)))
        .toList();
    final limit =
        _intValue(json, const ['limit', 'pageSize', 'page_size']) ??
        _intValue(meta, const ['limit', 'pageSize', 'page_size']) ??
        20;
    final offset =
        _intValue(json, const ['offset']) ??
        _intValue(meta, const ['offset']) ??
        0;
    final total =
        _intValue(json, const ['total', 'count']) ??
        _intValue(meta, const ['total', 'count']) ??
        items.length;
    final page =
        _intValue(json, const ['page']) ??
        _intValue(meta, const ['page']) ??
        (offset ~/ limit) + 1;

    return TransactionPage(
      items: items,
      total: total,
      page: page,
      limit: limit,
      hasMore:
          _boolValue(json, const ['hasMore', 'has_more']) ??
          _boolValue(meta, const ['hasMore', 'has_more']) ??
          (offset + items.length < total),
    );
  }
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
  final String? direction;
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
    this.direction,
    required this.createdAt,
  });

  /// Whether this transaction is a credit (money in).
  bool get isCredit {
    if (direction == 'credit') return true;
    if (direction == 'debit') return false;
    return type == 'deposit' ||
        type == 'mobile_money_deposit' ||
        type == 'received' ||
        type == 'transfer_in' ||
        type == 'internal_transfer_received' ||
        (type == 'transfer_internal' && amount > 0);
  }

  /// Whether this transaction is a debit (money out).
  bool get isDebit {
    if (direction == 'debit') return true;
    if (direction == 'credit') return false;
    return type == 'withdrawal' ||
        type == 'mobile_money_withdrawal' ||
        type == 'sent' ||
        type == 'transfer_out' ||
        type == 'internal_transfer_sent' ||
        type == 'transfer_external' ||
        type == 'external_transfer' ||
        (type == 'transfer_internal' && amount < 0);
  }

  factory TransactionItem.fromJson(
    Map<String, dynamic> json,
  ) => TransactionItem(
    id: json['id'] as String? ?? json['transactionId'] as String? ?? '',
    type: (json['type'] as String? ?? 'deposit').toLowerCase(),
    amount:
        _numValue(json, const ['amountDecimal', 'amount_decimal', 'amount']) ??
        0,
    currency: json['currency'] as String? ?? 'USDC',
    status: _normalizeTransactionStatus(json['status'] as String?),
    description: json['description'] as String? ?? json['note'] as String?,
    counterpartyName:
        json['counterpartyName'] as String? ?? json['recipientName'] as String?,
    counterpartyPhone:
        json['counterpartyPhone'] as String? ??
        json['recipientPhone'] as String? ??
        json['toPhone'] as String?,
    direction: (json['direction'] as String?)?.toLowerCase(),
    createdAt:
        _dateValue(json, const ['createdAt', 'created_at', 'timestamp']) ??
        DateTime.now(),
  );
}

String _normalizeTransactionStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
    case 'initiated':
      return 'pending';
    case 'processing':
    case 'in_progress':
      return 'processing';
    case 'completed':
    case 'complete':
    case 'success':
    case 'succeeded':
    case 'settled':
      return 'completed';
    case 'failed':
    case 'failure':
    case 'error':
    case 'timeout':
    case 'expired':
      return 'failed';
    case 'cancelled':
    case 'canceled':
      return 'cancelled';
    default:
      return 'pending';
  }
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected JSON object');
}

double? _numValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
  }
  return null;
}

int? _intValue(Map<String, dynamic>? map, List<String> keys) {
  if (map == null) return null;
  for (final key in keys) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
  }
  return null;
}

bool? _boolValue(Map<String, dynamic>? map, List<String> keys) {
  if (map == null) return null;
  for (final key in keys) {
    final value = map[key];
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value);
  }
  return null;
}

DateTime? _dateValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}
