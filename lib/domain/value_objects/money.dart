/// Value object representing a monetary amount.
class Money {
  final double amount;
  final String currency;

  const Money({
    required this.amount,
    this.currency = 'USDC',
  });

  const Money.zero({this.currency = 'USDC'}) : amount = 0;

  Money operator +(Money other) {
    assert(currency == other.currency, 'Cannot add different currencies');
    return Money(amount: amount + other.amount, currency: currency);
  }

  Money operator -(Money other) {
    assert(currency == other.currency, 'Cannot subtract different currencies');
    return Money(amount: amount - other.amount, currency: currency);
  }

  Money operator *(double factor) {
    return Money(amount: amount * factor, currency: currency);
  }

  bool get isZero => amount == 0;
  bool get isPositive => amount > 0;
  bool get isNegative => amount < 0;

  /// Format for display (e.g. "100.00 USDC").
  String get display => '${amount.toStringAsFixed(2)} $currency';

  @override
  bool operator ==(Object other) =>
      other is Money && other.amount == amount && other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => display;
}
