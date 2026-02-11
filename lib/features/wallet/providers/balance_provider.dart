import 'dart:async';
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
    available: (json['available'] as num?)?.toDouble() ?? (json['balance'] as num?)?.toDouble() ?? 0,
    pending: (json['pending'] as num?)?.toDouble() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? (json['balance'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'USDC',
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

/// Wallet balance provider — wired to GET /wallet/balance.
final walletBalanceProvider = FutureProvider<WalletBalance>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  Timer(const Duration(seconds: 30), () => link.close());

  final response = await dio.get('/wallet/balance');
  return WalletBalance.fromJson(response.data as Map<String, dynamic>);
});

/// Available balance shortcut.
final availableBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletBalanceProvider).value?.available ?? 0;
});

/// Whether balance is sufficient for a given amount.
final hasSufficientBalanceProvider = Provider.family<bool, double>((ref, amount) {
  return ref.watch(availableBalanceProvider) >= amount;
});
