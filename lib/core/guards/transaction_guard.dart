import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'guard_base.dart';

/// Garde pour les transactions financières.
class TransactionGuard extends GuardBase {
  static const _tag = 'TransactionGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'transaction';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final amount = (context.params['amount'] as num?)?.toDouble() ?? 0;

    // Check minimum amount
    if (amount <= 0) {
      return const GuardResult.deny('Montant invalide');
    }

    // Check maximum single transaction
    if (amount > 5000000) {
      return const GuardResult.deny('Montant maximum dépassé');
    }

    // Check if recipient is valid
    final recipient = context.params['recipient'] as String?;
    if (recipient == null || recipient.isEmpty) {
      return const GuardResult.deny('Destinataire requis');
    }

    _log.debug('Transaction guard passed: $amount FCFA');
    return const GuardResult.allow();
  }
}

final transactionGuardProvider = Provider<TransactionGuard>((ref) {
  return TransactionGuard();
});
