import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../state/index.dart';

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

  void _submit() {
    // TODO: Implement withdrawal via service
    // Refresh wallet and transactions via FSM
    ref.read(walletStateMachineProvider.notifier).refresh();
    ref.read(transactionStateMachineProvider.notifier).refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Withdrawal request submitted'),
        backgroundColor: AppColors.successBase,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateMachineProvider);

    // Get balance from FSM
    _availableBalance = walletState.availableBalance;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
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
                  const AppText(
                    'Available Balance',
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.textSecondary,
                  ),
                  walletState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.gold500,
                          ),
                        )
                      : AppText(
                          '\$${walletState.availableBalance.toStringAsFixed(2)}',
                          variant: AppTextVariant.titleMedium,
                          color: AppColors.gold500,
                        ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Amount Input
            _buildAmountCard(),

            const SizedBox(height: AppSpacing.xxl),

            // Withdrawal Method
            const AppText(
              'Withdrawal Method',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),

            ...WithdrawMethod.values.map((method) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _MethodCard(
                    method: method,
                    isSelected: _selectedMethod == method,
                    onTap: () => setState(() => _selectedMethod = method),
                  ),
                )),

            const SizedBox(height: AppSpacing.xxl),

            // Method-specific fields
            if (_selectedMethod != null) _buildMethodFields(),

            const SizedBox(height: AppSpacing.xxl),

            // Submit Button
            AppButton(
              label: 'Withdraw',
              onPressed: _canSubmit() ? _submit : null,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Info
            AppCard(
              variant: AppCardVariant.subtle,
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.gold500, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText(
                      'Withdrawals typically process within 1-3 business days. Fees may apply depending on the method.',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
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

  Widget _buildAmountCard() {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Amount to withdraw',
            variant: AppTextVariant.cardLabel,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                '\$',
                variant: AppTextVariant.displaySmall,
                color: AppColors.textPrimary,
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
                            : AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary,
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
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                label: '50%',
                onTap: () {
                  _amountController.text =
                      (_availableBalance * 0.5).toStringAsFixed(2);
                  _validateAmount();
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                label: '75%',
                onTap: () {
                  _amountController.text =
                      (_availableBalance * 0.75).toStringAsFixed(2);
                  _validateAmount();
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                label: 'MAX',
                onTap: () {
                  _amountController.text =
                      _availableBalance.toStringAsFixed(2);
                  _validateAmount();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodFields() {
    switch (_selectedMethod!) {
      case WithdrawMethod.mobileMoney:
        return _buildMobileMoneyFields();
      case WithdrawMethod.bankTransfer:
        return _buildBankFields();
      case WithdrawMethod.crypto:
        return _buildCryptoFields();
    }
  }

  Widget _buildMobileMoneyFields() {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Mobile Money Number',
            variant: AppTextVariant.cardLabel,
            color: AppColors.textSecondary,
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
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      AppText(
                        _countryCode,
                        variant: AppTextVariant.bodyLarge,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textTertiary,
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
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '07 00 00 00 00',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
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

  Widget _buildBankFields() {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Bank Details',
            variant: AppTextVariant.cardLabel,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _bankNameController,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              labelText: 'Bank Name',
              labelStyle: TextStyle(color: AppColors.textTertiary),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.gold500),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              labelText: 'Account Number',
              labelStyle: TextStyle(color: AppColors.textTertiary),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.gold500),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoFields() {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'USDC Wallet Address',
            variant: AppTextVariant.cardLabel,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _walletAddressController,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: '0x...',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.gold500),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppText(
            'Make sure to use a Solana or Base USDC address',
            variant: AppTextVariant.bodySmall,
            color: AppColors.textTertiary,
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
  });

  final WithdrawMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold500.withValues(alpha: 0.1) : AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.gold500 : Colors.transparent,
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
                    ? AppColors.gold500.withValues(alpha: 0.2)
                    : AppColors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? AppColors.gold500 : AppColors.textSecondary,
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
                    color: isSelected ? AppColors.gold500 : AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    method.description,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.gold500,
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
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: AppText(
              label,
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
