/// Virtual Card Models
library;

/// Virtual Card Status
enum CardStatus {
  active,
  frozen,
  blocked,
  expired,
}

/// Virtual Card Model
class VirtualCard {
  final String id;
  final String userId;
  final String cardNumber;
  final String cvv;
  final String expiryMonth;
  final String expiryYear;
  final String cardholderName;
  final CardStatus status;
  final double spendingLimit;
  final double spentAmount;
  final String currency;
  final DateTime createdAt;
  final DateTime? frozenAt;

  const VirtualCard({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.cvv,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    required this.status,
    required this.spendingLimit,
    required this.spentAmount,
    required this.currency,
    required this.createdAt,
    this.frozenAt,
  });

  factory VirtualCard.fromJson(Map<String, dynamic> json) {
    return VirtualCard(
      id: json['id'] as String,
      userId: json['userId'] as String,
      cardNumber: json['cardNumber'] as String,
      cvv: json['cvv'] as String,
      expiryMonth: json['expiryMonth'] as String,
      expiryYear: json['expiryYear'] as String,
      cardholderName: json['cardholderName'] as String,
      status: CardStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CardStatus.active,
      ),
      spendingLimit: (json['spendingLimit'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      frozenAt: json['frozenAt'] != null
          ? DateTime.parse(json['frozenAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'cardNumber': cardNumber,
        'cvv': cvv,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cardholderName': cardholderName,
        'status': status.name,
        'spendingLimit': spendingLimit,
        'spentAmount': spentAmount,
        'currency': currency,
        'createdAt': createdAt.toIso8601String(),
        'frozenAt': frozenAt?.toIso8601String(),
      };

  String get maskedNumber {
    if (cardNumber.length < 4) return cardNumber;
    final last4 = cardNumber.substring(cardNumber.length - 4);
    return '**** **** **** $last4';
  }

  String get expiry => '$expiryMonth/$expiryYear';

  bool get isActive => status == CardStatus.active;
  bool get isFrozen => status == CardStatus.frozen;
  bool get isBlocked => status == CardStatus.blocked;
  bool get isExpired => status == CardStatus.expired;

  double get availableLimit => spendingLimit - spentAmount;

  VirtualCard copyWith({
    String? id,
    String? userId,
    String? cardNumber,
    String? cvv,
    String? expiryMonth,
    String? expiryYear,
    String? cardholderName,
    CardStatus? status,
    double? spendingLimit,
    double? spentAmount,
    String? currency,
    DateTime? createdAt,
    DateTime? frozenAt,
  }) {
    return VirtualCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardNumber: cardNumber ?? this.cardNumber,
      cvv: cvv ?? this.cvv,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardholderName: cardholderName ?? this.cardholderName,
      status: status ?? this.status,
      spendingLimit: spendingLimit ?? this.spendingLimit,
      spentAmount: spentAmount ?? this.spentAmount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      frozenAt: frozenAt ?? this.frozenAt,
    );
  }
}

/// Card Transaction Model
class CardTransaction {
  final String id;
  final String cardId;
  final String merchantName;
  final String merchantCategory;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;

  const CardTransaction({
    required this.id,
    required this.cardId,
    required this.merchantName,
    required this.merchantCategory,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory CardTransaction.fromJson(Map<String, dynamic> json) {
    return CardTransaction(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      merchantName: json['merchantName'] as String,
      merchantCategory: json['merchantCategory'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardId': cardId,
        'merchantName': merchantName,
        'merchantCategory': merchantCategory,
        'amount': amount,
        'currency': currency,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };
}
