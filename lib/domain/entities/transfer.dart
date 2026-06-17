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
    final id = _stringValue(json, const ['id', 'transferId', 'transactionId']);
    return Transfer(
      id: id ?? '',
      reference:
          _stringValue(json, const ['reference', 'supportReference']) ??
          id ??
          '',
      type: _parseTransferType(_stringValue(json, const ['type'])),
      status: _parseTransferStatus(_stringValue(json, const ['status'])),
      senderId: _stringValue(json, const ['senderId', 'fromUserId']) ?? '',
      senderWalletId:
          _stringValue(json, const ['senderWalletId', 'fromWalletId']) ?? '',
      senderPhone: _stringValue(json, const ['senderPhone', 'fromPhone']),
      recipientId: _stringValue(json, const ['recipientId', 'toUserId']),
      recipientWalletId: _stringValue(json, const [
        'recipientWalletId',
        'toWalletId',
      ]),
      recipientPhone: _stringValue(json, const ['recipientPhone', 'toPhone']),
      recipientAddress: _stringValue(json, const ['recipientAddress']),
      recipientBlockchain: _stringValue(json, const [
        'recipientBlockchain',
        'network',
      ]),
      amount: _numValue(json, const ['amount', 'amountDecimal']) ?? 0,
      fee: _numValue(json, const ['fee', 'feeDecimal']) ?? 0,
      currency: _stringValue(json, const ['currency']) ?? 'USDC',
      note: _stringValue(json, const ['note', 'description']),
      txHash: _stringValue(json, const ['txHash', 'transactionHash']),
      errorMessage: _stringValue(json, const ['errorMessage', 'failureReason']),
      createdAt:
          _dateValue(json, const ['createdAt', 'created_at', 'timestamp']) ??
          DateTime.now(),
      updatedAt: _dateValue(json, const ['updatedAt', 'updated_at']),
      completedAt: _dateValue(json, const ['completedAt', 'completed_at']),
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

  static TransferType _parseTransferType(String? type) {
    switch (type?.toLowerCase()) {
      case 'internal':
      case 'transfer_internal':
      case 'internal_transfer':
      case 'internal_transfer_sent':
      case 'internal_transfer_received':
      case 'transfer_in':
      case 'transfer_out':
        return TransferType.internal;
      case 'external':
      case 'transfer_external':
      case 'external_transfer':
        return TransferType.external;
      default:
        return TransferType.internal;
    }
  }

  static TransferStatus _parseTransferStatus(String? status) {
    switch (status?.toLowerCase()) {
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

DateTime? _dateValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  }
  return null;
}

/// Transfer type enum
enum TransferType {
  internal, // P2P between users
  external, // To blockchain address
}

/// Transfer status enum
enum TransferStatus { pending, processing, completed, failed, cancelled }
