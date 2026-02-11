/// Stub providers for views that reference providers not yet created.
/// These are temporary — wire to real implementations as features complete.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/entities/transaction_filter.dart';

/// Filtered+paginated transactions (used by transactions_view.dart)
final filteredPaginatedTransactionsProvider =
    FutureProvider.autoDispose<List<Transaction>>((ref) async {
  return [];
});

/// Exchange rate provider
final exchangeRateProvider = FutureProvider.autoDispose<double>((ref) async {
  return 655.957; // USDC → XOF default rate
});

/// Spending trend provider (insights)
final spendingTrendProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return [];
});

/// Selected period for insights
final selectedPeriodProvider = Provider<String>((ref) => "month");

/// Spending by category provider
final spendingByCategoryProvider =
    FutureProvider.autoDispose<Map<String, double>>((ref) async {
  return {};
});

/// Spending summary provider
final spendingSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return {'total': 0.0, 'average': 0.0, 'count': 0};
});

/// Top recipients provider
final topRecipientsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return [];
});

/// Notifications notifier provider
final notificationsNotifierProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return [];
});

/// Profile notifier provider
final profileNotifierProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return {};
});

/// Providers list (debug)
final providersListProvider =
    Provider<List<String>>((ref) => []);

/// Analytics service provider
final analyticsServiceProvider = Provider<dynamic>((ref) => null);
