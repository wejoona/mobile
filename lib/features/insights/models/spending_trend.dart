/// Spending trend data point for charts
class SpendingTrend {
  final DateTime date;
  final double amount;

  const SpendingTrend({
    required this.date,
    required this.amount,
  });

  factory SpendingTrend.fromJson(Map<String, dynamic> json) {
    return SpendingTrend(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
      };
}
