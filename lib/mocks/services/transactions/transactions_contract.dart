/// Transactions API Contract
///
/// Defines the interface for transaction endpoints.
library;

import 'package:usdc_wallet/mocks/base/api_contract.dart';

// ==================== REQUEST/RESPONSE TYPES ====================

/// Transaction type enum
enum TransactionType { deposit, withdrawal, transferIn, transferOut }

/// Transaction status enum
enum TransactionStatus { pending, processing, completed, failed, cancelled }

/// Transaction response
class TransactionResponse {
  final String id;
  final String userId;
  final String type;
  final String status;
  final double amount;
  final double? fee;
  final String currency;
  final String? recipient;
  final String? sender;
  final String? note;
  final String? reference;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TransactionResponse({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    this.fee,
    required this.currency,
    this.recipient,
    this.sender,
    this.note,
    this.reference,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type,
    'status': status,
    'amount': amount,
    'fee': fee,
    'currency': currency,
    'recipient': recipient,
    'sender': sender,
    'note': note,
    'reference': reference,
    'metadata': metadata,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };
}

/// Transaction list response
class TransactionListResponse {
  final List<TransactionResponse> transactions;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const TransactionListResponse({
    required this.transactions,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  Map<String, dynamic> toJson() => {
    'transactions': transactions.map((t) => t.toJson()).toList(),
    'total': total,
    'page': page,
    'limit': limit,
    'hasMore': hasMore,
  };
}

/// Transfer request
class TransferRequest {
  final String recipientPhone;
  final double amount;
  final String? note;

  const TransferRequest({
    required this.recipientPhone,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'recipientPhone': recipientPhone,
    'amount': amount,
    'note': note,
  };
}

/// External transfer request
class ExternalTransferRequest {
  final String walletAddress;
  final double amount;
  final String network;
  final String? note;

  const ExternalTransferRequest({
    required this.walletAddress,
    required this.amount,
    required this.network,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'walletAddress': walletAddress,
    'amount': amount,
    'network': network,
    'note': note,
  };
}

// ==================== CONTRACT ====================

/// Transactions API Contract
class TransactionsContract extends ApiContract {
  @override
  String get serviceName => 'Transactions';

  @override
  String get basePath => '/wallet/transactions';

  static const getTransactions = ApiEndpoint(
    path: '',
    method: HttpMethod.get,
    description: 'Get transaction history',
    queryParams: {
      'page': 'Page number (default: 1)',
      'limit': 'Items per page (default: 20)',
      'type': 'Filter by type (deposit, withdrawal, transfer_in, transfer_out)',
      'status': 'Filter by status',
      'startDate': 'Filter from date (ISO 8601)',
      'endDate': 'Filter to date (ISO 8601)',
    },
    responseType: TransactionListResponse,
    requiresAuth: true,
  );

  static const getTransaction = ApiEndpoint(
    path: '/:id',
    method: HttpMethod.get,
    description: 'Get transaction by ID',
    pathParams: {'id': 'Transaction ID'},
    responseType: TransactionResponse,
    requiresAuth: true,
  );

  static const transfer = ApiEndpoint(
    path: '/transfer',
    method: HttpMethod.post,
    description: 'Transfer to another JoonaPay user',
    requestType: TransferRequest,
    responseType: TransactionResponse,
    requiresAuth: true,
  );

  static const externalTransfer = ApiEndpoint(
    path: '/transfer/external',
    method: HttpMethod.post,
    description: 'Transfer to external wallet',
    requestType: ExternalTransferRequest,
    responseType: TransactionResponse,
    requiresAuth: true,
  );

  static const exportTransactions = ApiEndpoint(
    path: '/export',
    method: HttpMethod.get,
    description: 'Export transactions as CSV/PDF',
    queryParams: {
      'format': 'Export format (csv, pdf)',
      'startDate': 'Start date',
      'endDate': 'End date',
    },
    requiresAuth: true,
  );

  @override
  List<ApiEndpoint> get endpoints => [
    getTransactions,
    getTransaction,
    transfer,
    externalTransfer,
    exportTransactions,
  ];
}
