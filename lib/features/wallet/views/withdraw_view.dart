import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/design/components/composed/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/withdraw_provider.dart'
    as withdraw_api;
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';
import 'package:usdc_wallet/services/index.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/utils/context_extensions.dart';

/// Withdrawal method type
enum WithdrawMethod { mobileMoney, bankTransfer, crypto }

extension WithdrawMethodExt on WithdrawMethod {
  String label(AppLocalizations l10n) {
    switch (this) {
      case WithdrawMethod.mobileMoney:
        return l10n.withdraw_mobileMoney;
      case WithdrawMethod.bankTransfer:
        return l10n.withdraw_bankTransfer;
      case WithdrawMethod.crypto:
        return l10n.withdraw_crypto;
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

  String description(AppLocalizations l10n) {
    switch (this) {
      case WithdrawMethod.mobileMoney:
        return l10n.withdraw_mobileMoneyDesc;
      case WithdrawMethod.bankTransfer:
        return l10n.withdraw_bankDesc;
      case WithdrawMethod.crypto:
        return l10n.withdraw_cryptoDesc;
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
    if (_requiresAvailabilitySubscription()) return true;
    if (_amountController.text.isEmpty) return false;
    if (_amountError != null) return false;

    switch (_selectedMethod!) {
      case WithdrawMethod.mobileMoney:
        final country = _effectiveCountry(ref);
        if (country.code != 'CI') return true;
        final localDigits = _localPhoneDigits(country);
        return country.code == 'CI' && country.isValidLength(localDigits);
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
    final selectedCountry = _effectiveCountry(ref, watch: false);
    if (_selectedMethod == WithdrawMethod.bankTransfer) {
      await _subscribeToWithdrawalAvailability(
        featureKey: _withdrawalFeatureKey(selectedCountry, _selectedMethod!),
        requestedFeature: _selectedMethod!.name,
        country: selectedCountry,
      );
      return;
    }
    if (_selectedMethod == WithdrawMethod.mobileMoney &&
        selectedCountry.code != 'CI') {
      await _subscribeToWithdrawalAvailability(
        featureKey: _withdrawalFeatureKey(selectedCountry, _selectedMethod!),
        requestedFeature: 'mobile_money',
        country: selectedCountry,
      );
      return;
    }

    final localDigits = _selectedMethod == WithdrawMethod.mobileMoney
        ? _localPhoneDigits(selectedCountry)
        : '';
    final mobileMoneyMethod = _selectedMethod == WithdrawMethod.mobileMoney
        ? _methodForCiMobileNumber(localDigits)
        : null;
    if (_selectedMethod == WithdrawMethod.mobileMoney &&
        mobileMoneyMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'This mobile money number is not supported yet. Use Orange, MTN, or Moov CI.',
          ),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    String destination = '';
    String recipientDisplay = '';

    // Build destination and display based on method
    switch (_selectedMethod!) {
      case WithdrawMethod.mobileMoney:
        destination = '${selectedCountry.fullPrefix}$localDigits';
        recipientDisplay = destination;
        break;
      case WithdrawMethod.bankTransfer:
        destination = _accountNumberController.text;
        recipientDisplay =
            '${_bankNameController.text} - ${_accountNumberController.text}';
        break;
      case WithdrawMethod.crypto:
        destination = _walletAddressController.text;
        recipientDisplay =
            '${destination.substring(0, 6)}...${destination.substring(destination.length - 4)}';
        break;
    }

    String? pinToken;

    // Show PIN confirmation
    final result = await PinConfirmationSheet.show(
      context: context,
      title: AppStrings.confirmWithdrawal,
      subtitle: AppStrings.enterPinToWithdraw,
      amount: amount,
      recipient: recipientDisplay,
      onConfirm: (pin) async {
        // Verify PIN with backend for financial transactions
        final pinService = ref.read(pinServiceProvider);
        final verification = await pinService.verifyPinWithBackend(pin);
        if (verification.success && verification.pinToken != null) {
          pinToken = verification.pinToken;
        }
        return verification.success;
      },
    );

    if (result == PinConfirmationResult.success) {
      if (pinToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.enterPinToWithdraw),
              backgroundColor: context.colors.error,
            ),
          );
        }
        return;
      }

      setState(() => _isSubmitting = true);

      final success = _selectedMethod == WithdrawMethod.crypto
          ? await _submitCryptoWithdrawal(
              amount: amount,
              destinationAddress: destination,
              pinToken: pinToken!,
            )
          : await _submitMobileMoneyWithdrawal(
              amount: amount,
              destination: destination,
              method: mobileMoneyMethod!,
              pinToken: pinToken!,
            );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (success) {
        // Refresh wallet and transactions via FSM
        unawaited(ref.read(walletStateMachineProvider.notifier).refresh());
        unawaited(ref.read(transactionStateMachineProvider.notifier).refresh());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.withdrawalSubmitted),
            backgroundColor: context.colors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        // Error is handled by listener
        if (mounted && _selectedMethod != WithdrawMethod.crypto) {
          final error = ref.read(withdraw_api.withdrawProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error ?? AppLocalizations.of(context)!.withdraw_failed,
              ),
              backgroundColor: context.colors.error,
            ),
          );
        }
      }
    } else if (result == PinConfirmationResult.failed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.common_tooManyAttempts),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  Future<bool> _submitMobileMoneyWithdrawal({
    required double amount,
    required String destination,
    required withdraw_api.WithdrawMethod method,
    required String pinToken,
  }) async {
    final notifier = ref.read(withdraw_api.withdrawProvider.notifier)
      ..selectMethod(method)
      ..setPhoneNumber(destination);
    await notifier.setAmount(amount);
    await notifier.submit(
      pinToken: pinToken,
      idempotencyKey: generateIdempotencyKey(),
    );

    return ref.read(withdraw_api.withdrawProvider).result != null;
  }

  Future<bool> _submitCryptoWithdrawal({
    required double amount,
    required String destinationAddress,
    required String pinToken,
  }) async {
    try {
      final response = await ref
          .read(walletServiceProvider)
          .withdraw(
            amount: amount,
            destinationAddress: destinationAddress,
            network: 'polygon',
            pinToken: pinToken,
            idempotencyKey: generateIdempotencyKey(),
          );
      return response.transactionId.isNotEmpty;
    } catch (e) {
      ref.read(withdraw_api.withdrawProvider.notifier).reset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: context.colors.error,
          ),
        );
      }
      return false;
    }
  }

  String _localPhoneDigits(CountryConfig country) {
    final digitsOnly = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.startsWith(country.prefix)
        ? digitsOnly.substring(country.prefix.length)
        : digitsOnly;
  }

  withdraw_api.WithdrawMethod? _methodForCiMobileNumber(String localDigits) {
    if (localDigits.startsWith('07')) {
      return withdraw_api.WithdrawMethod.orangeMoney;
    }
    if (localDigits.startsWith('05')) {
      return withdraw_api.WithdrawMethod.mtnMomo;
    }
    if (localDigits.startsWith('01')) {
      return withdraw_api.WithdrawMethod.moovMoney;
    }
    if (localDigits.startsWith('27')) {
      return withdraw_api.WithdrawMethod.wave;
    }
    return null;
  }

  bool _requiresAvailabilitySubscription() {
    final method = _selectedMethod;
    if (method == null) return false;
    if (method == WithdrawMethod.crypto) return false;
    if (method != WithdrawMethod.mobileMoney) return true;
    return _effectiveCountry(ref).code != 'CI';
  }

  Future<void> _subscribeToWithdrawalAvailability({
    required String featureKey,
    required String requestedFeature,
    required CountryConfig country,
  }) async {
    setState(() => _isSubmitting = true);
    final authState = ref.read(authProvider);
    final user = authState.user;
    try {
      await ref
          .read(featureSubscriptionServiceProvider)
          .subscribe(
            FeatureSubscriptionRequest(
              featureKey: featureKey,
              source: 'withdrawal_screen',
              phone: user?.phone ?? authState.phone,
              email: user?.email,
              featureName: 'Korido withdrawals',
              requestedFeature: requestedFeature,
              countryCode: country.code,
              locale: user?.preferredLocale,
              metadata: {
                'surface': 'withdrawal_screen',
                'method': _selectedMethod?.name,
                'countryCode': country.code,
                'currency': country.primaryCurrency,
              },
            ),
          );
      if (!mounted) return;
      context.showSnack(
        AppLocalizations.of(context)!.withdraw_notifySuccess,
        tone: AppSnackTone.success,
      );
    } catch (e) {
      if (!mounted) return;
      context.showSnack(
        AppLocalizations.of(context)!.common_errorFormat(e.toString()),
        tone: AppSnackTone.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final walletState = ref.watch(walletStateMachineProvider);
    final withdrawState = ref.watch(withdraw_api.withdrawProvider);

    // Withdrawals are submitted in USDC, so validate against USDC balance.
    _availableBalance = walletState.usdcBalance;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.navigation_withdraw,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
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
                    l10n.wallet_availableBalance,
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                  ),
                  walletState.isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.gold,
                          ),
                        )
                      : AppText(
                          '${walletState.usdcBalance.toStringAsFixed(2)} USDC',
                          variant: AppTextVariant.titleMedium,
                          color: context.colors.gold,
                        ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Amount Input
            _buildAmountCard(colors, l10n),

            const SizedBox(height: AppSpacing.xxl),

            // Withdrawal Method
            AppText(
              l10n.withdraw_method,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),

            ...WithdrawMethod.values.map(
              (method) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _MethodCard(
                  method: method,
                  isSelected: _selectedMethod == method,
                  onTap: () => setState(() => _selectedMethod = method),
                  colors: colors,
                  l10n: l10n,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Method-specific fields
            if (_selectedMethod != null) _buildMethodFields(colors, l10n),

            const SizedBox(height: AppSpacing.xxl),

            // Submit Button
            AppButton(
              label: _requiresAvailabilitySubscription()
                  ? l10n.deposit_notifyWhenAvailable
                  : l10n.navigation_withdraw,
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
                  Icon(
                    Icons.info_outline,
                    color: context.colors.gold,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText(
                      // ignore: dead_code
                      l10n.withdraw_processingInfo ??
                          // ignore: dead_null_aware_expression
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

  Widget _buildAmountCard(ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.withdraw_amountLabel,
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
                    AppInput(
                      controller: _amountController,
                      variant: AppInputVariant.amount,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      error: _amountError,
                      onChanged: (_) => _validateAmount(),
                    ),
                    if (_amountError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: AppText(
                          _amountError!,
                          variant: AppTextVariant.bodySmall,
                          color: context.colors.error,
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
                  _amountController.text = (_availableBalance * 0.25)
                      .toStringAsFixed(2);
                  _validateAmount();
                },
                colors: colors,
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                label: '50%',
                onTap: () {
                  _amountController.text = (_availableBalance * 0.5)
                      .toStringAsFixed(2);
                  _validateAmount();
                },
                colors: colors,
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                label: '75%',
                onTap: () {
                  _amountController.text = (_availableBalance * 0.75)
                      .toStringAsFixed(2);
                  _validateAmount();
                },
                colors: colors,
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                label: 'MAX',
                onTap: () {
                  _amountController.text = _availableBalance.toStringAsFixed(2);
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

  Widget _buildMethodFields(ThemeColors colors, AppLocalizations l10n) {
    switch (_selectedMethod!) {
      case WithdrawMethod.mobileMoney:
        return _buildMobileMoneyFields(colors, l10n);
      case WithdrawMethod.bankTransfer:
        return _buildBankFields(colors, l10n);
      case WithdrawMethod.crypto:
        return _buildCryptoFields(colors, l10n);
    }
  }

  Widget _buildMobileMoneyFields(ThemeColors colors, AppLocalizations l10n) {
    final selectedCountry = _effectiveCountry(ref);
    final isMobileMoneyAvailable = selectedCountry.code == 'CI';

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.withdraw_mobileNumber,
            variant: AppTextVariant.cardLabel,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
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
                      selectedCountry.fullPrefix,
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppText(
                      selectedCountry.code,
                      variant: AppTextVariant.labelSmall,
                      color: colors.textTertiary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppInput(
                  controller: _phoneController,
                  variant: AppInputVariant.phone,
                  hint: selectedCountry.phoneFormat ?? '07 00 00 00 00',
                  keyboardType: TextInputType.phone,
                  enabled: isMobileMoneyAvailable,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          if (!isMobileMoneyAvailable) ...[
            const SizedBox(height: AppSpacing.md),
            AppText(
              "Mobile money withdrawals are currently available for Côte d'Ivoire accounts.",
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBankFields(ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.withdraw_bankDetails,
            variant: AppTextVariant.cardLabel,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            controller: _bankNameController,
            label: 'Bank Name',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            controller: _accountNumberController,
            label: 'Account Number',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoFields(ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.withdraw_walletAddress,
            variant: AppTextVariant.cardLabel,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            controller: _walletAddressController,
            hint: '0x...',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.withdraw_networkWarning,
            variant: AppTextVariant.bodySmall,
            color: colors.textTertiary,
          ),
        ],
      ),
    );
  }
}

CountryConfig _effectiveCountry(WidgetRef ref, {bool watch = true}) {
  final selectedCountry = watch
      ? ref.watch(selectedCountryProvider)
      : ref.read(selectedCountryProvider);
  final countryCodeProvider = userStateMachineProvider.select(
    (state) => state.countryCode,
  );
  final userCountryCode = watch
      ? ref.watch(countryCodeProvider)
      : ref.read(countryCodeProvider);
  return SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
}

String _withdrawalFeatureKey(CountryConfig country, WithdrawMethod method) {
  return 'withdrawal_${country.code.toLowerCase()}_${method.name}';
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
    required this.colors,
    required this.l10n,
  });

  final WithdrawMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.gold.withValues(alpha: 0.1)
              : context.colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? context.colors.gold : Colors.transparent,
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
                    ? context.colors.gold.withValues(alpha: 0.2)
                    : context.colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? context.colors.gold : colors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    method.label(l10n),
                    variant: AppTextVariant.titleSmall,
                    color: isSelected
                        ? context.colors.gold
                        : colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    method.description(l10n),
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: context.colors.gold),
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
