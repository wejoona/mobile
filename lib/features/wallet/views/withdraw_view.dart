import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../services/index.dart';
import '../../../state/index.dart';
import '../providers/wallet_provider.dart';

/// Withdrawal method type
enum WithdrawMethod {
  mobileMoney,
  bankTransfer,
  crypto,
}

extension WithdrawMethodExt on WithdrawMethod {
  String get label {
    switch (this) {
      case WithdrawMethod.mobileMoney:
        return 'Mobile Money';
      case WithdrawMethod.bankTransfer:
        return 'Bank Transfer';
      case WithdrawMethod.crypto:
        return 'Crypto Wallet';
    }
  }

  IconData get icon {
    switch (this) {
      case WithdrawMethod.mobileMoney:
        return Icons.phone_android;
      case WithdrawMethod.bankTransfer:
        return Icons.account_balance;
      case WithdrawMethod.crypto:
        return Icons.currency_bitcoin;
    }
  }

  String get description {
    switch (this) {
      case WithdrawMethod.mobileMoney:
        return 'Withdraw to Orange Money, MTN MoMo, Wave';
      case WithdrawMethod.bankTransfer:
        return 'Transfer to your bank account';
      case WithdrawMethod.crypto:
        return 'Send to external USDC wallet';
    }
  }
}

class WithdrawView extends ConsumerStatefulWidget {
  const WithdrawView({super.key});

  @override
  ConsumerState<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends ConsumerState<WithdrawView> {
  final _amountController = TextEditingController();
  WithdrawMethod? _selectedMethod;
  String? _amountError;
  double _availableBalance = 0;
  bool _isSubmitting = false;

  // Mobile money fields
  final _phoneController = TextEditingController();
  String _countryCode = '+225';

  // Bank fields
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();

  // Crypto fields
  final _walletAddressController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _walletAddressController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    final text = _amountController.text;
    if (text.isEmpty) {
      setState(() => _amountError = null);
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null) {
      setState(() => _amountError = 'Invalid amount');
    } else if (amount <= 0) {
      setState(() => _amountError = 'Amount must be greater than 0');
    } else if (amount > _availableBalance) {
      setState(() => _amountError = 'Insufficient balance');
    } else if (amount < 1) {
      setState(() => _amountError = 'Minimum withdrawal is \$1');
    } else {
      setState(() => _amountError = null);
    }
  }

  bool _canSubmit() {
    if (_selectedMethod == null) return false;
    if (_amountController.text.isEmpty) return false;
    if (_amountError != null) return false;

    switch (_selectedMethod!) {
      case WithdrawMethod.mobileMoney:
        return _phoneController.text.length >= 8;
      case WithdrawMethod.bankTransfer:
        return _accountNumberController.text.isNotEmpty &&
            _bankNameController.text.isNotEmpty;
      case WithdrawMethod.crypto:
        return _walletAddressController.text.length >= 20;
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    String destination = '';
    String recipientDisplay = '';
    String method = '';

    // Build destination and display based on method
    switch (_selectedMethod!) {
      case WithdrawMethod.mobileMoney:
        destination = '$_countryCode${_phoneController.text}';
        recipientDisplay = destination;
        method = 'mobile_money';
        break;
      case WithdrawMethod.bankTransfer:
        destination = _accountNumberController.text;
        recipientDisplay = '${_bankNameController.text} - ${_accountNumberController.text}';
        method = 'bank_transfer';
        break;
      case WithdrawMethod.crypto:
        destination = _walletAddressController.text;
        recipientDisplay = '${destination.substring(0, 6)}...${destination.substring(destination.length - 4)}';
        method = 'crypto';
        break;
    }

    // Show PIN confirmation
    final result = await PinConfirmationSheet.show(
      context: context,
      title: 'Confirm Withdrawal',
      subtitle: 'Enter your PIN to withdraw funds',
      amount: amount,
      recipient: recipientDisplay,
      onConfirm: (pin) async {
        // Verify PIN with backend for financial transactions
        final pinService = ref.read(pinServiceProvider);
        final verification = await pinService.verifyPinWithBackend(pin);
        return verification.success;
      },
    );

    if (result == PinConfirmationResult.success) {
      setState(() => _isSubmitting = true);

      // Call withdrawal service
      final success = await ref.read(withdrawProvider.notifier).withdraw(
            amount: amount,
            destinationAddress: destination,
            network: _selectedMethod == WithdrawMethod.crypto ? 'polygon' : null,
            method: method,
          );

      setState(() => _isSubmitting = false);

      if (success) {
        // Refresh wallet and transactions via FSM
        ref.read(walletStateMachineProvider.notifier).refresh();
        ref.read(transactionStateMachineProvider.notifier).refresh();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Withdrawal request submitted successfully!'),
              backgroundColor: AppColors.successBase,
            ),
          );
          context.pop();
        }
      } else {
        // Error is handled by listener
        if (mounted) {
          final error = ref.read(withdrawProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Withdrawal failed. Please try again.'),
              backgroundColor: AppColors.errorBase,
            ),
          );
        }
      }
    } else if (result == PinConfirmationResult.failed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Too many incorrect attempts. Please try again later.'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final walletState = ref.watch(walletStateMachineProvider);
    final withdrawState = ref.watch(withdrawProvider);

    // Get balance from FSM
    _availableBalance = walletState.availableBalance;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Withdraw',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card from FSM
            AppCard(
              variant: AppCardVariant.subtle,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Available Balance',
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                  ),
                  walletState.isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.gold,
                          ),
                        )
                      : AppText(
                          '\$${walletState.availableBalance.toStringAsFixed(2)}',
                          variant: AppTextVariant.titleMedium,
                          color: colors.gold,
                        ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Amount Input
            _buildAmountCard(colors),

            const SizedBox(height: AppSpacing.xxl),

            // Withdrawal Method
            AppText(
              'Withdrawal Method',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),

            ...WithdrawMethod.values.map((method) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _MethodCard(
                    method: method,
                    isSelected: _selectedMethod == method,
                    onTap: () => setState(() => _selectedMethod = method),
                    colors: colors,
                  ),
                )),

            const SizedBox(height: AppSpacing.xxl),

            // Method-specific fields
            if (_selectedMethod != null) _buildMethodFields(colors),

            const SizedBox(height: AppSpacing.xxl),

            // Submit Button
            AppButton(
              label: 'Withdraw',
              onPressed: _canSubmit() && !_isSubmitting ? _submit : null,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
              isLoading: _isSubmitting || withdrawState.isLoading,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Info
            AppCard(
              variant: AppCardVariant.subtle,
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colors.gold, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText(
                      'Withdrawals typically process within 1-3 business days. Fees may apply depending on the method.',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Amount to withdraw',
            variant: AppTextVariant.cardLabel,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                '\$',
                variant: AppTextVariant.displaySmall,
                color: colors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      style: AppTypography.displaySmall.copyWith(
                        color: _amountError != null
                            ? AppColors.errorBase
                            : colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: colors.textTertiary,
                        ),
                      ),
                      onChanged: (_) => _validateAmount(),
                    ),
                    if (_amountError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: AppText(
                          _amountError!,
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.errorBase,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Quick amount buttons
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _QuickAmountButton(
                label: '25%',
                onTap: () {
                  _amountController.text =
                      (_availableBalance * 0.25).toStringAsFixed(2);
                  _validateAmount();
                },
                colors: colors,
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                label: '50%',
                onTap: () {
                  _amountController.text =
                      (_availableBalance * 0.5).toStringAsFixed(2);
                  _validateAmount();
                },
                colors: colors,
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                label: '75%',
                onTap: () {
                  _amountController.text =
                      (_availableBalance * 0.75).toStringAsFixed(2);
                  _validateAmount();
                },
                colors: colors,
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                label: 'MAX',
                onTap: () {
                  _amountController.text =
                      _availableBalance.toStringAsFixed(2);
                  _validateAmount();
                },
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodFields(ThemeColors colors) {
    switch (_selectedMethod!) {
      case WithdrawMethod.mobileMoney:
        return _buildMobileMoneyFields(colors);
      case WithdrawMethod.bankTransfer:
        return _buildBankFields(colors);
      case WithdrawMethod.crypto:
        return _buildCryptoFields(colors);
    }
  }

  Widget _buildMobileMoneyFields(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Mobile Money Number',
            variant: AppTextVariant.cardLabel,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: Show country picker
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      AppText(
                        _countryCode,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: colors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '07 00 00 00 00',
                    hintStyle: TextStyle(color: colors.textTertiary),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankFields(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Bank Details',
            variant: AppTextVariant.cardLabel,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _bankNameController,
            style: AppTypography.bodyLarge.copyWith(
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Bank Name',
              labelStyle: TextStyle(color: colors.textTertiary),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.gold),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            style: AppTypography.bodyLarge.copyWith(
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Account Number',
              labelStyle: TextStyle(color: colors.textTertiary),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.gold),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoFields(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'USDC Wallet Address',
            variant: AppTextVariant.cardLabel,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _walletAddressController,
            style: AppTypography.bodyLarge.copyWith(
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '0x...',
              hintStyle: TextStyle(color: colors.textTertiary),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.gold),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            'Make sure to use a Solana or Base USDC address',
            variant: AppTextVariant.bodySmall,
            color: colors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final WithdrawMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold.withValues(alpha: 0.1) : colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? colors.gold : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.gold.withValues(alpha: 0.2)
                    : colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? colors.gold : colors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    method.label,
                    variant: AppTextVariant.titleSmall,
                    color: isSelected ? colors.gold : colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    method.description,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.gold,
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  const _QuickAmountButton({
    required this.label,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: AppText(
              label,
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
