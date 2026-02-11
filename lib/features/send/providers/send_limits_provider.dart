import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Run 351: Send limits provider - enforces daily/monthly transfer limits
class SendLimits {
  final double dailyLimit;
  final double dailyUsed;
  final double monthlyLimit;
  final double monthlyUsed;
  final double perTransactionLimit;

  const SendLimits({
    this.dailyLimit = 1000,
    this.dailyUsed = 0,
    this.monthlyLimit = 5000,
    this.monthlyUsed = 0,
    this.perTransactionLimit = 500,
  });

  double get dailyRemaining => dailyLimit - dailyUsed;
  double get monthlyRemaining => monthlyLimit - monthlyUsed;
  double get maxSendable {
    final limits = [dailyRemaining, monthlyRemaining, perTransactionLimit];
    return limits.reduce((a, b) => a < b ? a : b);
  }

  bool canSend(double amount) {
    return amount <= dailyRemaining &&
        amount <= monthlyRemaining &&
        amount <= perTransactionLimit;
  }

  String? validateAmount(double amount) {
    if (amount <= 0) return 'Le montant doit etre positif';
    if (amount > perTransactionLimit) {
      return 'Limite par transaction: $perTransactionLimit USDC';
    }
    if (amount > dailyRemaining) {
      return 'Limite journaliere atteinte ($dailyRemaining USDC restant)';
    }
    if (amount > monthlyRemaining) {
      return 'Limite mensuelle atteinte ($monthlyRemaining USDC restant)';
    }
    return null;
  }
}

final sendLimitsProvider = FutureProvider<SendLimits>((ref) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return const SendLimits();
});
