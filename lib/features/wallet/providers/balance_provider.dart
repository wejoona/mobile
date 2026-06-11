import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Wallet balance state.
class WalletBalance {
  final double available;
  final double pending;
  final double total;
  final String currency;
  final DateTime updatedAt;

  const WalletBalance({
    this.available = 0,
    this.pending = 0,
    this.total = 0,
    this.currency = 'USDC',
    required this.updatedAt,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
    available:
        _amountFromString(json['availableDecimal']) ??
        _amountFromString(json['available_decimal']) ??
        _amountFromString(json['balanceDecimal']) ??
        _amountFromString(json['balance_decimal']) ??
        (json['available'] as num?)?.toDouble() ??
        (json['balance'] as num?)?.toDouble() ??
        0,
    pending:
        _amountFromString(json['pendingDecimal']) ??
        _amountFromString(json['pending_decimal']) ??
        (json['pending'] as num?)?.toDouble() ??
        0,
    total:
        _amountFromString(json['totalDecimal']) ??
        _amountFromString(json['total_decimal']) ??
        _amountFromString(json['balanceDecimal']) ??
        _amountFromString(json['balance_decimal']) ??
        (json['total'] as num?)?.toDouble() ??
        (json['balance'] as num?)?.toDouble() ??
        0,
    currency: json['currency'] as String? ?? 'USDC',
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

/// Wallet balance provider — wired to GET /wallet.
/// Backend serves balance at GET /wallet (not /wallet/balance).
final walletBalanceProvider = FutureProvider<WalletBalance>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(seconds: 30), () => link.close());
  ref.onDispose(() => timer.cancel());

  try {
    final response = await dio.get(
      '/wallet',
      options: Options(
        validateStatus: (status) =>
            status != null && (status < 400 || status == 404),
      ),
    );
    if (response.statusCode == 404) {
      final created = await dio.post('/wallet/create');
      return _walletBalanceFromPayload(created.data);
    }
    return _walletBalanceFromPayload(response.data);
  } on DioException catch (error) {
    if (error.response?.statusCode != 404) {
      rethrow;
    }

    final response = await dio.post('/wallet/create');
    return _walletBalanceFromPayload(response.data);
  }
});

WalletBalance _walletBalanceFromPayload(dynamic payload) {
  final data = _asMap(payload);
  final envelopeData = _asMap(data['data']);
  final wallet = envelopeData.isNotEmpty ? envelopeData : data;

  // GET /wallet returns { walletId, currency, balances: [...] }.
  // POST /wallet/create returns { id, currency, balance }.
  // Extract the first balance entry when present, otherwise use root balance.
  final balances = wallet['balances'] as List? ?? [];
  if (balances.isNotEmpty) {
    final first = Map<String, dynamic>.from(balances.first as Map);
    return WalletBalance.fromJson({
      'available': first['available'],
      'availableDecimal': first['availableDecimal'],
      'pending': first['pending'],
      'pendingDecimal': first['pendingDecimal'],
      'total': first['total'],
      'totalDecimal': first['totalDecimal'],
      'currency': first['currency'] ?? 'USDC',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  return WalletBalance.fromJson({
    'available': wallet['available'] ?? wallet['balance'] ?? 0,
    'pending': wallet['pending'] ?? 0,
    'total': wallet['total'] ?? wallet['balance'] ?? 0,
    'currency': wallet['currency'] ?? 'USDC',
    'updatedAt': DateTime.now().toIso8601String(),
  });
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

double? _amountFromString(Object? value) {
  if (value is String) return double.tryParse(value);
  return null;
}

/// Available balance shortcut.
final availableBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletBalanceProvider).value?.available ?? 0;
});

/// Whether balance is sufficient for a given amount.
final hasSufficientBalanceProvider = Provider.family<bool, double>((
  ref,
  amount,
) {
  return ref.watch(availableBalanceProvider) >= amount;
});
