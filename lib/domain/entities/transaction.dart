import '../enums/index.dart';

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
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  bool get isDebit =>
      type == TransactionType.withdrawal ||
      type == TransactionType.transferExternal;

  bool get isCredit =>
      type == TransactionType.deposit ||
      type == TransactionType.transferInternal;

  bool get isPending =>
      status == TransactionStatus.pending ||
      status == TransactionStatus.processing;

  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;

  /// Reference for display - uses externalReference or id
  String get reference => externalReference ?? id;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      walletId: json['walletId'] as String? ?? '',
      type: _parseTransactionType(json['type'] as String),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      fee: (json['fee'] as num?)?.toDouble(),
      description: json['description'] as String?,
      externalReference: json['externalReference'] as String?,
      failureReason: json['failureReason'] as String?,
      recipientPhone: json['recipientPhone'] as String?,
      recipientAddress: json['recipientAddress'] as String?,
      recipientWalletId: json['recipientWalletId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  static TransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'transfer_internal':
        return TransactionType.transferInternal;
      case 'transfer_external':
        return TransactionType.transferExternal;
      default:
        return TransactionType.deposit;
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
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
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
