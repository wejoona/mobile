import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/core/guards/guard_base.dart';

/// Detects unusual transaction velocity patterns.
class VelocityGuard extends GuardBase {
  static const _tag = 'VelocityGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'velocity';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final txCountLast5Min = context.params['txCountLast5Min'] as int? ?? 0;
    final txCountLastHour = context.params['txCountLastHour'] as int? ?? 0;

    if (txCountLast5Min > 5) {
      _log.warn('Velocity alert: $txCountLast5Min tx in 5 min');
      return const GuardResult.deny('Trop de transactions en peu de temps');
    }
    if (txCountLastHour > 20) {
      return const GuardResult.deny('Limite horaire de transactions atteinte');
    }
    return const GuardResult.allow();
  }
}

final velocityGuardProvider = Provider<VelocityGuard>((ref) {
  return VelocityGuard();
});
