import 'dart:async';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/transactions/models/filtered_transactions_state.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/features/insights/models/top_recipient.dart';

/// Compatibility providers used by older feature views.
///
/// New features should live in their own feature folders. While these adapters
/// remain, they must still call real APIs and avoid fake/demo values in live mode.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';
import 'package:usdc_wallet/features/deposit/models/provider_data.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart'
    hide TransactionItem, TransactionPage;
import 'package:usdc_wallet/services/sdk/usdc_wallet_sdk.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';

/// Filtered+paginated transactions — wired to GET /wallet/transactions.
final filteredPaginatedTransactionsProvider =
    StateNotifierProvider.autoDispose<
      FilteredPaginatedTransactionsNotifier,
      FilteredPaginatedTransactionsState
    >((ref) {
      return FilteredPaginatedTransactionsNotifier(ref);
    });

class FilteredPaginatedTransactionsNotifier
    extends StateNotifier<FilteredPaginatedTransactionsState> {
  FilteredPaginatedTransactionsNotifier(this._ref)
    : super(const FilteredPaginatedTransactionsState()) {
    // Auto-load on creation
    unawaited(refresh());
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
      final response = await dio.get(
        '/wallet/transactions',
        queryParameters: params,
      );
      final page = TransactionPage.fromJson(_asStringMap(response.data));
      if (!mounted) {
        return;
      }
      state = FilteredPaginatedTransactionsState(
        isLoading: false,
        transactions: page.transactions,
        hasMore: page.hasMore,
        page: 1,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) {
      return;
    }
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
      final response = await dio.get(
        '/wallet/transactions',
        queryParameters: params,
      );
      final page = TransactionPage.fromJson(_asStringMap(response.data));
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        transactions: [...state.transactions, ...page.transactions],
        hasMore: page.hasMore,
        page: nextPage,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected JSON object');
}

/// Exchange rate provider — wired to GET /wallet/exchange-rate.
final exchangeRateProvider = FutureProvider.autoDispose<ExchangeRate>((
  ref,
) async {
  final selectedCountry = ref.watch(selectedCountryProvider);
  final userCountryCode = ref.watch(
    userStateMachineProvider.select((state) => state.countryCode),
  );
  final effectiveCountry =
      SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
  if (effectiveCountry.primaryCurrency == 'USD') {
    return ExchangeRate(
      fromCurrency: 'USD',
      toCurrency: 'USD',
      rate: 1,
      timestamp: DateTime.now(),
    );
  }

  final depositService = ref.watch(depositServiceProvider);
  try {
    return await depositService.getExchangeRate(
      from: effectiveCountry.primaryCurrency,
      to: 'USD',
    );
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

/// Spending trend provider (insights) derived from real transaction history.
final spendingTrendProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final period = ref.watch(selectedPeriodProvider);
      final items = await _fetchInsightTransactions(ref, period);
      final start = _periodStart(period);
      final days = DateTime.now().difference(start).inDays + 1;
      final buckets = <DateTime, double>{
        for (var i = 0; i < days; i++)
          DateTime(start.year, start.month, start.day + i): 0,
      };

      for (final item in items) {
        if (!_isSpend(item) || item.createdAt.isBefore(start)) continue;
        final day = DateTime(
          item.createdAt.year,
          item.createdAt.month,
          item.createdAt.day,
        );
        buckets[day] = (buckets[day] ?? 0) + item.amount.abs();
      }

      return buckets.entries
          .map(
            (entry) => {
              'date': entry.key.toIso8601String(),
              'amount': entry.value,
            },
          )
          .toList();
    });

/// Selected period for insights
final selectedPeriodProvider = StateProvider<String>((ref) => 'month');

/// Spending by category provider from transaction types.
final spendingByCategoryProvider =
    FutureProvider.autoDispose<Map<String, double>>((ref) async {
      final period = ref.watch(selectedPeriodProvider);
      final items = await _fetchInsightTransactions(ref, period);
      final start = _periodStart(period);
      final categories = <String, double>{};

      for (final item in items) {
        if (!_isSpend(item) || item.createdAt.isBefore(start)) continue;
        final category = _categoryForTransaction(item);
        categories[category] = (categories[category] ?? 0) + item.amount.abs();
      }

      return categories;
    });

/// Spending summary provider backed by GET /wallet/transactions/stats.
final spendingSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final dio = ref.watch(dioProvider);
      final response = await dio.get('/wallet/transactions/stats');
      final stats = _asStringMap(response.data);

      final totalWithdrawn = _amount(stats, 'totalWithdrawn');
      final totalTransferred = _amount(stats, 'totalTransferred');
      final totalReceived = _amount(stats, 'totalDeposited');
      final totalSpent = totalWithdrawn + totalTransferred;

      return {
        'totalSpent': totalSpent,
        'totalReceived': totalReceived,
        'netFlow': totalReceived - totalSpent,
        'count': _intAmount(stats, 'totalTransactions'),
        'currency': stats['currency'] as String? ?? 'USDC',
        'percentageChange': 0.0,
        'isIncrease': false,
      };
    });

/// Top recipients provider
final topRecipientsProvider = FutureProvider.autoDispose<List<TopRecipient>>((
  ref,
) async {
  final period = ref.watch(selectedPeriodProvider);
  final items = await _fetchInsightTransactions(ref, period);
  final start = _periodStart(period);
  final totals =
      <String, ({String name, String? phone, double total, int count})>{};

  for (final item in items) {
    if (!_isSpend(item) || item.createdAt.isBefore(start)) continue;
    final phone = item.recipientPhone;
    final name = phone?.trim().isNotEmpty == true
        ? phone!.trim()
        : item.recipientAddress?.trim().isNotEmpty == true
        ? item.recipientAddress!.trim()
        : 'External recipient';
    final id = name.toLowerCase();
    final existing = totals[id];
    totals[id] = (
      name: existing?.name ?? name,
      phone: existing?.phone ?? phone,
      total: (existing?.total ?? 0) + item.amount.abs(),
      count: (existing?.count ?? 0) + 1,
    );
  }

  final grandTotal = totals.values.fold<double>(
    0,
    (sum, recipient) => sum + recipient.total,
  );
  final entries = totals.entries.toList()
    ..sort((a, b) => b.value.total.compareTo(a.value.total));

  return entries
      .map(
        (entry) => TopRecipient(
          id: entry.key,
          name: entry.value.name,
          phoneNumber: entry.value.phone,
          totalSent: entry.value.total,
          percentage: grandTotal == 0
              ? 0
              : (entry.value.total / grandTotal) * 100,
          transactionCount: entry.value.count,
        ),
      )
      .toList();
});

Future<List<Transaction>> _fetchInsightTransactions(
  Ref ref,
  String period,
) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(
    '/wallet/transactions',
    queryParameters: {
      'offset': 0,
      'limit': 100,
      'startDate': _periodStart(period).toIso8601String(),
      'sortBy': 'createdAt',
      'sortOrder': 'DESC',
    },
  );
  return TransactionPage.fromJson(_asStringMap(response.data)).transactions;
}

DateTime _periodStart(String period) {
  final now = DateTime.now();
  final days = switch (period) {
    'week' => 6,
    'quarter' => 89,
    'year' => 364,
    _ => 29,
  };
  final start = now.subtract(Duration(days: days));
  return DateTime(start.year, start.month, start.day);
}

bool _isSpend(Transaction item) =>
    item.isDebit ||
    item.type == TransactionType.withdrawal ||
    item.type == TransactionType.transferExternal;

String _categoryForTransaction(Transaction item) {
  switch (item.type) {
    case TransactionType.withdrawal:
      return 'Withdrawals';
    case TransactionType.transferExternal:
      return 'External transfers';
    case TransactionType.transferInternal:
      return 'Transfers';
    case TransactionType.deposit:
      return 'Other spending';
  }
}

double _amount(Map<String, dynamic> json, String key) {
  final decimal = json['${key}Decimal'];
  if (decimal is String) return double.tryParse(decimal) ?? 0;
  final value = json[key];
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _intAmount(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Notifications notifier provider — wired to GET /notifications.
final notificationsNotifierProvider = FutureProvider.autoDispose<List<dynamic>>(
  (ref) async {
    final dio = ref.watch(dioProvider);
    try {
      final response = await dio.get('/notifications');
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List?) ?? [];
    } catch (_) {
      return [];
    }
  },
);

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

/// Deposit providers list — wired to GET /wallet/deposit/channels.
final depositProvidersAvailabilityProvider =
    FutureProvider<DepositProvidersAvailability>((ref) async {
      final depositService = ref.watch(depositServiceProvider);
      final selectedCountry = ref.watch(selectedCountryProvider);
      final userCountryCode = ref.watch(
        userStateMachineProvider.select((state) => state.countryCode),
      );
      final effectiveCountry =
          SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
      final payload = await depositService.getProvidersAvailability(
        countryCode: effectiveCountry.code,
        currency: effectiveCountry.primaryCurrency,
      );
      return DepositProvidersAvailability(
        providers: payload.providers
            .where((json) => json['available'] as bool? ?? true)
            .where((json) => _matchesSelectedCountry(json, effectiveCountry))
            .map(_providerDataFromJson)
            .where((provider) => provider.id.isNotEmpty)
            .toList(),
        country: payload.country ?? effectiveCountry.code,
        currency: payload.currency,
        status: payload.status,
        reason: payload.reason,
        retryable: payload.retryable,
        supportReviewRequired: payload.supportReviewRequired,
      );
    });

final providersListProvider = FutureProvider<List<ProviderData>>((ref) async {
  final availability = await ref.watch(
    depositProvidersAvailabilityProvider.future,
  );
  return availability.providers;
});

bool _matchesSelectedCountry(
  Map<String, dynamic> json,
  CountryConfig selectedCountry,
) {
  final countries = _stringList(json, const [
    'countries',
    'countryCodes',
    'supportedCountries',
  ]);
  final singleCountry = json['country'] ?? json['countryCode'];
  final selectedCode = selectedCountry.code.toUpperCase();
  final countryMatches =
      countries.isEmpty && singleCountry == null ||
      countries.map((code) => code.toUpperCase()).contains(selectedCode) ||
      singleCountry?.toString().toUpperCase() == selectedCode;

  final currencies = _stringList(json, const [
    'supportedCurrencies',
    'currencies',
  ]);
  final singleCurrency = json['currency'];
  final selectedCurrencies = selectedCountry.supportedDepositCurrencies
      .map((currency) => currency.toUpperCase())
      .toSet();
  final currencyMatches =
      currencies.isEmpty && singleCurrency == null ||
      currencies
          .map((currency) => currency.toUpperCase())
          .any(selectedCurrencies.contains) ||
      selectedCurrencies.contains(singleCurrency?.toString().toUpperCase());

  final rail = (json['rail'] ?? json['type'] ?? json['paymentRail'])
      ?.toString()
      .toLowerCase();
  final railMatches =
      rail == null || selectedCountry.supportedDepositRails.contains(rail);

  return countryMatches && currencyMatches && railMatches;
}

ProviderData _providerDataFromJson(Map<String, dynamic> json) {
  return ProviderData(
    id: json['code'] as String? ?? json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    paymentMethodType: json['paymentMethodType'] as String?,
    enumProvider: json['provider'] as String? ?? json['code'] as String?,
    minAmount: (json['minAmount'] as num?)?.toDouble(),
    maxAmount: (json['maxAmount'] as num?)?.toDouble(),
    countries: _stringList(json, const [
      'countries',
      'countryCodes',
      'supportedCountries',
    ]),
    supportedCurrencies: _stringList(json, const [
      'supportedCurrencies',
      'currencies',
    ]),
    rails: _stringList(json, const ['rails', 'type']),
  );
}

List<String> _stringList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      return [value];
    }
  }
  return const [];
}

// analyticsServiceProvider is in lib/services/analytics/analytics_provider.dart
