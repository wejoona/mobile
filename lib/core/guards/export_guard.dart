import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/core/guards/guard_base.dart';

/// Garde pour l'exportation de données sensibles.
class ExportGuard extends GuardBase {
  static const _tag = 'ExportGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'export';

  @override
  Future<GuardResult> check(GuardContext context) async {
    // Require recent biometric auth for export
    final recentBiometric = context.params['recentBiometric'] as bool? ?? false;
    if (!recentBiometric) {
      return const GuardResult.redirect('/biometric-verify');
    }

    // Check export rate limit (max 3 per day)
    final exportsToday = context.params['exportsToday'] as int? ?? 0;
    if (exportsToday >= 3) {
      return const GuardResult.deny('Limite d\'exportation quotidienne atteinte');
    }

    // Check if export type is allowed
    final exportType = context.params['type'] as String?;
    if (exportType == 'full_history' && context.params['kycTier'] != 'verified') {
      return const GuardResult.deny('KYC vérifié requis pour l\'export complet');
    }

    _log.debug('Export guard passed for type: $exportType');
    return const GuardResult.allow();
  }
}

final exportGuardProvider = Provider<ExportGuard>((ref) {
  return ExportGuard();
});
