/// Value object for monetary amounts — ensures type safety and formatting.
class Money {
  final double amount;
  final String currency;

  const Money({required this.amount, this.currency = 'USDC'});

  /// Zero amount.
  static const zero = Money(amount: 0);

  /// Format: "100.00 USDC".
  String get formatted => '${amount.toStringAsFixed(2)} $currency';

  /// Format: "$100.00" or "100.00 USDC".
  String get display {
    if (currency == 'USD' || currency == 'USDC') {
      return '\$${amount.toStringAsFixed(2)}';
    }
    return formatted;
  }

  /// Compact: "1.2K", "500", etc.
  String get compact {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $currency';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $currency';
    }
    return formatted;
  }

  /// Whether amount is positive.
  bool get isPositive => amount > 0;

  /// Whether amount is zero.
  bool get isZero => amount == 0;

  /// Add two Money values (must be same currency).
  Money operator +(Money other) {
    assert(currency == other.currency, 'Cannot add different currencies');
    return Money(amount: amount + other.amount, currency: currency);
  }

  /// Subtract.
  Money operator -(Money other) {
    assert(currency == other.currency, 'Cannot subtract different currencies');
    return Money(amount: amount - other.amount, currency: currency);
  }

  /// Multiply by a scalar.
  Money operator *(double factor) {
    return Money(amount: amount * factor, currency: currency);
  }

  @override
  bool operator ==(Object other) =>
      other is Money && amount == other.amount && currency == other.currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => formatted;

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USDC',
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
      };
}
