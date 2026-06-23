import 'package:usdc_wallet/domain/enums/index.dart';

/// Transaction entity - mirrors backend Transaction domain entity
class Transaction {
  final String id;
  final String walletId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final String currency;
  final double? fee;
  final String? description;
  final String? externalReference;
  final String? supportReference;
  final String? ledgerReference;
  final String? providerReference;
  final String? failureReason;
  final String? counterpartyName;
  final String? counterpartyPhone;
  final String? recipientPhone;
  final String? recipientAddress;
  final String? recipientWalletId;
  final String? direction;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Transaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    this.fee,
    this.description,
    this.externalReference,
    this.supportReference,
    this.ledgerReference,
    this.providerReference,
    this.failureReason,
    this.counterpartyName,
    this.counterpartyPhone,
    this.recipientPhone,
    this.recipientAddress,
    this.recipientWalletId,
    this.direction,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  bool get isDebit {
    if (direction == 'debit') return true;
    if (direction == 'credit') return false;
    return type == TransactionType.withdrawal ||
        type == TransactionType.billPayment ||
        type == TransactionType.transferExternal ||
        (type == TransactionType.transferInternal && amount < 0) ||
        (type == TransactionType.unknown && amount < 0);
  }

  bool get isCredit {
    if (direction == 'credit') return true;
    if (direction == 'debit') return false;
    return type == TransactionType.deposit ||
        (type == TransactionType.transferInternal && amount >= 0);
  }

  String get amountSign {
    if (isCredit) return '+';
    if (isDebit) return '-';
    return '';
  }

  bool get isPending =>
      status == TransactionStatus.pending ||
      status == TransactionStatus.processing;

  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;

  /// Best transaction reference for customer-facing display and receipts.
  String get reference =>
      externalReference ??
      providerReference ??
      ledgerReference ??
      supportReference ??
      id;

  String? get displayCounterpartyName => counterpartyName;
  String? get displayCounterpartyPhone => counterpartyPhone ?? recipientPhone;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final counterpartyPhone = _stringValue(json, const [
      'counterpartyPhone',
      'recipientPhone',
      'senderPhone',
      'toPhone',
      'fromPhone',
    ]);

    return Transaction(
      id: json['id'] as String? ?? json['transactionId'] as String? ?? '',
      walletId: _stringValue(json, const ['walletId', 'wallet_id']) ?? '',
      type: parseTransactionType(_stringValue(json, const ['type', 'kind'])),
      status: _parseTransactionStatus(json['status'] as String?),
      amount:
          _numValue(json, const [
            'amountDecimal',
            'amount_decimal',
            'amount',
            'amountUsd',
            'amount_usd',
          ]) ??
          0,
      currency: json['currency'] as String? ?? 'USD',
      fee: _numValue(json, const ['feeDecimal', 'fee_decimal', 'fee']),
      description: json['description'] as String? ?? json['note'] as String?,
      externalReference:
          json['externalReference'] as String? ??
          json['reference'] as String? ??
          json['providerReference'] as String? ??
          json['ledgerReference'] as String?,
      supportReference: json['supportReference'] as String?,
      ledgerReference: json['ledgerReference'] as String?,
      providerReference:
          json['providerReference'] as String? ??
          json['yellowCardRef'] as String?,
      failureReason:
          json['failureReason'] as String? ?? json['errorMessage'] as String?,
      counterpartyName: _stringValue(json, const [
        'counterpartyName',
        'recipientName',
        'senderName',
      ]),
      counterpartyPhone: counterpartyPhone,
      recipientPhone:
          _stringValue(json, const ['recipientPhone', 'toPhone']) ??
          counterpartyPhone,
      recipientAddress: json['recipientAddress'] as String?,
      recipientWalletId: json['recipientWalletId'] as String?,
      direction: (json['direction'] as String?)?.toLowerCase(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt:
          _dateValue(json, const ['createdAt', 'created_at', 'timestamp']) ??
          DateTime.now(),
      completedAt: _dateValue(json, const ['completedAt', 'completed_at']),
    );
  }

  static TransactionStatus _parseTransactionStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'initiated':
        return TransactionStatus.pending;
      case 'processing':
      case 'in_progress':
        return TransactionStatus.processing;
      case 'completed':
      case 'complete':
      case 'success':
      case 'succeeded':
      case 'settled':
        return TransactionStatus.completed;
      case 'failed':
      case 'failure':
      case 'error':
      case 'timeout':
      case 'expired':
        return TransactionStatus.failed;
      case 'cancelled':
      case 'canceled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'type': type.wireName,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'fee': fee,
      'description': description,
      'externalReference': externalReference,
      'supportReference': supportReference,
      'ledgerReference': ledgerReference,
      'providerReference': providerReference,
      'failureReason': failureReason,
      'counterpartyName': counterpartyName,
      'counterpartyPhone': counterpartyPhone,
      'recipientPhone': recipientPhone,
      'direction': direction,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

/// Paginated transaction response
class TransactionPage {
  final List<Transaction> transactions;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const TransactionPage({
    required this.transactions,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory TransactionPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;
    final rawList =
        json['transactions'] ??
        json['items'] ??
        dataMap?['transactions'] ??
        dataMap?['items'] ??
        (data is List ? data : null);
    final list = (rawList as List<dynamic>? ?? [])
        .map((e) => Transaction.fromJson(_asStringMap(e)))
        .toList();

    // API returns limit/offset, convert to page/pageSize
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : dataMap?['meta'] is Map
        ? Map<String, dynamic>.from(dataMap?['meta'] as Map)
        : null;
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
        list.length;
    final page =
        _intValue(json, const ['page']) ??
        _intValue(meta, const ['page']) ??
        (offset ~/ limit) + 1;

    return TransactionPage(
      transactions: list,
      total: total,
      page: page,
      pageSize: limit,
      hasMore:
          _boolValue(json, const ['hasMore', 'has_more']) ??
          _boolValue(meta, const ['hasMore', 'has_more']) ??
          (offset + list.length < total),
    );
  }
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected transaction JSON object');
}

String? _stringValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
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
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
  }
  return null;
}

DateTime? _dateValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  }
  return null;
}
