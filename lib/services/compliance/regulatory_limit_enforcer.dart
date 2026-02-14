import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Result of limit enforcement check.
class LimitEnforcementResult {
  final bool allowed;
  final double remainingDaily;
  final double remainingMonthly;
  final String? rejectionReason;

  const LimitEnforcementResult({
    required this.allowed,
    required this.remainingDaily,
    required this.remainingMonthly,
    this.rejectionReason,
  });
}

/// Enforces BCEAO and internal regulatory limits on transactions.
///
/// Checks are performed client-side for immediate feedback; the server
/// performs authoritative enforcement.
class RegulatoryLimitEnforcer {
  static const _tag = 'LimitEnforcer';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);

  /// Check if a transaction amount is within limits.
  LimitEnforcementResult check({
    required double amountCfa,
    required double dailyUsedCfa,
    required double monthlyUsedCfa,
    required double dailyLimitCfa,
    required double monthlyLimitCfa,
    double? singleTxLimitCfa,
  }) {
    if (singleTxLimitCfa != null && amountCfa > singleTxLimitCfa) {
      return LimitEnforcementResult(
        allowed: false,
        remainingDaily: dailyLimitCfa - dailyUsedCfa,
        remainingMonthly: monthlyLimitCfa - monthlyUsedCfa,
        rejectionReason:
            'Montant depasse la limite par transaction: '
            '${singleTxLimitCfa.toStringAsFixed(0)} XOF',
      );
    }

    if (dailyUsedCfa + amountCfa > dailyLimitCfa) {
      return LimitEnforcementResult(
        allowed: false,
        remainingDaily: dailyLimitCfa - dailyUsedCfa,
        remainingMonthly: monthlyLimitCfa - monthlyUsedCfa,
        rejectionReason:
            'Limite journaliere atteinte. Restant: '
            '${(dailyLimitCfa - dailyUsedCfa).toStringAsFixed(0)} XOF',
      );
    }

    if (monthlyUsedCfa + amountCfa > monthlyLimitCfa) {
      return LimitEnforcementResult(
        allowed: false,
        remainingDaily: dailyLimitCfa - dailyUsedCfa,
        remainingMonthly: monthlyLimitCfa - monthlyUsedCfa,
        rejectionReason:
            'Limite mensuelle atteinte. Restant: '
            '${(monthlyLimitCfa - monthlyUsedCfa).toStringAsFixed(0)} XOF',
      );
    }

    return LimitEnforcementResult(
      allowed: true,
      remainingDaily: dailyLimitCfa - dailyUsedCfa - amountCfa,
      remainingMonthly: monthlyLimitCfa - monthlyUsedCfa - amountCfa,
    );
  }
}

final regulatoryLimitEnforcerProvider =
    Provider<RegulatoryLimitEnforcer>((ref) {
  return RegulatoryLimitEnforcer();
});
