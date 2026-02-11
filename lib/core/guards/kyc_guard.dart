import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'guard_base.dart';

/// Vérifie le niveau KYC requis pour une action.
class KycGuard extends GuardBase {
  static const _tag = 'KycGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'kyc';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final requiredTier = context.params['requiredKycTier'] as String? ?? 'basic';
    final currentTier = context.params['currentKycTier'] as String? ?? 'none';

    final tierOrder = ['none', 'basic', 'verified', 'enhanced'];
    final requiredIndex = tierOrder.indexOf(requiredTier);
    final currentIndex = tierOrder.indexOf(currentTier);

    if (currentIndex < requiredIndex) {
      _log.debug('KYC guard: tier $currentTier < required $requiredTier');
      return const GuardResult.redirect('/kyc-upgrade');
    }
    return const GuardResult.allow();
  }
}

final kycGuardProvider = Provider<KycGuard>((ref) {
  return KycGuard();
});
