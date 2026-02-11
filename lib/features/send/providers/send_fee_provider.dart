import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/providers/wallet_actions_provider.dart';

/// Fee estimate for a transfer.
class FeeEstimate {
  final double fee;
  final double total;
  final String feeType; // flat, percentage
  final double? feePercentage;

  const FeeEstimate({this.fee = 0, this.total = 0, this.feeType = 'flat', this.feePercentage});

  factory FeeEstimate.fromAmount(double amount, double fee) => FeeEstimate(
    fee: fee,
    total: amount + fee,
    feeType: 'calculated',
  );
}

/// Fee estimate provider — uses WalletActions.estimateFee.
final sendFeeProvider = FutureProvider.family<FeeEstimate, double>((ref, amount) async {
  if (amount <= 0) return const FeeEstimate();
  try {
    final actions = ref.watch(walletActionsProvider);
    final fee = await actions.estimateFee(amount: amount, type: 'internal');
    return FeeEstimate.fromAmount(amount, fee);
  } catch (_) {
    // Fallback to local fee calculation
    return FeeEstimate.fromAmount(amount, amount * 0.001); // 0.1% default
  }
});
