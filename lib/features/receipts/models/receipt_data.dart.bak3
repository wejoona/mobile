import '../../../domain/entities/transaction.dart';
import '../../../domain/enums/index.dart';

/// Receipt data extracted from a transaction
class ReceiptData {
  final String transactionId;
  final String referenceNumber;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double fee;
  final double total;
  final String currency;
  final DateTime date;
  final String? recipientName;
  final String? recipientPhone;
  final String? recipientAddress;
  final String? description;
  final Map<String, dynamic>? metadata;

  const ReceiptData({
    required this.transactionId,
    required this.referenceNumber,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
    required this.total,
    required this.currency,
    required this.date,
    this.recipientName,
    this.recipientPhone,
    this.recipientAddress,
    this.description,
    this.metadata,
  });

  /// Create receipt data from a transaction
  factory ReceiptData.fromTransaction(Transaction transaction) {
    final fee = transaction.fee ?? 0.0;
    final amount = transaction.amount.abs();
    final total = amount + fee;

    return ReceiptData(
      transactionId: transaction.id,
      referenceNumber: transaction.reference,
      type: transaction.type,
      status: transaction.status,
      amount: amount,
      fee: fee,
      total: total,
      currency: transaction.currency,
      date: transaction.completedAt ?? transaction.createdAt,
      recipientPhone: transaction.recipientPhone,
      recipientAddress: transaction.recipientAddress,
      description: transaction.description,
      metadata: transaction.metadata,
    );
  }

  /// Get a display-friendly transaction type label
  String getTypeLabel() {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.transferInternal:
        return 'Transfer Received';
      case TransactionType.transferExternal:
        return 'Transfer Sent';
    }
  }

  /// Get a display-friendly status label
  String getStatusLabel() {
    switch (status) {
      case TransactionStatus.completed:
        return 'Successful';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Check if transaction was successful
  bool get isSuccessful => status == TransactionStatus.completed;

  /// Get truncated transaction ID for display
  String get truncatedId {
    if (transactionId.length <= 12) return transactionId;
    return '${transactionId.substring(0, 6)}...${transactionId.substring(transactionId.length - 6)}';
  }
}
