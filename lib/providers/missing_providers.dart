import 'dart:async';
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
/// Remaining stubs: 7 (as of 2026-02-20)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart';
import 'package:usdc_wallet/services/sdk/usdc_wallet_sdk.dart';

/// Filtered+paginated transactions — wired to GET /wallet/transactions.
final filteredPaginatedTransactionsProvider =
    StateNotifierProvider.autoDispose<FilteredPaginatedTransactionsNotifier, FilteredPaginatedTransactionsState>((ref) {
  return FilteredPaginatedTransactionsNotifier(ref);
});

class FilteredPaginatedTransactionsNotifier extends StateNotifier<FilteredPaginatedTransactionsState> {
  FilteredPaginatedTransactionsNotifier(this._ref) : super(const FilteredPaginatedTransactionsState()) {
    // Auto-load on creation
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, page: 1);
    try {
      final filter = _ref.read(transactionFilterProvider);
      final dio = _ref.read(dioProvider);
      final params = <String, dynamic>{
        ...filter.toQueryParams(),
        'offset': 0,
        'limit': 20,
      };
      final response = await dio.get('/wallet/transactions', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      final items = ((data['transactions'] ?? data['data'] ?? data['items']) as List?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];
      final hasMore = data['hasMore'] as bool? ?? items.length >= 20;
      state = FilteredPaginatedTransactionsState(
        isLoading: false,
        transactions: items,
        hasMore: hasMore,
        page: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoading: true);
    try {
      final filter = _ref.read(transactionFilterProvider);
      final dio = _ref.read(dioProvider);
      final params = <String, dynamic>{
        ...filter.toQueryParams(),
        'offset': (nextPage - 1) * 20,
        'limit': 20,
      };
      final response = await dio.get('/wallet/transactions', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      final items = ((data['transactions'] ?? data['data'] ?? data['items']) as List?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];
      final hasMore = data['hasMore'] as bool? ?? items.length >= 20;
      state = state.copyWith(
        isLoading: false,
        transactions: [...state.transactions, ...items],
        hasMore: hasMore,
        page: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Exchange rate provider — wired to GET /deposits/rate.
final exchangeRateProvider = FutureProvider.autoDispose<ExchangeRate>((ref) async {
  final depositService = ref.watch(depositServiceProvider);
  try {
    return await depositService.getExchangeRate(from: 'XOF', to: 'USD');
  } catch (_) {
    // Fallback to approximate BCEAO peg rate
    return ExchangeRate(
      fromCurrency: 'XOF',
      toCurrency: 'USD',
      rate: 655.957,
      timestamp: DateTime.now(),
    );
  }
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

/// Notifications notifier provider — wired to GET /notifications.
final notificationsNotifierProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/notifications');
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List?) ?? [];
  } catch (_) {
    return [];
  }
});

/// Profile notifier provider — wired to GET /user/profile.
final profileNotifierProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/user/profile');
    return response.data as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
});

/// Deposit providers list — wired to GET /deposits/providers.
final providersListProvider =
    FutureProvider<List<dynamic>>((ref) async {
  final depositService = ref.watch(depositServiceProvider);
  try {
    return await depositService.getProviders();
  } catch (_) {
    return [];
  }
});

// analyticsServiceProvider is in lib/services/analytics/analytics_provider.dart
