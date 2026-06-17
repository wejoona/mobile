import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// USDC → XOF exchange rate.
class ExchangeRate {
  final double rate;
  final String from;
  final String to;
  final DateTime updatedAt;

  const ExchangeRate({
    required this.rate,
    this.from = 'USDC',
    this.to = 'XOF',
    required this.updatedAt,
  });

  /// Convert USDC amount to XOF.
  double toXof(double usdc) => usdc * rate;

  /// Format XOF amount with separator.
  String formatXof(double usdc) {
    final xof = toXof(usdc);
    // Format with thousand separators, no decimals for CFA
    final parts = xof.round().toString().split('');
    final buffer = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(parts[i]);
    }
    return '${buffer.toString()} FCFA';
  }
}

/// Fetches USDC/XOF rate from backend. Refreshes every 10 minutes.
final exchangeRateProvider = FutureProvider<ExchangeRate>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 10), () => link.close());
  ref.onDispose(() => timer.cancel());

  final response = await dio.get(
    ApiEndpoints.walletExchangeRate,
    queryParameters: {
      'sourceCurrency': 'XOF',
      'targetCurrency': 'USD',
      'amount': 10000,
      'direction': 'buy',
    },
  );
  final data = response.data as Map<String, dynamic>;
  final rate = data.containsKey('fromCurrency')
      ? _readDouble(data['rate']) ?? _rateFromAmounts(data)
      : _rateFromAmounts(data) ??
            _readDouble(data['rateDecimal']) ??
            _readDouble(data['rate']);
  if (rate == null || rate <= 0) {
    throw const FormatException('Exchange rate response missing rate');
  }
  return ExchangeRate(rate: rate, updatedAt: _updatedAt(data));
});

double? _rateFromAmounts(Map<String, dynamic> data) {
  final sourceAmount =
      (data['sourceAmount'] as num?)?.toDouble() ??
      double.tryParse(data['sourceAmountDecimal']?.toString() ?? '');
  final targetAmount =
      (data['targetAmount'] as num?)?.toDouble() ??
      double.tryParse(data['targetAmountDecimal']?.toString() ?? '');
  if (sourceAmount == null || targetAmount == null || targetAmount <= 0) {
    return null;
  }
  return sourceAmount / targetAmount;
}

double? _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

DateTime _updatedAt(Map<String, dynamic> data) {
  final raw = data['timestamp'] ?? data['expiresAt'];
  return DateTime.tryParse(raw?.toString() ?? '') ?? DateTime.now();
}
