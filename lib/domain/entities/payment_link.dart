/// Payment link entity - mirrors backend PaymentLink domain entity.
class PaymentLink {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String? description;
  final String? recipientName;
  final PaymentLinkStatus status;
  final String shortCode;
  final String url;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? payerPhone;
  final Map<String, dynamic>? metadata;

  const PaymentLink({
    required this.id,
    required this.userId,
    required this.amount,
    this.currency = 'USDC',
    this.description,
    this.recipientName,
    required this.status,
    required this.shortCode,
    required this.url,
    this.expiresAt,
    required this.createdAt,
    this.paidAt,
    this.payerPhone,
    this.metadata,
  });

  bool get isActive => status == PaymentLinkStatus.active;
  bool get isPaid => status == PaymentLinkStatus.paid;
  bool get isExpired =>
      status == PaymentLinkStatus.expired ||
      (expiresAt != null && DateTime.now().isAfter(expiresAt!));

  factory PaymentLink.fromJson(Map<String, dynamic> json) {
    return PaymentLink(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USDC',
      description: json['description'] as String?,
      recipientName: json['recipientName'] as String?,
      status: PaymentLinkStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentLinkStatus.active,
      ),
      shortCode: json['shortCode'] as String? ?? '',
      url: json['url'] as String? ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      payerPhone: json['payerPhone'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'currency': currency,
        'description': description,
        'recipientName': recipientName,
        'status': status.name,
        'shortCode': shortCode,
        'url': url,
        'expiresAt': expiresAt?.toIso8601String(),
      };
}

enum PaymentLinkStatus { active, paid, expired, cancelled }
