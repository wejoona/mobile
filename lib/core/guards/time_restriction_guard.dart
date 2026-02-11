import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/core/guards/guard_base.dart';

/// Restricts certain actions to specific time windows.
class TimeRestrictionGuard extends GuardBase {
  static const _tag = 'TimeGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'time_restriction';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final hour = DateTime.now().hour;
    final action = context.action;

    // Large transfers restricted during off-hours (11 PM - 6 AM)
    if (action == 'large_transfer' && (hour >= 23 || hour < 6)) {
      return const GuardResult.deny(
        'Les transferts importants ne sont pas disponibles entre 23h et 6h',
      );
    }
    return const GuardResult.allow();
  }
}

final timeRestrictionGuardProvider = Provider<TimeRestrictionGuard>((ref) {
  return TimeRestrictionGuard();
});
