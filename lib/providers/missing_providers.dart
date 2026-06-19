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
import 'package:usdc_wallet/features/deposit/models/deposit_channel_id.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';
import 'package:usdc_wallet/features/deposit/models/provider_data.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart';
import 'package:usdc_wallet/services/sdk/usdc_wallet_sdk.dart';
import 'package:usdc_wallet/services/notifications/notifications_service.dart';
import 'package:usdc_wallet/services/transactions/transactions_service.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';

/// Filtered+paginated transactions — wired to GET /wallet/transactions.
final filteredPaginatedTransactionsProvider =
    StateNotifierProvider.autoDispose<
      FilteredPaginatedTransactionsNotifier,
      FilteredPaginatedTransactionsState
    >((ref) {
      ref.watch(transactionFilterProvider);
      return FilteredPaginatedTransactionsNotifier(ref);
    });

const _transactionsPageSize = 20;

class FilteredPaginatedTransactionsNotifier
    extends StateNotifier<FilteredPaginatedTransactionsState> {
  FilteredPaginatedTransactionsNotifier(this._ref)
    : super(const FilteredPaginatedTransactionsState()) {
    // Auto-load on creation
    unawaited(refresh());
  }

  final Ref _ref;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, page: 1, clearError: true);
    try {
      final filter = _ref.read(transactionFilterProvider);
      final service = _ref.read(transactionsServiceProvider);
      final page = await service
          .getTransactions(
            page: 1,
            pageSize: _transactionsPageSize,
            filter: filter,
          )
          .timeout(const Duration(seconds: 12));
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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final filter = _ref.read(transactionFilterProvider);
      final service = _ref.read(transactionsServiceProvider);
      final page = await service
          .getTransactions(
            page: nextPage,
            pageSize: _transactionsPageSize,
            filter: filter,
          )
          .timeout(const Duration(seconds: 12));
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        transactions: [...state.transactions, ...page.transactions],
        hasMore: page.hasMore,
        page: nextPage,
        clearError: true,
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
  return depositService.getExchangeRate(
    from: effectiveCountry.primaryCurrency,
    to: 'USD',
  );
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
  final service = ref.watch(transactionsServiceProvider);
  final page = await service.getTransactions(
    page: 1,
    pageSize: 100,
    filter: TransactionFilter(startDate: _periodStart(period)),
  );
  return page.transactions;
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
    final service = ref.watch(notificationsServiceProvider);
    return service.getNotifications(pageSize: 100);
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

  final rail =
      (json['rail'] ??
              json['type'] ??
              json['paymentRail'] ??
              json['paymentMethodType'] ??
              json['provider'])
          ?.toString();
  final railMatches =
      rail == null || _railMatchesCountry(rail, selectedCountry);

  return countryMatches && currencyMatches && railMatches;
}

ProviderData _providerDataFromJson(Map<String, dynamic> json) {
  return ProviderData(
    id: depositChannelIdFromJson(json),
    name: json['name'] as String? ?? '',
    paymentMethodType: _paymentMethodTypeFromDepositRail(json),
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

String? _paymentMethodTypeFromDepositRail(Map<String, dynamic> json) {
  final explicit = json['paymentMethodType']?.toString();
  if (explicit != null && explicit.isNotEmpty) {
    return explicit;
  }

  final rail =
      (json['rail'] ?? json['type'] ?? json['method'] ?? json['paymentRail'])
          ?.toString()
          .trim()
          .toLowerCase()
          .replaceAll('-', '_');
  switch (rail) {
    case 'mobile_money':
    case 'momo':
      return 'PUSH';
    case 'bank':
    case 'bank_transfer':
    case 'ach':
      return 'BANK_TRANSFER';
    case 'card':
      return 'CARD';
    case 'crypto':
    case 'usdc':
    case 'usdc_crypto':
      return 'CRYPTO';
    case 'qr':
    case 'qr_link':
      return 'QR_LINK';
    case 'otp':
    case 'push':
      return rail?.toUpperCase();
    default:
      return null;
  }
}

bool _railMatchesCountry(String rawRail, CountryConfig selectedCountry) {
  final rail = _normalizeDepositRail(rawRail);
  final countryRails = selectedCountry.supportedDepositRails
      .map(_normalizeDepositRail)
      .toSet();
  return countryRails.contains(rail);
}

String _normalizeDepositRail(String value) {
  final normalized = value.trim().toLowerCase().replaceAll('-', '_');
  switch (normalized) {
    case 'usdc':
    case 'crypto':
    case 'blockchain':
    case 'onchain':
    case 'on_chain':
    case 'usdc_crypto':
      return 'crypto';
    case 'ach':
    case 'bank':
    case 'bank_transfer':
    case 'wire':
      return 'bank_transfer';
    case 'card':
    case 'credit_card':
    case 'debit_card':
    case 'visa':
    case 'mastercard':
      return 'card';
    case 'momo':
    case 'mobile_money':
    case 'orange_money':
    case 'mtn_momo':
    case 'moov_money':
    case 'wave':
    case 'omci':
    case 'mtnci':
    case 'moovci':
    case 'waveci':
    case 'otp':
    case 'push':
    case 'qr_link':
      return 'mobile_money';
    default:
      return normalized;
  }
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
