import 'package:usdc_wallet/features/transactions/models/filtered_transactions_state.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/features/insights/models/top_recipient.dart';
/// TECH DEBT: Stub providers — wire to real implementations as features complete.
///
/// Each provider here is a placeholder. When implementing the real feature:
/// 1. Create the real provider in the feature's providers/ directory
/// 2. Update imports in consuming views
/// 3. Remove the stub from this file
///
/// Remaining stubs: 10 (as of 2026-02-14)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';
import 'package:usdc_wallet/features/cards/models/cards_state.dart';
import 'package:usdc_wallet/features/settings/models/devices_state.dart';
import 'package:usdc_wallet/features/expenses/models/expenses_state.dart';
import 'package:usdc_wallet/features/savings_pots/models/savings_pots_state.dart';

/// Filtered+paginated transactions (used by transactions_view.dart)
final filteredPaginatedTransactionsProvider =
    StateNotifierProvider.autoDispose<FilteredPaginatedTransactionsNotifier, FilteredPaginatedTransactionsState>((ref) {
  return FilteredPaginatedTransactionsNotifier();
});

class FilteredPaginatedTransactionsNotifier extends StateNotifier<FilteredPaginatedTransactionsState> {
  FilteredPaginatedTransactionsNotifier() : super(const FilteredPaginatedTransactionsState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false, transactions: <Transaction>[], hasMore: false);
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false);
  }
}

/// Exchange rate provider
final exchangeRateProvider = FutureProvider.autoDispose<ExchangeRate>((ref) async {
  return ExchangeRate(
    fromCurrency: 'USDC',
    toCurrency: 'XOF',
    rate: 655.957,
    timestamp: DateTime.now(),
  );
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
    FutureProvider.autoDispose<List<TopRecipient>>((ref) async {
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
    FutureProvider<List<String>>((ref) async => []);

// analyticsServiceProvider is in lib/services/analytics/analytics_provider.dart
