import 'package:usdc_wallet/features/payment_links/models/payment_link_status.dart';

class PaymentLink {
  final String id;
  final String shortCode;
  final double amount;
  final String currency;
  final String recipientName;
  final String? description;
  final PaymentLinkStatus status;
  final String url;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewCount;
  final DateTime? paidAt;
  final String? paidByPhone;
  final String? paidByName;
  final String? transactionId;

  const PaymentLink({
    required this.id,
    required this.shortCode,
    required this.amount,
    required this.currency,
    required this.recipientName,
    this.description,
    required this.status,
    required this.url,
    required this.createdAt,
    required this.expiresAt,
    this.viewCount = 0,
    this.paidAt,
    this.paidByPhone,
    this.paidByName,
    this.transactionId,
  });

  factory PaymentLink.fromJson(Map<String, dynamic> json) {
    return PaymentLink(
      id: json['id'] as String,
      shortCode: json['shortCode'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      recipientName: json['recipientName'] as String,
      description: json['description'] as String?,
      status: PaymentLinkStatusExtension.fromJson(json['status'] as String),
      url: json['url'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewCount: json['viewCount'] as int? ?? 0,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
      paidByPhone: json['paidByPhone'] as String?,
      paidByName: json['paidByName'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shortCode': shortCode,
        'amount': amount,
        'currency': currency,
        'recipientName': recipientName,
        'description': description,
        'status': status.toJson(),
        'url': url,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'viewCount': viewCount,
        'paidAt': paidAt?.toIso8601String(),
        'paidByPhone': paidByPhone,
        'paidByName': paidByName,
        'transactionId': transactionId,
      };

  PaymentLink copyWith({
    String? id,
    String? shortCode,
    double? amount,
    String? currency,
    String? recipientName,
    String? description,
    PaymentLinkStatus? status,
    String? url,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    DateTime? paidAt,
    String? paidByPhone,
    String? paidByName,
    String? transactionId,
  }) {
    return PaymentLink(
      id: id ?? this.id,
      shortCode: shortCode ?? this.shortCode,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      recipientName: recipientName ?? this.recipientName,
      description: description ?? this.description,
      status: status ?? this.status,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      paidAt: paidAt ?? this.paidAt,
      paidByPhone: paidByPhone ?? this.paidByPhone,
      paidByName: paidByName ?? this.paidByName,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  bool get isPending => status == PaymentLinkStatus.pending;
  bool get isViewed => status == PaymentLinkStatus.viewed;
  bool get isPaid => status == PaymentLinkStatus.paid;
  bool get isExpired => status == PaymentLinkStatus.expired;
  bool get isCancelled => status == PaymentLinkStatus.cancelled;
  bool get isActive => isPending || isViewed;
}
