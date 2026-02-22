import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Spending insights provider — wired to transaction stats API.
final spendingInsightsProvider = FutureProvider<SpendingInsights>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 10), () => link.close());
  ref.onDispose(() => timer.cancel());

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

  const SpendingInsights({this.totalSpent = 0, this.totalReceived = 0, this.netFlow = 0, this.transactionCount = 0, this.categoryBreakdown = const []});

  factory SpendingInsights.fromJson(Map<String, dynamic> json) => SpendingInsights(
    totalSpent: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0,
    totalReceived: (json['totalDeposited'] as num?)?.toDouble() ?? 0,
    netFlow: (json['netFlow'] as num?)?.toDouble() ?? 0,
    transactionCount: json['totalCount'] as int? ?? 0,
    categoryBreakdown: (json['categories'] as List?)?.map((e) => SpendingSummary.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  );
}

/// Time period filter.
enum InsightsPeriod {
  week('This Week', 7),
  month('This Month', 30),
  quarter('This Quarter', 90),
  year('This Year', 365);

  final String label;
  final int days;
  const InsightsPeriod(this.label, this.days);
}

final insightsPeriodProvider = StateProvider<InsightsPeriod>((ref) => InsightsPeriod.month);
