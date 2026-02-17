import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Timer(const Duration(minutes: 10), () => link.close());

  try {
    final response = await dio.get('/rates/pair', queryParameters: {
      'from': 'USDC',
      'to': 'XOF',
    });
    final data = response.data as Map<String, dynamic>;
    final rate = (data['rate'] as num?)?.toDouble() ?? 600.0;
    return ExchangeRate(rate: rate, updatedAt: DateTime.now());
  } catch (_) {
    // Fallback to BCEAO peg rate (1 USD ≈ 600 XOF)
    return ExchangeRate(rate: 600.0, updatedAt: DateTime.now());
  }
});
