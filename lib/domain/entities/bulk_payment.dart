/// Bulk payment entity - batch payments to multiple recipients.
class BulkPayment {
  final String id;
  final String userId;
  final String name;
  final BulkPaymentStatus status;
  final List<BulkPaymentItem> items;
  final double totalAmount;
  final String currency;
  final int successCount;
  final int failureCount;
  final DateTime createdAt;
  final DateTime? completedAt;

  const BulkPayment({
    required this.id,
    required this.userId,
    required this.name,
    required this.status,
    required this.items,
    required this.totalAmount,
    this.currency = 'USDC',
    this.successCount = 0,
    this.failureCount = 0,
    required this.createdAt,
    this.completedAt,
  });

  int get totalItems => items.length;
  int get pendingCount => totalItems - successCount - failureCount;
  double get progress =>
      totalItems > 0 ? (successCount + failureCount) / totalItems : 0;
  bool get isComplete => status == BulkPaymentStatus.completed;

  factory BulkPayment.fromJson(Map<String, dynamic> json) {
    return BulkPayment(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? 'Bulk Payment',
      status: BulkPaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BulkPaymentStatus.pending,
      ),
      items: (json['items'] as List?)
              ?.map((e) =>
                  BulkPaymentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USDC',
      successCount: json['successCount'] as int? ?? 0,
      failureCount: json['failureCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

class BulkPaymentItem {
  final String recipientPhone;
  final String? recipientName;
  final double amount;
  final String? note;
  final BulkItemStatus status;
  final String? failureReason;

  const BulkPaymentItem({
    required this.recipientPhone,
    this.recipientName,
    required this.amount,
    this.note,
    this.status = BulkItemStatus.pending,
    this.failureReason,
  });

  factory BulkPaymentItem.fromJson(Map<String, dynamic> json) {
    return BulkPaymentItem(
      recipientPhone: json['recipientPhone'] as String,
      recipientName: json['recipientName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      status: BulkItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BulkItemStatus.pending,
      ),
      failureReason: json['failureReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'recipientPhone': recipientPhone,
        'recipientName': recipientName,
        'amount': amount,
        'note': note,
      };
}

enum BulkPaymentStatus { pending, processing, completed, failed }

enum BulkItemStatus { pending, success, failed }
