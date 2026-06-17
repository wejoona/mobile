import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Spending insights provider — wired to transaction stats API.
/// Re-fetches when the selected period changes.
final spendingInsightsProvider = FutureProvider<SpendingInsights>((ref) async {
  final dio = ref.watch(dioProvider);
  final period = ref.watch(insightsPeriodProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 10), () => link.close());
  ref.onDispose(() => timer.cancel());

  final now = DateTime.now();
  final from = now.subtract(Duration(days: period.days));

  final response = await dio.get(
    ApiEndpoints.walletTransactionStats,
    queryParameters: {
      'from': from.toIso8601String(),
      'to': now.toIso8601String(),
      'period': period.name,
    },
  );
  return SpendingInsights.fromJson(_payloadMap(response.data));
});

/// Spending insights model.
class SpendingInsights {
  final double totalSpent;
  final double totalReceived;
  final double netFlow;
  final int transactionCount;
  final List<SpendingSummary> categoryBreakdown;

  const SpendingInsights({
    this.totalSpent = 0,
    this.totalReceived = 0,
    this.netFlow = 0,
    this.transactionCount = 0,
    this.categoryBreakdown = const [],
  });

  factory SpendingInsights.fromJson(Map<String, dynamic> json) {
    final payload = _payloadMap(json);
    final withdrawn = _amount(payload, 'totalWithdrawn');
    final transferred = _amount(payload, 'totalTransferred');
    final received = _amount(payload, 'totalDeposited');
    final spent = withdrawn + transferred;

    return SpendingInsights(
      totalSpent: spent,
      totalReceived: received,
      netFlow: _amount(payload, 'netFlow', fallback: received - spent),
      transactionCount:
          _intValue(payload['totalTransactions']) ??
          _intValue(payload['totalCount']) ??
          0,
      categoryBreakdown:
          (payload['categories'] as List?)
              ?.map((e) => SpendingSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
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

final insightsPeriodProvider = StateProvider<InsightsPeriod>(
  (ref) => InsightsPeriod.month,
);

Map<String, dynamic> _payloadMap(Object? raw) {
  if (raw is Map<String, dynamic>) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return raw;
  }
  if (raw is Map) {
    return _payloadMap(Map<String, dynamic>.from(raw));
  }
  return const {};
}

double _amount(Map<String, dynamic> json, String key, {double fallback = 0}) {
  final decimal = json['${key}Decimal'];
  if (decimal is num) {
    return decimal.toDouble();
  }
  if (decimal is String) {
    return double.tryParse(decimal) ?? fallback;
  }
  final value = json[key];
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }
  return fallback;
}

int? _intValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
