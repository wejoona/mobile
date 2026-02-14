/// Bank Transfer View (Deposit/Withdraw)
library;
import 'package:usdc_wallet/design/tokens/index.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/features/bank_linking/providers/bank_linking_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class BankTransferView extends ConsumerStatefulWidget {
  const BankTransferView({
    super.key,
    required this.accountId,
    required this.type,
  });

  final String accountId;
  final String type; // 'deposit' or 'withdraw'

  @override
  ConsumerState<BankTransferView> createState() => _BankTransferViewState();
}

class _BankTransferViewState extends ConsumerState<BankTransferView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  bool get isDeposit => widget.type == 'deposit';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bankLinkingProvider);
    final account = state.linkedAccounts.firstWhere(
      (a) => a.id == widget.accountId,
      orElse: () => state.linkedAccounts.first,
    );

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          isDeposit
              ? l10n.bankLinking_depositFromBank
              : l10n.bankLinking_withdrawToBank,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Bank account card
                    _buildAccountCard(account, l10n),
                    SizedBox(height: AppSpacing.xl),
                    // Amount input
                    AppText(
                      l10n.bankLinking_amount,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppInput(
                      label: l10n.bankLinking_enterAmount,
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.bankLinking_amountRequired;
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return l10n.bankLinking_invalidAmount;
                        }
                        return null;
                      },
                      hint: '10000',
                      suffix: AppText(
                        account.currency,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Quick amounts
                    _buildQuickAmounts(),
                    SizedBox(height: AppSpacing.lg),
                    // Info box
                    _buildInfoBox(l10n),
                  ],
                ),
              ),
              _buildBottomButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(account, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: AppText(
                account.bankName.substring(0, 1),
                style: AppTypography.headlineSmall.copyWith(
                  color: context.colors.gold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  account.bankName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                AppText(
                  account.accountNumberMasked,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                if (account.availableBalance != null) ...[
                  SizedBox(height: 4),
                  AppText(
                    '${l10n.bankLinking_balance}: ${_formatAmount(account.availableBalance!)} ${account.currency}',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts() {
    final amounts = [5000, 10000, 25000, 50000];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: amounts.map((amount) {
        return InkWell(
          onTap: () => _amountController.text = amount.toString(),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: context.colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: context.colors.gold.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: AppText(
              _formatAmount(amount.toDouble()),
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoBox(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: context.colors.textSecondary,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  isDeposit
                      ? l10n.bankLinking_depositInfo
                      : l10n.bankLinking_withdrawInfo,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                if (!isDeposit) ...[
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    l10n.bankLinking_withdrawTime,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.elevated,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: isDeposit
              ? l10n.bankLinking_confirmDeposit
              : l10n.bankLinking_confirmWithdraw,
          onPressed: _handleSubmit,
          isLoading: _isLoading,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.elevated,
        title: AppText(
          isDeposit
              ? AppLocalizations.of(context)!.bankLinking_confirmDeposit
              : AppLocalizations.of(context)!.bankLinking_confirmWithdraw,
          style: AppTypography.headlineSmall,
        ),
        content: AppText(
          isDeposit
              ? AppLocalizations.of(context)!
                  .bankLinking_depositConfirmation(_formatAmount(amount))
              : AppLocalizations.of(context)!
                  .bankLinking_withdrawConfirmation(_formatAmount(amount)),
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(
              AppLocalizations.of(context)!.common_cancel,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          AppButton(
            label: AppLocalizations.of(context)!.common_confirm,
            onPressed: () => Navigator.pop(context, true),
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // In real app, call SDK
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            isDeposit
                ? AppLocalizations.of(context)!.bankLinking_depositSuccess
                : AppLocalizations.of(context)!.bankLinking_withdrawSuccess,
            style: AppTypography.bodyMedium,
          ),
          backgroundColor: context.colors.success,
        ),
      );

      // Navigate back
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            e.toString(),
            style: AppTypography.bodyMedium,
          ),
          backgroundColor: context.colors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }
}
