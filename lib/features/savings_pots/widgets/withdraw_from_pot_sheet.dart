import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/pin_confirmation_sheet.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/features/savings_pots/providers/pot_actions_provider.dart';
import 'package:usdc_wallet/features/savings_pots/providers/savings_pots_provider.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Bottom sheet for withdrawing money from a pot
class WithdrawFromPotSheet extends ConsumerStatefulWidget {
  const WithdrawFromPotSheet({super.key, required this.potId});

  final String potId;

  @override
  ConsumerState<WithdrawFromPotSheet> createState() =>
      _WithdrawFromPotSheetState();
}

class _WithdrawFromPotSheetState extends ConsumerState<WithdrawFromPotSheet> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savingsPotsStateProvider);
    final pot = state.pots.where((p) => p.id == widget.potId).firstOrNull;

    if (pot == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Title
          AppText(
            l10n.savingsPots_withdraw,
            variant: AppTextVariant.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),

          // Pot balance
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.canvas,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  l10n.savingsPots_potBalance,
                  variant: AppTextVariant.bodyMedium,
                  color: context.colors.textSecondary,
                ),
                AppText(
                  formatXof(pot.currentAmount),
                  variant: AppTextVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
                  color: pot.color,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Amount input
          AppInput(
            label: l10n.savingsPots_amount,
            controller: _amountController,
            keyboardType: TextInputType.number,
            prefix: const Text('\$ '),
            hint: '0.00',
          ),
          SizedBox(height: AppSpacing.md),

          // Withdraw all button
          OutlinedButton(
            onPressed: () {
              _amountController.text = pot.currentAmount.toStringAsFixed(2);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.warning,
              side: BorderSide(color: context.colors.warning),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            child: AppText(
              l10n.savingsPots_withdrawAll,
              variant: AppTextVariant.bodyMedium,
              color: context.colors.warning,
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // Withdraw button
          AppButton(
            label: l10n.savingsPots_withdrawButton,
            onPressed: _handleWithdraw,
            isLoading: _isLoading,
            variant: AppButtonVariant.secondary,
          ),
          SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Future<void> _handleWithdraw() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.savingsPots_invalidAmount),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    final state = ref.read(savingsPotsStateProvider);
    final pot = state.pots.where((p) => p.id == widget.potId).firstOrNull;

    if (pot == null) return;

    if (amount > pot.currentAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.savingsPots_insufficientPotBalance),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    String? pinToken;
    final idempotencyKey = generateIdempotencyKey();
    final confirmation = await PinConfirmationSheet.show(
      context: context,
      title: l10n.savingsPots_withdraw,
      subtitle: l10n.send_enterPinToConfirm,
      amount: amount,
      onConfirm: (pin) async {
        final verification = await ref
            .read(pinServiceProvider)
            .verifyPinWithBackend(pin);
        if (verification.success && verification.pinToken != null) {
          pinToken = verification.pinToken;
          return true;
        }
        return false;
      },
    );

    if (confirmation != PinConfirmationResult.success || pinToken == null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(potActionsProvider.notifier)
          .withdraw(
            widget.potId,
            amount,
            pinToken: pinToken!,
            idempotencyKey: idempotencyKey,
          );
      await ref.read(walletStateMachineProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
