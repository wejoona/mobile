import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/savings_pots/providers/savings_pots_provider.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

/// Bottom sheet for adding money to a pot
class AddToPotSheet extends ConsumerStatefulWidget {
  const AddToPotSheet({super.key, required this.potId});

  final String potId;

  @override
  ConsumerState<AddToPotSheet> createState() => _AddToPotSheetState();
}

class _AddToPotSheetState extends ConsumerState<AddToPotSheet> {
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
    final walletState = ref.watch(walletStateMachineProvider);
    final availableBalance = walletState.usdcBalance;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Title
          AppText(
            l10n.savingsPots_addMoney,
            variant: AppTextVariant.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),

          // Available balance
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.obsidian,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  l10n.savingsPots_availableBalance,
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
                AppText(
                  currencyFormat.format(availableBalance),
                  variant: AppTextVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
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

          // Quick amount buttons
          Row(
            children: [
              _buildQuickAmount(l10n.savingsPots_quick10, availableBalance * 0.1),
              SizedBox(width: AppSpacing.sm),
              _buildQuickAmount(l10n.savingsPots_quick25, availableBalance * 0.25),
              SizedBox(width: AppSpacing.sm),
              _buildQuickAmount(l10n.savingsPots_quick50, availableBalance * 0.5),
            ],
          ),
          SizedBox(height: AppSpacing.xl),

          // Add button
          AppButton(
            label: l10n.savingsPots_addButton,
            onPressed: _handleAdd,
            isLoading: _isLoading,
          ),
          SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildQuickAmount(String label, double amount) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          _amountController.text = amount.toStringAsFixed(2);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold500,
          side: BorderSide(color: AppColors.gold500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        child: AppText(
          label,
          variant: AppTextVariant.bodyMedium,
          color: AppColors.gold500,
        ),
      ),
    );
  }

  Future<void> _handleAdd() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.savingsPots_invalidAmount),
          backgroundColor: AppColors.errorBase,
        ),
      );
      return;
    }

    final walletState = ref.read(walletStateMachineProvider);
    final availableBalance = walletState.usdcBalance;

    if (amount > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.savingsPots_insufficientBalance),
          backgroundColor: AppColors.errorBase,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await ref.read(savingsPotsActionsProvider).addToPot(
            widget.potId,
            amount,
          );

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
