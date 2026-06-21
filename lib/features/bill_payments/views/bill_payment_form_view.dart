import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/index.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/bill_payments/bill_payments_service.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/features/bill_payments/providers/bill_payments_provider.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Bill Payment Form View
/// Account entry, validation, and amount input
class BillPaymentFormView extends ConsumerStatefulWidget {
  const BillPaymentFormView({super.key, required this.providerId});

  final String providerId;

  @override
  ConsumerState<BillPaymentFormView> createState() =>
      _BillPaymentFormViewState();
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
    final selectedProvider = ref.read(selectedBillProviderProvider);
    if (selectedProvider?.id == widget.providerId) {
      setState(() {
        _provider = selectedProvider;
      });
      return;
    }

    final providersAsync = ref.read(
      billProvidersProvider(const BillProvidersParams()),
    );

    providersAsync.whenData((data) {
      if (!mounted) return;
      final provider = _findProvider(data.providers, widget.providerId);
      if (provider != null) {
        setState(() {
          _provider = provider;
        });
      }
    });
  }

  BillProvider? _findProvider(List<BillProvider> providers, String providerId) {
    for (final provider in providers) {
      if (provider.id == providerId) {
        return provider;
      }
    }
    return null;
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
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final validationState = ref.watch(accountValidationProvider);
    final formState = ref.watch(billPaymentFormProvider);
    final walletAsync = ref.watch(walletBalanceProvider);
    final selectedProvider = ref.watch(selectedBillProviderProvider);
    final providersAsync = ref.watch(
      billProvidersProvider(const BillProvidersParams()),
    );
    final provider =
        _provider ??
        (selectedProvider?.id == widget.providerId ? selectedProvider : null) ??
        _findProvider(providersAsync.value?.providers ?? [], widget.providerId);

    if (provider == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.icon),
            onPressed: () => context.fsmPop(),
          ),
        ),
        body: Center(
          child: providersAsync.isLoading
              ? CircularProgressIndicator(color: colors.gold)
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: AppText(
                    l10n.error_notFound,
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText(
          l10n.billPayments_payProvider(provider.shortName, provider.shortName),
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.icon),
          onPressed: () => context.fsmPop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Provider Card
            _buildProviderInfo(provider),
            const SizedBox(height: AppSpacing.xxl),

            // Account Number Field
            _buildAccountField(l10n, provider),
            const SizedBox(height: AppSpacing.lg),

            // Meter Number Field (if required)
            if (provider.requiresMeterNumber) ...[
              _buildMeterField(l10n, provider),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Validation Result
            if (validationState.result != null) ...[
              _buildValidationResult(l10n, validationState.result!),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Validate Button (if not validated)
            if (!formState.isValidated && provider.supportsValidation) ...[
              _buildValidateButton(l10n, provider, validationState.isLoading),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // Amount Field (after validation or if validation not supported)
            if (formState.isValidated || !provider.supportsValidation) ...[
              _buildAmountField(l10n, provider),
              const SizedBox(height: AppSpacing.lg),

              // Fee Display
              _buildFeeDisplay(l10n, provider),
              const SizedBox(height: AppSpacing.lg),

              // Balance Display
              walletAsync.when(
                data: (wallet) => _buildBalanceDisplay(wallet, l10n),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Pay Button
              _buildPayButton(l10n, provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfo(BillProvider provider) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.flat,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.1),
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

  Widget _buildAccountField(AppLocalizations l10n, BillProvider provider) {
    return AppInput(
      controller: _accountController,
      label: provider.accountNumberLabel,
      hint: l10n.billPayments_enterField(
        provider.accountNumberLabel.toLowerCase(),
      ),
      maxLength: provider.accountNumberLength,
      inputFormatters: [
        if (provider.accountNumberLength != null)
          LengthLimitingTextInputFormatter(provider.accountNumberLength),
      ],
      onChanged: (value) {
        ref.read(billPaymentFormProvider.notifier).setAccountNumber(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.billPayments_pleaseEnterField(
            provider.accountNumberLabel.toLowerCase(),
          );
        }
        if (provider.accountNumberLength != null &&
            value.length != provider.accountNumberLength) {
          return l10n.billPayments_fieldMustBeLength(
            provider.accountNumberLabel,
            provider.accountNumberLength!,
          );
        }
        return null;
      },
    );
  }

  Widget _buildMeterField(AppLocalizations l10n, BillProvider provider) {
    return AppInput(
      controller: _meterController,
      label: l10n.billPayments_meterNumber,
      hint: l10n.billPayments_enterMeterNumber,
      onChanged: (value) {
        ref.read(billPaymentFormProvider.notifier).setMeterNumber(value);
      },
      validator: (value) {
        if (provider.requiresMeterNumber && (value == null || value.isEmpty)) {
          return l10n.billPayments_pleaseEnterMeterNumber;
        }
        return null;
      },
    );
  }

  Widget _buildValidateButton(
    AppLocalizations l10n,
    BillProvider provider,
    bool isLoading,
  ) {
    return AppButton(
      label: l10n.billPayments_verifyAccount,
      onPressed: isLoading ? null : () => _validateAccount(provider),
      variant: AppButtonVariant.secondary,
      isLoading: isLoading,
      icon: Icons.verified_user,
    );
  }

  Widget _buildValidationResult(
    AppLocalizations l10n,
    AccountValidationResult result,
  ) {
    final message =
        result.message ??
        (result.isValid
            ? l10n.billPayments_accountVerified
            : l10n.billPayments_verificationFailed);
    final outstanding = result.outstandingBalance == null
        ? null
        : l10n.billPayments_outstanding(
            formatXof(result.outstandingBalance!, showSymbol: false),
            'XOF',
          );

    return InfoCallout(
      icon: result.isValid ? Icons.check_circle : Icons.error,
      tone: result.isValid ? InfoCalloutTone.success : InfoCalloutTone.danger,
      title: result.customerName ?? message,
      body: result.customerName == null
          ? outstanding
          : [message, outstanding].whereType<String>().join(' • '),
    );
  }

  Widget _buildAmountField(AppLocalizations l10n, BillProvider provider) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppInput(
          controller: _amountController,
          label: '${l10n.billPayments_amount} (${provider.currency})',
          hint: '0',
          variant: AppInputVariant.amount,
          suffix: AppText(
            provider.currency,
            variant: AppTextVariant.titleMedium,
            color: colors.textSecondary,
          ),
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0;
            ref.read(billPaymentFormProvider.notifier).setAmount(amount);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.billPayments_pleaseEnterAmount;
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return l10n.billPayments_pleaseEnterValidAmount;
            }
            if (amount < provider.minimumAmount) {
              return l10n.billPayments_minimumAmount(
                provider.minimumAmount.toInt(),
                provider.currency,
              );
            }
            if (amount > provider.maximumAmount) {
              return l10n.billPayments_maximumAmount(
                provider.maximumAmount.toInt(),
                provider.currency,
              );
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          l10n.billPayments_minMaxRange(
            provider.minimumAmount.toInt(),
            provider.maximumAmount.toInt(),
            provider.currency,
          ),
          variant: AppTextVariant.labelSmall,
          color: colors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildFeeDisplay(AppLocalizations l10n, BillProvider provider) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = provider.calculateFee(amount);
    final total = amount + fee;

    return MoneySummaryCard(
      lines: [
        MoneySummaryLine(
          label: l10n.billPayments_amount,
          amount: amount,
          currencyCode: provider.currency,
        ),
        MoneySummaryLine(
          label: l10n.billPayments_processingFee,
          amount: fee,
          currencyCode: provider.currency,
        ),
        MoneySummaryLine(
          label: l10n.billPayments_totalAmount,
          amount: total,
          currencyCode: provider.currency,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildBalanceDisplay(WalletBalance wallet, AppLocalizations l10n) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.account_balance_wallet,
          size: 16,
          color: colors.iconSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        AppText(
          l10n
              .billPayments_available(
                formatCurrency(wallet.available, wallet.currency),
                '',
              )
              .trim(),
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildPayButton(AppLocalizations l10n, BillProvider provider) {
    final formState = ref.watch(billPaymentFormProvider);
    final paymentState = ref.watch(billPaymentProvider);

    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = provider.calculateFee(amount);
    final total = amount + fee;

    return AppButton(
      label: l10n.billPayments_payAmount(
        total.toStringAsFixed(0),
        provider.currency,
      ),
      onPressed: paymentState.isLoading || !formState.isComplete
          ? null
          : () => _confirmPayment(provider),
      isLoading: paymentState.isLoading,
      icon: Icons.payment,
    );
  }

  Future<void> _validateAccount(BillProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(accountValidationProvider.notifier)
        .validate(
          providerId: provider.id,
          accountNumber: _accountController.text,
          meterNumber: _meterController.text.isNotEmpty
              ? _meterController.text
              : null,
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

    final l10n = AppLocalizations.of(context)!;
    String? pinToken;
    final idempotencyKey = generateIdempotencyKey();
    final result = await PinConfirmationSheet.show(
      context: context,
      title: l10n.billPayments_confirmPayment,
      subtitle: l10n.billPayments_enterPinToPay(provider.name, provider.name),
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

    if (result == PinConfirmationResult.success && pinToken != null) {
      await _processPayment(
        provider,
        pinToken: pinToken!,
        idempotencyKey: idempotencyKey,
      );
    }
  }

  Future<void> _processPayment(
    BillProvider provider, {
    required String pinToken,
    required String idempotencyKey,
  }) async {
    final formState = ref.read(billPaymentFormProvider);
    final amount = double.tryParse(_amountController.text) ?? 0;

    final success = await ref
        .read(billPaymentProvider.notifier)
        .payBill(
          providerId: provider.id,
          accountNumber: _accountController.text,
          amount: amount,
          meterNumber: _meterController.text.isNotEmpty
              ? _meterController.text
              : null,
          customerName: formState.customerName,
          currency: provider.currency,
          pinToken: pinToken,
          idempotencyKey: idempotencyKey,
        );

    if (success && mounted) {
      final result = ref.read(billPaymentProvider).result;
      if (result != null) {
        context.fsmGo('/bill-payments/success/${result.paymentId}');
      }
    } else if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      final colors = context.colors;
      final error = ref.read(billPaymentProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? l10n.billPayments_paymentFailed),
          backgroundColor: colors.error,
        ),
      );
    }
  }
}
