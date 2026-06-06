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
  final String? failureReason;
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
    this.failureReason,
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
        type == TransactionType.transferExternal ||
        (type == TransactionType.transferInternal && amount < 0);
  }

  bool get isCredit {
    if (direction == 'credit') return true;
    if (direction == 'debit') return false;
    return type == TransactionType.deposit ||
        (type == TransactionType.transferInternal && amount >= 0);
  }

  bool get isPending =>
      status == TransactionStatus.pending ||
      status == TransactionStatus.processing;

  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;

  /// Reference for display - uses externalReference or id
  String get reference => externalReference ?? id;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String? ?? json['transactionId'] as String? ?? '',
      walletId: json['walletId'] as String? ?? '',
      type: _parseTransactionType(json['type'] as String?),
      status: _parseTransactionStatus(json['status'] as String?),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      fee: (json['fee'] as num?)?.toDouble(),
      description: json['description'] as String? ?? json['note'] as String?,
      externalReference:
          json['externalReference'] as String? ??
          json['reference'] as String? ??
          json['supportReference'] as String?,
      failureReason:
          json['failureReason'] as String? ?? json['errorMessage'] as String?,
      recipientPhone:
          json['recipientPhone'] as String? ?? json['toPhone'] as String?,
      recipientAddress: json['recipientAddress'] as String?,
      recipientWalletId: json['recipientWalletId'] as String?,
      direction: (json['direction'] as String?)?.toLowerCase(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  static TransactionType _parseTransactionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'deposit':
      case 'mobile_money_deposit':
        return TransactionType.deposit;
      case 'withdrawal':
      case 'mobile_money_withdrawal':
        return TransactionType.withdrawal;
      case 'transfer_internal':
      case 'internal_transfer_sent':
      case 'internal_transfer_received':
      case 'transfer_in':
      case 'transfer_out':
      case 'internal':
        return TransactionType.transferInternal;
      case 'transfer_external':
      case 'external_transfer':
      case 'external':
        return TransactionType.transferExternal;
      default:
        return TransactionType.deposit;
    }
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
      'type': type.name,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'fee': fee,
      'description': description,
      'externalReference': externalReference,
      'failureReason': failureReason,
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
    final list = (json['transactions'] as List<dynamic>? ?? [])
        .map((e) => Transaction.fromJson(_asStringMap(e)))
        .toList();

    // API returns limit/offset, convert to page/pageSize
    final limit = json['limit'] as int? ?? json['pageSize'] as int? ?? 20;
    final offset = json['offset'] as int? ?? 0;
    final total = json['total'] as int? ?? list.length;
    final page = json['page'] as int? ?? (offset ~/ limit) + 1;

    return TransactionPage(
      transactions: list,
      total: total,
      page: page,
      pageSize: limit,
      hasMore: json['hasMore'] as bool? ?? (offset + list.length < total),
    );
  }
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected transaction JSON object');
}
