import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';
import 'package:usdc_wallet/features/deposit/views/deposit_amount_screen.dart';
import 'package:usdc_wallet/features/deposit/views/deposit_status_screen.dart';
import 'package:usdc_wallet/features/deposit/views/payment_instructions_screen.dart';
import 'package:usdc_wallet/features/deposit/views/provider_selection_screen.dart';

/// Deposit Screen — Main flow controller
///
/// Routes between sub-screens based on current DepositFlowStep:
/// 1. selectProvider → ProviderSelectionScreen
/// 2. enterAmount → DepositAmountScreen
/// 3. instructions → PaymentInstructionsScreen (adapts to OTP/PUSH/QR)
/// 4. processing → Processing overlay on instructions
/// 5. completed / failed → DepositStatusScreen
class DepositScreen extends ConsumerWidget {
  const DepositScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(depositProvider.select((s) => s.step));

    return PopScope(
      canPop: step == DepositFlowStep.selectProvider ||
          step == DepositFlowStep.completed ||
          step == DepositFlowStep.failed,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(depositProvider.notifier).goBack();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildStep(step),
      ),
    );
  }

  Widget _buildStep(DepositFlowStep step) {
    switch (step) {
      case DepositFlowStep.selectProvider:
        return const ProviderSelectionScreen(key: ValueKey('provider'));
      case DepositFlowStep.enterAmount:
        return const DepositAmountScreen(key: ValueKey('amount'));
      case DepositFlowStep.instructions:
      case DepositFlowStep.processing:
        return const PaymentInstructionsScreen(key: ValueKey('instructions'));
      case DepositFlowStep.completed:
      case DepositFlowStep.failed:
        return const DepositStatusScreen(key: ValueKey('status'));
    }
  }
}
