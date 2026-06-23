import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/wallet.dart' as wallet_entity;
import 'package:usdc_wallet/services/wallet/wallet_service.dart'
    as wallet_service;
import 'package:usdc_wallet/state/wallet_state_machine.dart';

/// Wallet balance state.
class WalletBalance {
  const WalletBalance({
    required this.updatedAt,
    this.available = 0,
    this.pending = 0,
    this.total = 0,
    this.currency = 'USDC',
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    final available = _amountFromAny(json, const [
      'availableDecimal',
      'available_decimal',
      'availableBalanceDecimal',
      'available_balance_decimal',
      'balanceDecimal',
      'balance_decimal',
      'available',
      'availableBalance',
      'available_balance',
      'balance',
    ]);
    final pending = _amountFromAny(json, const [
      'pendingDecimal',
      'pending_decimal',
      'pendingBalanceDecimal',
      'pending_balance_decimal',
      'pending',
      'pendingBalance',
      'pending_balance',
    ]);
    final total = _amountFromAny(json, const [
      'totalDecimal',
      'total_decimal',
      'totalBalanceDecimal',
      'total_balance_decimal',
      'balanceDecimal',
      'balance_decimal',
      'total',
      'totalBalance',
      'total_balance',
      'balance',
      'available',
      'availableBalance',
      'available_balance',
    ]);

    return WalletBalance(
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      available: available ?? total ?? 0,
      pending: pending ?? 0,
      total: total ?? available ?? 0,
      currency: json['currency'] as String? ?? 'USDC',
    );
  }

  factory WalletBalance.fromWalletResponse(
    wallet_service.WalletBalanceResponse response,
  ) {
    final selected = _selectedBalance(response);
    return WalletBalance(
      updatedAt: DateTime.now(),
      available: selected?.available ?? response.availableBalance,
      pending:
          selected?.pending ??
          response.balances.fold<double>(
            0,
            (total, balance) => total + balance.pending,
          ),
      total: selected?.total ?? response.totalBalance,
      currency: selected?.currency ?? response.currency,
    );
  }

  final double available;
  final double pending;
  final double total;
  final String currency;
  final DateTime updatedAt;
}

wallet_entity.WalletBalance? _selectedBalance(
  wallet_service.WalletBalanceResponse response,
) {
  if (response.balances.isEmpty) {
    return null;
  }

  wallet_entity.WalletBalance? byCurrency(String currency) {
    for (final balance in response.balances) {
      if (balance.currency.toUpperCase() == currency.toUpperCase()) {
        return balance;
      }
    }
    return null;
  }

  final usdc = byCurrency('USDC');
  if (usdc != null) {
    return usdc;
  }

  final declared = response.currency.trim();
  if (declared.isNotEmpty) {
    final matchingDeclared = byCurrency(declared);
    if (matchingDeclared != null) {
      return matchingDeclared;
    }
  }

  for (final balance in response.balances) {
    if (balance.available > 0 || balance.total > 0) {
      return balance;
    }
  }

  return response.balances.first;
}

/// Wallet balance provider — wired to GET /wallet.
/// Backend serves balance at GET /wallet (not /wallet/balance).
final walletBalanceProvider = FutureProvider<WalletBalance>((ref) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(seconds: 30), link.close);
  ref.onDispose(timer.cancel);

  final response = await ref
      .watch(wallet_service.walletServiceProvider)
      .getBalance()
      .timeout(const Duration(seconds: 18));
  return WalletBalance.fromWalletResponse(response);
});

double? _amountFromAny(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (!json.containsKey(key)) continue;
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
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
final hasSufficientBalanceProvider = Provider.family<bool, double>(
  (ref, amount) => ref.watch(availableBalanceProvider) >= amount,
);
