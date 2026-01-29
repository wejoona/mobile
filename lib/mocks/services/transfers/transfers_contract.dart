/// Transfers API Contract
///
/// Defines the interface for transfer endpoints.
/// This serves as the specification for backend implementation.
///
/// IMPORTANT: Both internal and external transfers require PIN verification.
/// The client must first call POST /wallet/pin/verify to get a PIN token,
/// then include it in the X-Pin-Token header for transfer requests.
library;

import '../../base/api_contract.dart';

// ==================== REQUEST/RESPONSE TYPES ====================

/// Internal transfer request (P2P between JoonaPay users)
class InternalTransferRequest {
  final String recipientPhone;
  final double amount;
  final String? note;

  const InternalTransferRequest({
    required this.recipientPhone,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'recipientPhone': recipientPhone,
    'amount': amount,
    if (note != null) 'note': note,
  };
}

/// External transfer request (to blockchain address)
class ExternalTransferRequest {
  final String recipientAddress;
  final double amount;
  final String? blockchain;
  final String? note;

  const ExternalTransferRequest({
    required this.recipientAddress,
    required this.amount,
    this.blockchain,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'recipientAddress': recipientAddress,
    'amount': amount,
    if (blockchain != null) 'blockchain': blockchain,
    if (note != null) 'note': note,
  };
}

/// Transfer response
class TransferResponse {
  final String id;
  final String reference;
  final String type; // 'internal' or 'external'
  final String status; // 'pending', 'completed', 'failed'
  final double amount;
  final double fee;
  final String currency;
  final String? recipientPhone;
  final String? recipientAddress;
  final String? blockchain;
  final String? txHash;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransferResponse({
    required this.id,
    required this.reference,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
    required this.currency,
    this.recipientPhone,
    this.recipientAddress,
    this.blockchain,
    this.txHash,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      id: json['id'] as String,
      reference: json['reference'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      currency: json['currency'] as String,
      recipientPhone: json['recipientPhone'] as String?,
      recipientAddress: json['recipientAddress'] as String?,
      blockchain: json['blockchain'] as String?,
      txHash: json['txHash'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'type': type,
    'status': status,
    'amount': amount,
    'fee': fee,
    'currency': currency,
    if (recipientPhone != null) 'recipientPhone': recipientPhone,
    if (recipientAddress != null) 'recipientAddress': recipientAddress,
    if (blockchain != null) 'blockchain': blockchain,
    if (txHash != null) 'txHash': txHash,
    if (note != null) 'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

/// Paginated transfers list response
class TransfersListResponse {
  final List<TransferResponse> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const TransfersListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory TransfersListResponse.fromJson(Map<String, dynamic> json) {
    return TransfersListResponse(
      items: (json['items'] as List)
          .map((item) => TransferResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'total': total,
    'page': page,
    'pageSize': pageSize,
    'totalPages': totalPages,
  };
}

// ==================== API CONTRACT ====================

class TransfersContract extends ApiContract {
  @override
  String get serviceName => 'transfers';

  @override
  String get basePath => '/transfers';

  @override
  List<ApiEndpoint> get endpoints => [
    ApiEndpoint(
      path: '/internal',
      method: HttpMethod.post,
      description: 'Transfer USDC to another JoonaPay user by phone number',
      requestType: InternalTransferRequest,
      responseType: TransferResponse,
      requiresAuth: true,
    ),
    ApiEndpoint(
      path: '/external',
      method: HttpMethod.post,
      description: 'Send USDC to external blockchain address',
      requestType: ExternalTransferRequest,
      responseType: TransferResponse,
      requiresAuth: true,
    ),
    ApiEndpoint(
      path: '',
      method: HttpMethod.get,
      description: 'Get paginated list of transfers',
      responseType: TransfersListResponse,
      requiresAuth: true,
      queryParams: {
        'page': 'Page number (default: 1)',
        'pageSize': 'Items per page (default: 20)',
        'type': 'Filter by type: internal or external (optional)',
      },
    ),
    ApiEndpoint(
      path: '/:id',
      method: HttpMethod.get,
      description: 'Get transfer details by ID',
      responseType: TransferResponse,
      requiresAuth: true,
      pathParams: {
        'id': 'Transfer ID',
      },
    ),
  ];
}

// ==================== SECURITY NOTES ====================

/// PIN Verification Required
///
/// Both POST /transfers/internal and POST /transfers/external require PIN verification.
///
/// Flow:
/// 1. Client calls POST /wallet/pin/verify with { pinHash: "..." }
/// 2. Server responds with { verified: true, pinToken: "token", expiresIn: 300 }
/// 3. Client includes PIN token in transfer requests:
///    Headers: { "X-Pin-Token": "token" }
/// 4. If header is missing: 400 Bad Request with code "PIN_REQUIRED"
/// 5. If token is invalid/expired: 403 Forbidden with code "PIN_INVALID" or "PIN_EXPIRED"
///
/// The PIN token is valid for 5 minutes and should be used for multiple transfers
/// within that time window (not consumed on first use).
