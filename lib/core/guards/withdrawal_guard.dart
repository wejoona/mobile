import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'guard_base.dart';

/// Garde pour les retraits - vérifications supplémentaires.
class WithdrawalGuard extends GuardBase {
  static const _tag = 'WithdrawalGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'withdrawal';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final amount = (context.params['amount'] as num?)?.toDouble() ?? 0;
    final balance = (context.params['balance'] as num?)?.toDouble() ?? 0;
    final kycTier = context.params['kycTier'] as String? ?? 'basic';

    if (amount > balance) {
      return const GuardResult.deny('Solde insuffisant');
    }

    // Daily withdrawal limit by KYC tier
    final dailyLimit = kycTier == 'verified' ? 2000000.0 : 200000.0;
    final dailyTotal = (context.params['dailyWithdrawn'] as num?)?.toDouble() ?? 0;

    if (dailyTotal + amount > dailyLimit) {
      return const GuardResult.deny('Limite de retrait journalière atteinte');
    }

    // Large withdrawals require step-up auth
    if (amount > 500000) {
      final stepUpDone = context.params['stepUpCompleted'] as bool? ?? false;
      if (!stepUpDone) {
        return const GuardResult.redirect('/step-up-auth');
      }
    }

    _log.debug('Withdrawal guard passed: $amount FCFA');
    return const GuardResult.allow();
  }
}

final withdrawalGuardProvider = Provider<WithdrawalGuard>((ref) {
  return WithdrawalGuard();
});
