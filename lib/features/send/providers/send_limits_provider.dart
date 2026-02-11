import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';

/// Whether a specific send amount would exceed limits.
final sendLimitCheckProvider = Provider.family<SendLimitResult, double>((ref, amount) {
  final limitMsg = ref.watch(limitCheckProvider(amount));
  final maxAmount = ref.watch(effectiveMaxProvider);

  return SendLimitResult(
    isWithinLimits: limitMsg == null,
    limitMessage: limitMsg,
    maxAllowed: maxAmount,
    suggestedAmount: limitMsg != null ? maxAmount : null,
  );
});

/// Send limit check result.
class SendLimitResult {
  final bool isWithinLimits;
  final String? limitMessage;
  final double maxAllowed;
  final double? suggestedAmount;

  const SendLimitResult({
    this.isWithinLimits = true,
    this.limitMessage,
    this.maxAllowed = 0,
    this.suggestedAmount,
  });
}
