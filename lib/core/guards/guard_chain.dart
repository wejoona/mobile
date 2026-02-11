import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/core/guards/guard_base.dart';

/// Chains multiple guards for sequential evaluation.
class GuardChain {
  static const _tag = 'GuardChain';
  final AppLogger _log = AppLogger(_tag);
  final List<GuardBase> _guards;

  GuardChain(this._guards);

  /// Run all guards in order. Returns first denial or allow.
  Future<GuardResult> evaluate(GuardContext context) async {
    for (final guard in _guards) {
      final result = await guard.check(context);
      if (!result.allowed) {
        _log.debug('Guard ${guard.name} denied: ${result.reason}');
        await guard.onBlocked(context, result.reason ?? 'Unknown');
        return result;
      }
    }
    return const GuardResult.allow();
  }

  int get length => _guards.length;
}

final guardChainProvider = Provider.family<GuardChain, List<GuardBase>>((ref, guards) {
  return GuardChain(guards);
});
