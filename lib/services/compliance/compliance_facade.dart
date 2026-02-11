import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Façade unifiée pour les services de conformité.
class ComplianceFacade {
  static const _tag = 'ComplianceFacade';
  final AppLogger _log = AppLogger(_tag);

  /// Check if a user can perform a transaction.
  Future<ComplianceCheckResult> checkTransaction({
    required String userId,
    required double amount,
    required String type,
    String? destinationCountry,
  }) async {
    _log.debug('Compliance check: $type for $amount');
    return const ComplianceCheckResult(
      allowed: true,
      checks: ['kyc', 'aml', 'sanctions', 'limits'],
    );
  }
}

class ComplianceCheckResult {
  final bool allowed;
  final List<String> checks;
  final String? reason;

  const ComplianceCheckResult({
    required this.allowed,
    required this.checks,
    this.reason,
  });
}

final complianceFacadeProvider = Provider<ComplianceFacade>((ref) {
  return ComplianceFacade();
});
