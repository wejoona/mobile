import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

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
    final response = await dio
        .get(
          '/wallet',
          options: Options(
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            validateStatus: (status) =>
                status != null && (status < 400 || status == 404),
          ),
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 404) {
      final created = await dio
          .post(
            '/wallet/create',
            options: Options(
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
            ),
          )
          .timeout(const Duration(seconds: 18));
      return _walletBalanceFromPayload(created.data);
    }
    return _walletBalanceFromPayload(response.data);
  } on DioException catch (error) {
    if (error.response?.statusCode != 404) {
      rethrow;
    }

    final response = await dio
        .post(
          '/wallet/create',
          options: Options(
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
          ),
        )
        .timeout(const Duration(seconds: 18));
    return _walletBalanceFromPayload(response.data);
  }
});

WalletBalance _walletBalanceFromPayload(dynamic payload) {
  final data = _asMap(payload);
  final envelopeData = _asMap(data['data']);
  final wallet = _unwrapWalletMap(
    envelopeData.isNotEmpty ? envelopeData : data,
  );

  // GET /wallet returns { walletId, currency, balances: [...] }.
  // POST /wallet/create returns { id, currency, balance }.
  // Prefer the spendable USDC row, then the wallet currency row, then the
  // first positive row. Backend row order is not a UI contract.
  final balances = wallet['balances'] as List? ?? [];
  if (balances.isNotEmpty) {
    final selected = _selectBalanceRow(
      balances.whereType<Map>().map(Map<String, dynamic>.from).toList(),
      wallet['currency'] as String?,
    );
    if (selected != null) {
      return WalletBalance.fromJson({
        'available': selected['available'],
        'availableDecimal': selected['availableDecimal'],
        'pending': selected['pending'],
        'pendingDecimal': selected['pendingDecimal'],
        'total': selected['total'],
        'totalDecimal': selected['totalDecimal'],
        'currency': selected['currency'] ?? wallet['currency'] ?? 'USDC',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  return WalletBalance.fromJson({
    'available': wallet['available'] ?? wallet['balance'] ?? 0,
    'pending': wallet['pending'] ?? 0,
    'total': wallet['total'] ?? wallet['balance'] ?? 0,
    'currency': wallet['currency'] ?? 'USDC',
    'updatedAt': DateTime.now().toIso8601String(),
  });
}

Map<String, dynamic>? _selectBalanceRow(
  List<Map<String, dynamic>> balances,
  String? walletCurrency,
) {
  if (balances.isEmpty) return null;

  Map<String, dynamic>? byCurrency(String currency) {
    for (final balance in balances) {
      if ((balance['currency'] as String?)?.toUpperCase() ==
          currency.toUpperCase()) {
        return balance;
      }
    }
    return null;
  }

  final usdc = byCurrency('USDC');
  if (usdc != null) return usdc;

  if (walletCurrency != null && walletCurrency.trim().isNotEmpty) {
    final matchingWalletCurrency = byCurrency(walletCurrency);
    if (matchingWalletCurrency != null) return matchingWalletCurrency;
  }

  for (final balance in balances) {
    final amount =
        _amountFromString(balance['availableDecimal']) ??
        _amountFromString(balance['available_decimal']) ??
        (balance['available'] as num?)?.toDouble() ??
        0;
    if (amount > 0) return balance;
  }

  return balances.first;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

Map<String, dynamic> _unwrapWalletMap(Map<String, dynamic> value) {
  for (final key in const ['wallet', 'account', 'result']) {
    final nested = _asMap(value[key]);
    if (nested.isNotEmpty) return nested;
  }
  return value;
}

double? _amountFromString(Object? value) {
  if (value is String) return double.tryParse(value);
  return null;
}

/// Available balance shortcut.
final availableBalanceProvider = Provider<double>((ref) {
  final walletState = ref.watch(walletStateMachineProvider);
  if (walletState.hasBalanceData) {
    return walletState.availableBalance;
  }

  return ref.watch(walletBalanceProvider).value?.available ?? 0;
});

/// Whether balance is sufficient for a given amount.
final hasSufficientBalanceProvider = Provider.family<bool, double>((
  ref,
  amount,
) {
  return ref.watch(availableBalanceProvider) >= amount;
});
