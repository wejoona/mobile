import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Vérifie les limites de transaction réglementaires.
class TransactionLimitChecker {
  static const _tag = 'LimitCheck';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);

  // BCEAO limits in XOF (USDC equivalent applied at conversion)
  static const double dailyLimitBasic = 200000; // ~$320
  static const double dailyLimitVerified = 2000000; // ~$3200
  static const double monthlyLimitBasic = 1000000;
  static const double monthlyLimitVerified = 10000000;
  static const double singleTransactionMax = 5000000;

  /// Check if a transaction is within limits.
  LimitCheckResult check({
    required double amount,
    required double dailyTotal,
    required double monthlyTotal,
    required String kycTier,
  }) {
    final dailyLimit = kycTier == 'verified' ? dailyLimitVerified : dailyLimitBasic;
    final monthlyLimit = kycTier == 'verified' ? monthlyLimitVerified : monthlyLimitBasic;

    if (amount > singleTransactionMax) {
      return LimitCheckResult.exceeded('Montant maximum par transaction dépassé');
    }
    if (dailyTotal + amount > dailyLimit) {
      return LimitCheckResult.exceeded('Limite journalière atteinte');
    }
    if (monthlyTotal + amount > monthlyLimit) {
      return LimitCheckResult.exceeded('Limite mensuelle atteinte');
    }
    return LimitCheckResult.allowed();
  }
}

class LimitCheckResult {
  final bool allowed;
  final String? reason;
  LimitCheckResult.allowed() : allowed = true, reason = null;
  LimitCheckResult.exceeded(this.reason) : allowed = false;
}

final transactionLimitCheckerProvider = Provider<TransactionLimitChecker>((ref) {
  return TransactionLimitChecker();
});
