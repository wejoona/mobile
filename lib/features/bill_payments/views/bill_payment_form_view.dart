import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../services/bill_payments/bill_payments_service.dart';
import '../../../features/wallet/providers/wallet_provider.dart';
import '../providers/bill_payments_provider.dart';

/// Bill Payment Form View
/// Account entry, validation, and amount input
class BillPaymentFormView extends ConsumerStatefulWidget {
  const BillPaymentFormView({
    super.key,
    required this.providerId,
  });

  final String providerId;

  @override
  ConsumerState<BillPaymentFormView> createState() => _BillPaymentFormViewState();
}

class _BillPaymentFormViewState extends ConsumerState<BillPaymentFormView> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _meterController = TextEditingController();
  final _amountController = TextEditingController();

  BillProvider? _provider;

  @override
  void initState() {
    super.initState();
    // Load provider after first frame to avoid unsafe ref.read()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProvider();
      }
    });
  }

  void _loadProvider() {
    final providersAsync = ref.read(
      billProvidersProvider(const BillProvidersParams()),
    );

    providersAsync.whenData((data) {
      if (!mounted) return;
      final provider = data.providers.firstWhere(
        (p) => p.id == widget.providerId,
        orElse: () => throw Exception('Provider not found'),
      );
      setState(() {
        _provider = provider;
      });
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _meterController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final validationState = ref.watch(accountValidationProvider);
    final formState = ref.watch(billPaymentFormProvider);
    final walletAsync = ref.watch(walletBalanceProvider);

    if (_provider == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: colors.gold),
        ),
      );
    }

    final provider = _provider!;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText(
          'Pay ${provider.shortName}',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Provider Card
            _buildProviderInfo(colors, provider),
            const SizedBox(height: AppSpacing.xxl),

            // Account Number Field
            _buildAccountField(colors, provider),
            const SizedBox(height: AppSpacing.lg),

            // Meter Number Field (if required)
            if (provider.requiresMeterNumber) ...[
              _buildMeterField(colors, provider),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Validation Result
            if (validationState.result != null) ...[
              _buildValidationResult(validationState.result!),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Validate Button (if not validated)
            if (!formState.isValidated && provider.supportsValidation) ...[
              _buildValidateButton(provider, validationState.isLoading),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // Amount Field (after validation or if validation not supported)
            if (formState.isValidated || !provider.supportsValidation) ...[
              _buildAmountField(colors, provider),
              const SizedBox(height: AppSpacing.lg),

              // Fee Display
              _buildFeeDisplay(colors, provider),
              const SizedBox(height: AppSpacing.lg),

              // Balance Display
              walletAsync.when(
                data: (wallet) => _buildBalanceDisplay(colors, wallet.availableBalance),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Pay Button
              _buildPayButton(provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfo(ThemeColors colors, BillProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: AppText(
                provider.shortName.isNotEmpty ? provider.shortName[0] : '?',
                variant: AppTextVariant.titleLarge,
                color: colors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  provider.name,
                  variant: AppTextVariant.titleSmall,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: 4),
                AppText(
                  '${provider.category.displayName} - ${provider.estimatedProcessingTime}',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountField(ThemeColors colors, BillProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          provider.accountNumberLabel,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _accountController,
          style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
          keyboardType: TextInputType.text,
          inputFormatters: [
            if (provider.accountNumberLength != null)
              LengthLimitingTextInputFormatter(provider.accountNumberLength),
          ],
          decoration: InputDecoration(
            hintText: 'Enter ${provider.accountNumberLabel.toLowerCase()}',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: colors.textTertiary,
            ),
            filled: true,
            fillColor: colors.container,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.gold),
            ),
          ),
          onChanged: (value) {
            ref.read(billPaymentFormProvider.notifier).setAccountNumber(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${provider.accountNumberLabel.toLowerCase()}';
            }
            if (provider.accountNumberLength != null &&
                value.length != provider.accountNumberLength) {
              return '${provider.accountNumberLabel} must be ${provider.accountNumberLength} characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMeterField(ThemeColors colors, BillProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Meter Number',
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _meterController,
          style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Enter meter number',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: colors.textTertiary,
            ),
            filled: true,
            fillColor: colors.container,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.gold),
            ),
          ),
          onChanged: (value) {
            ref.read(billPaymentFormProvider.notifier).setMeterNumber(value);
          },
          validator: (value) {
            if (provider.requiresMeterNumber && (value == null || value.isEmpty)) {
              return 'Please enter meter number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildValidateButton(BillProvider provider, bool isLoading) {
    return AppButton(
      label: 'Verify Account',
      onPressed: isLoading ? null : () => _validateAccount(provider),
      variant: AppButtonVariant.secondary,
      isLoading: isLoading,
      icon: Icons.verified_user,
    );
  }

  Widget _buildValidationResult(AccountValidationResult result) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: result.isValid
            ? AppColors.successBase.withOpacity(0.1)
            : AppColors.errorBase.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: result.isValid ? AppColors.successBase : AppColors.errorBase,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            result.isValid ? Icons.check_circle : Icons.error,
            color: result.isValid ? AppColors.successText : AppColors.errorText,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.customerName != null)
                  AppText(
                    result.customerName!,
                    variant: AppTextVariant.bodyMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                AppText(
                  result.message ?? (result.isValid ? 'Account verified' : 'Verification failed'),
                  variant: AppTextVariant.labelMedium,
                  color: result.isValid ? AppColors.successText : AppColors.errorText,
                ),
                if (result.outstandingBalance != null)
                  AppText(
                    'Outstanding: ${result.outstandingBalance!.toStringAsFixed(0)} XOF',
                    variant: AppTextVariant.labelSmall,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(ThemeColors colors, BillProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Amount (${provider.currency})',
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _amountController,
          style: AppTypography.headlineMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: AppTypography.headlineMedium.copyWith(
              color: colors.textTertiary,
            ),
            filled: true,
            fillColor: colors.container,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.gold),
            ),
            suffixText: provider.currency,
            suffixStyle: AppTypography.titleMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0;
            ref.read(billPaymentFormProvider.notifier).setAmount(amount);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount < provider.minimumAmount) {
              return 'Minimum amount is ${provider.minimumAmount.toInt()} ${provider.currency}';
            }
            if (amount > provider.maximumAmount) {
              return 'Maximum amount is ${provider.maximumAmount.toInt()} ${provider.currency}';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          'Min: ${provider.minimumAmount.toInt()} - Max: ${provider.maximumAmount.toInt()} ${provider.currency}',
          variant: AppTextVariant.labelSmall,
          color: colors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildFeeDisplay(ThemeColors colors, BillProvider provider) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = provider.calculateFee(amount);
    final total = amount + fee;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          _buildFeeRow(colors, 'Amount', '${amount.toStringAsFixed(0)} ${provider.currency}'),
          const SizedBox(height: AppSpacing.sm),
          _buildFeeRow(colors, 'Processing Fee', '${fee.toStringAsFixed(0)} ${provider.currency}'),
          Divider(color: colors.borderSubtle, height: AppSpacing.lg),
          _buildFeeRow(
            colors,
            'Total',
            '${total.toStringAsFixed(0)} ${provider.currency}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(ThemeColors colors, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: isTotal ? AppTextVariant.bodyMedium : AppTextVariant.labelMedium,
          color: isTotal ? colors.textPrimary : colors.textSecondary,
          fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
        ),
        AppText(
          value,
          variant: isTotal ? AppTextVariant.bodyMedium : AppTextVariant.labelMedium,
          color: isTotal ? colors.gold : colors.textPrimary,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
        ),
      ],
    );
  }

  Widget _buildBalanceDisplay(ThemeColors colors, double balance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.account_balance_wallet,
          size: 16,
          color: colors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        AppText(
          'Available: \$${balance.toStringAsFixed(2)} USD',
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildPayButton(BillProvider provider) {
    final formState = ref.watch(billPaymentFormProvider);
    final paymentState = ref.watch(billPaymentProvider);

    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = provider.calculateFee(amount);
    final total = amount + fee;

    return AppButton(
      label: 'Pay ${total.toStringAsFixed(0)} ${provider.currency}',
      onPressed: paymentState.isLoading || !formState.isComplete
          ? null
          : () => _confirmPayment(provider),
      isLoading: paymentState.isLoading,
      icon: Icons.payment,
    );
  }

  Future<void> _validateAccount(BillProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(accountValidationProvider.notifier).validate(
      providerId: provider.id,
      accountNumber: _accountController.text,
      meterNumber: _meterController.text.isNotEmpty ? _meterController.text : null,
    );

    if (success) {
      final result = ref.read(accountValidationProvider).result;
      if (result != null) {
        ref.read(billPaymentFormProvider.notifier).setValidationResult(result);
      }
    }
  }

  Future<void> _confirmPayment(BillProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final result = await PinConfirmationSheet.show(
      context: context,
      title: 'Confirm Payment',
      subtitle: 'Enter your PIN to pay ${provider.name}',
      onConfirm: (pin) async {
        // Verify PIN with server
        // TODO: Implement actual PIN verification
        return pin.length == 4;
      },
    );

    if (result == PinConfirmationResult.success) {
      await _processPayment(provider);
    }
  }

  Future<void> _processPayment(BillProvider provider) async {
    final formState = ref.read(billPaymentFormProvider);
    final amount = double.tryParse(_amountController.text) ?? 0;

    final success = await ref.read(billPaymentProvider.notifier).payBill(
      providerId: provider.id,
      accountNumber: _accountController.text,
      amount: amount,
      meterNumber: _meterController.text.isNotEmpty ? _meterController.text : null,
      customerName: formState.customerName,
      currency: provider.currency,
    );

    if (success && mounted) {
      final result = ref.read(billPaymentProvider).result;
      if (result != null) {
        context.go('/bill-payments/success/${result.paymentId}');
      }
    } else if (mounted) {
      final error = ref.read(billPaymentProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Payment failed'),
          backgroundColor: AppColors.errorBase,
        ),
      );
    }
  }
}
