/// Transfer entity - mirrors backend Transfer domain entity
///
/// Represents a transfer (internal P2P or external blockchain)
class Transfer {
  final String id;
  final String reference;
  final TransferType type;
  final TransferStatus status;
  final String senderId;
  final String senderWalletId;
  final String? senderPhone;
  final String? recipientId;
  final String? recipientWalletId;
  final String? recipientPhone;
  final String? recipientAddress;
  final String? recipientBlockchain;
  final double amount;
  final double fee;
  final String currency;
  final String? note;
  final String? txHash;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const Transfer({
    required this.id,
    required this.reference,
    required this.type,
    required this.status,
    required this.senderId,
    required this.senderWalletId,
    this.senderPhone,
    this.recipientId,
    this.recipientWalletId,
    this.recipientPhone,
    this.recipientAddress,
    this.recipientBlockchain,
    required this.amount,
    required this.fee,
    required this.currency,
    this.note,
    this.txHash,
    this.errorMessage,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  bool get isInternal => type == TransferType.internal;
  bool get isExternal => type == TransferType.external;
  bool get isPending => status == TransferStatus.pending;
  bool get isProcessing => status == TransferStatus.processing;
  bool get isCompleted => status == TransferStatus.completed;
  bool get isFailed => status == TransferStatus.failed;

  /// Display name for recipient
  String get recipientDisplayName {
    if (recipientPhone != null) return recipientPhone!;
    if (recipientAddress != null) {
      // Shorten address for display
      if (recipientAddress!.length > 12) {
        return '${recipientAddress!.substring(0, 6)}...${recipientAddress!.substring(recipientAddress!.length - 4)}';
      }
      return recipientAddress!;
    }
    return 'Unknown';
  }

  /// Total amount including fee
  double get totalAmount => amount + fee;

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] as String,
      reference: json['reference'] as String,
      type: _parseTransferType(json['type'] as String),
      status: _parseTransferStatus(json['status'] as String),
      senderId: json['senderId'] as String,
      senderWalletId: json['senderWalletId'] as String,
      senderPhone: json['senderPhone'] as String?,
      recipientId: json['recipientId'] as String?,
      recipientWalletId: json['recipientWalletId'] as String?,
      recipientPhone: json['recipientPhone'] as String?,
      recipientAddress: json['recipientAddress'] as String?,
      recipientBlockchain: json['recipientBlockchain'] as String?,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USDC',
      note: json['note'] as String?,
      txHash: json['txHash'] as String?,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'type': type.name,
      'status': status.name,
      'senderId': senderId,
      'senderWalletId': senderWalletId,
      'senderPhone': senderPhone,
      'recipientId': recipientId,
      'recipientWalletId': recipientWalletId,
      'recipientPhone': recipientPhone,
      'recipientAddress': recipientAddress,
      'recipientBlockchain': recipientBlockchain,
      'amount': amount,
      'fee': fee,
      'currency': currency,
      'note': note,
      'txHash': txHash,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  static TransferType _parseTransferType(String type) {
    switch (type.toLowerCase()) {
      case 'internal':
        return TransferType.internal;
      case 'external':
        return TransferType.external;
      default:
        return TransferType.internal;
    }
  }

  static TransferStatus _parseTransferStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransferStatus.pending;
      case 'processing':
        return TransferStatus.processing;
      case 'completed':
        return TransferStatus.completed;
      case 'failed':
        return TransferStatus.failed;
      case 'cancelled':
        return TransferStatus.cancelled;
      default:
        return TransferStatus.pending;
    }
  }
}

/// Transfer type enum
enum TransferType {
  internal, // P2P between users
  external, // To blockchain address
}

/// Transfer status enum
enum TransferStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}
