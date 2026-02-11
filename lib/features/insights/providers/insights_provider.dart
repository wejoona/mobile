import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/expense.dart';
import '../../../services/api/api_client.dart';

/// Spending insights provider.
final spendingInsightsProvider =
    FutureProvider<SpendingInsights>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 10), () => link.close());

  final response = await dio.get('/wallet/transactions/stats');
  return SpendingInsights.fromJson(response.data as Map<String, dynamic>);
});

/// Spending insights model.
class SpendingInsights {
  final double totalSpent;
  final double totalReceived;
  final double netFlow;
  final int transactionCount;
  final List<SpendingSummary> categoryBreakdown;
  final List<DailySpending> dailySpending;

  const SpendingInsights({
    this.totalSpent = 0,
    this.totalReceived = 0,
    this.netFlow = 0,
    this.transactionCount = 0,
    this.categoryBreakdown = const [],
    this.dailySpending = const [],
  });

  factory SpendingInsights.fromJson(Map<String, dynamic> json) {
    return SpendingInsights(
      totalSpent: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0,
      totalReceived: (json['totalDeposited'] as num?)?.toDouble() ?? 0,
      netFlow: (json['netFlow'] as num?)?.toDouble() ?? 0,
      transactionCount: json['totalCount'] as int? ?? 0,
      categoryBreakdown: (json['categories'] as List?)
              ?.map((e) =>
                  SpendingSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Daily spending data point.
class DailySpending {
  final DateTime date;
  final double amount;
  final int count;

  const DailySpending({
    required this.date,
    required this.amount,
    required this.count,
  });

  factory DailySpending.fromJson(Map<String, dynamic> json) {
    return DailySpending(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] as int? ?? 0,
    );
  }
}

/// Time period filter for insights.
enum InsightsPeriod {
  week('This Week', 7),
  month('This Month', 30),
  quarter('This Quarter', 90),
  year('This Year', 365);

  final String label;
  final int days;
  const InsightsPeriod(this.label, this.days);
}

final insightsPeriodProvider =
    StateProvider<InsightsPeriod>((ref) => InsightsPeriod.month);
