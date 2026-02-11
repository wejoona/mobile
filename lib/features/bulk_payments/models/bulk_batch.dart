import 'package:usdc_wallet/features/bulk_payments/models/bulk_payment.dart';

enum BatchStatus {
  draft,
  pending,
  processing,
  completed,
  partiallyCompleted,
  failed,
}

class BulkBatch {
  final String id;
  final String name;
  final List<BulkPayment> payments;
  final BatchStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final int totalCount;
  final int successCount;
  final int failedCount;
  final double totalAmount;

  const BulkBatch({
    required this.id,
    required this.name,
    required this.payments,
    required this.status,
    required this.createdAt,
    this.processedAt,
    required this.totalCount,
    required this.successCount,
    required this.failedCount,
    required this.totalAmount,
  });

  factory BulkBatch.fromPayments({
    required String id,
    required String name,
    required List<BulkPayment> payments,
  }) {
    final validPayments = payments.where((p) => p.isValid).toList();
    final totalAmount = validPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    return BulkBatch(
      id: id,
      name: name,
      payments: payments,
      status: BatchStatus.draft,
      createdAt: DateTime.now(),
      totalCount: validPayments.length,
      successCount: 0,
      failedCount: 0,
      totalAmount: totalAmount,
    );
  }

  factory BulkBatch.fromJson(Map<String, dynamic> json) {
    return BulkBatch(
      id: json['id'] as String,
      name: json['name'] as String,
      payments: (json['payments'] as List)
          .map((p) => BulkPayment(
                phone: p['phone'] as String,
                amount: (p['amount'] as num).toDouble(),
                description: p['description'] as String,
                isValid: p['isValid'] as bool? ?? true,
                error: p['error'] as String?,
              ))
          .toList(),
      status: BatchStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BatchStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      totalCount: json['totalCount'] as int,
      successCount: json['successCount'] as int,
      failedCount: json['failedCount'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'payments': payments.map((p) => p.toJson()).toList(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'processedAt': processedAt?.toIso8601String(),
        'totalCount': totalCount,
        'successCount': successCount,
        'failedCount': failedCount,
        'totalAmount': totalAmount,
      };

  List<BulkPayment> get validPayments =>
      payments.where((p) => p.isValid).toList();

  List<BulkPayment> get invalidPayments =>
      payments.where((p) => !p.isValid).toList();

  bool get hasErrors => invalidPayments.isNotEmpty;

  int get errorCount => invalidPayments.length;

  BulkBatch copyWith({
    String? id,
    String? name,
    List<BulkPayment>? payments,
    BatchStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
    int? totalCount,
    int? successCount,
    int? failedCount,
    double? totalAmount,
  }) {
    return BulkBatch(
      id: id ?? this.id,
      name: name ?? this.name,
      payments: payments ?? this.payments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      totalCount: totalCount ?? this.totalCount,
      successCount: successCount ?? this.successCount,
      failedCount: failedCount ?? this.failedCount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
