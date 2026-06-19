import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:usdc_wallet/providers/missing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Deposit Amount Screen
class DepositAmountScreen extends ConsumerStatefulWidget {
  const DepositAmountScreen({super.key});

  @override
  ConsumerState<DepositAmountScreen> createState() =>
      _DepositAmountScreenState();
}

class _DepositAmountScreenState extends ConsumerState<DepositAmountScreen> {
  final _amountController = TextEditingController();
  bool _isXOF = true; // Toggle between XOF and USD
  bool _currencyInitialized = false;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(limitsProvider.notifier).fetchLimits());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final country = _effectiveCountry(ref);
    final exchangeRateAsync = ref.watch(exchangeRateProvider);
    final transactionLimits = ref.watch(limitsProvider).limits;

    if (!_currencyInitialized) {
      _isXOF = country.primaryCurrency == 'XOF';
      _currencyInitialized = true;
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(l10n.deposit_title, variant: AppTextVariant.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.fsmPop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exchange Rate Card
                      exchangeRateAsync.when(
                        data: (rate) =>
                            _buildExchangeRateCard(rate, colors, l10n),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Amount Input Card
                      exchangeRateAsync.when(
                        data: (rate) => _buildAmountCard(
                          rate,
                          colors,
                          l10n,
                          country,
                          transactionLimits,
                        ),
                        loading: () => _buildLoadingCard(colors, l10n),
                        error: (err, _) => _buildRateErrorCard(colors, l10n),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Quick Amount Buttons
                      AppText(
                        l10n.deposit_quickAmounts,
                        variant: AppTextVariant.labelMedium,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      exchangeRateAsync.when(
                        data: (rate) =>
                            _buildQuickAmounts(rate, colors, country),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Min/Max Info
                      _buildLimitsInfo(
                        colors,
                        l10n,
                        country,
                        exchangeRateAsync.value,
                        transactionLimits,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Continue Button
              exchangeRateAsync.when(
                data: (rate) => AppButton(
                  label: l10n.action_continue,
                  onPressed: _canContinue(rate, country, transactionLimits)
                      ? () => _handleContinue(rate)
                      : null,
                  isFullWidth: true,
                ),
                loading: () => AppButton(
                  label: l10n.action_continue,
                  onPressed: null,
                  isFullWidth: true,
                ),
                error: (_, __) => AppButton(
                  label: l10n.action_continue,
                  onPressed: null,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeRateCard(
    ExchangeRate rate,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    if (!_isXOF) {
      return AppCard(
        variant: AppCardVariant.elevated,
        child: Row(
          children: [
            Icon(Icons.currency_exchange, color: colors.gold, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(
                l10n.deposit_rateUsdUsdc,
                variant: AppTextVariant.bodyMedium,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Row(
        children: [
          Icon(Icons.currency_exchange, color: colors.gold, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.deposit_rateUsdToCurrency(
                    rate.rate.toStringAsFixed(2),
                    rate.fromCurrency,
                  ),
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
                AppText(
                  l10n.deposit_rateUpdated(
                    _formatTimestamp(rate.timestamp, l10n),
                    rate.timestamp,
                  ),
                  variant: AppTextVariant.bodySmall,
                  color: colors.textTertiary,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: colors.textSecondary),
            onPressed: () => ref.refresh(exchangeRateProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(
    ExchangeRate rate,
    ThemeColors colors,
    AppLocalizations l10n,
    CountryConfig country,
    TransactionLimits? transactionLimits,
  ) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final convertedAmount = _isXOF ? rate.convert(amount) : amount;
    final currencies = country.supportedDepositCurrencies
        .where((currency) => currency == 'XOF' || currency == 'USD')
        .toList();

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currency Toggle
          Row(
            children: [
              for (final currency in currencies) ...[
                _CurrencyTab(
                  label: currency,
                  isSelected: _currency == currency,
                  onTap: () => _selectCurrency(currency == 'XOF', rate),
                  colors: colors,
                ),
                if (currency != currencies.last)
                  const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Amount Input
          Row(
            children: [
              AppText(
                _currency,
                variant: AppTextVariant.titleLarge,
                color: colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppInput(
                  controller: _amountController,
                  variant: AppInputVariant.amount,
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  error: _amountError,
                  onChanged: (_) => _validateAmount(rate, transactionLimits),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          Divider(color: colors.borderSubtle, height: 1),
          const SizedBox(height: AppSpacing.lg),

          // Conversion Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  l10n.deposit_youWillReceive,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: AmountText.fromText(
                    formatUsdc(convertedAmount),
                    size: AmountTextSize.small,
                    color: colors.gold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts(
    ExchangeRate rate,
    ThemeColors colors,
    CountryConfig country,
  ) {
    final amounts = _quickAmounts(country);

    return Row(
      children: amounts.map((amount) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: amount != amounts.last ? AppSpacing.sm : 0,
            ),
            child: _QuickAmountButton(
              amount: amount,
              currency: _currency,
              onTap: () => _setAmount(amount, rate),
              colors: colors,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLimitsInfo(
    ThemeColors colors,
    AppLocalizations l10n,
    CountryConfig country,
    ExchangeRate? rate,
    TransactionLimits? transactionLimits,
  ) {
    final limits = _limits(country, rate, transactionLimits);
    return AppCard(
      variant: AppCardVariant.flat,
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colors.textTertiary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.deposit_limits,
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                AppText(
                  l10n.deposit_limitRange(
                    _formatAmount(limits.$1, _currency),
                    _formatAmount(limits.$2, _currency),
                  ),
                  variant: AppTextVariant.bodySmall,
                  color: colors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(color: colors.gold),
        ),
      ),
    );
  }

  Widget _buildRateErrorCard(ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_problem, color: colors.errorText, size: 28),
          const SizedBox(height: AppSpacing.md),
          AppText(
            l10n.common_errorTryAgain,
            variant: AppTextVariant.bodyMedium,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.action_retry,
            onPressed: () => ref.invalidate(exchangeRateProvider),
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  void _selectCurrency(bool isXof, ExchangeRate rate) {
    if (_isXOF == isXof) return;

    setState(() {
      _isXOF = isXof;
      _amountError = _validationErrorFor(rate, ref.read(limitsProvider).limits);
    });
  }

  String? _validationErrorFor(
    ExchangeRate rate,
    TransactionLimits? transactionLimits,
  ) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final country = _effectiveCountry(ref);
    final limits = _limits(country, rate, transactionLimits);

    if (_amountController.text.isEmpty) {
      return null;
    } else if (amount < limits.$1) {
      return AppLocalizations.of(
        context,
      )!.deposit_minimumAmount(_formatAmount(limits.$1, _currency));
    } else if (amount > limits.$2) {
      return AppLocalizations.of(
        context,
      )!.deposit_maximumAmount(_formatAmount(limits.$2, _currency));
    }

    return null;
  }

  void _validateAmount(
    ExchangeRate rate,
    TransactionLimits? transactionLimits,
  ) {
    setState(() {
      _amountError = _validationErrorFor(rate, transactionLimits);
    });
  }

  void _setAmount(double amount, ExchangeRate rate) {
    _amountController.text = amount.toStringAsFixed(_isXOF ? 0 : 2);
    _validateAmount(rate, ref.read(limitsProvider).limits);
  }

  bool _canContinue(
    ExchangeRate rate,
    CountryConfig country,
    TransactionLimits? transactionLimits,
  ) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (!country.supportedDepositCurrencies.contains(_currency)) return false;
    return amount > 0 && _validationErrorFor(rate, transactionLimits) == null;
  }

  void _handleContinue(ExchangeRate rate) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final countryCode = _effectiveCountry(ref).code;
    if (_isXOF) {
      ref
          .read(depositProvider.notifier)
          .setAmountXOF(amount, rate, countryCode);
    } else {
      ref
          .read(depositProvider.notifier)
          .setAmountUSD(amount, rate, countryCode);
    }
    unawaited(context.fsmPush('/deposit/provider'));
  }

  String get _currency => _isXOF ? 'XOF' : 'USD';

  (double, double) _limits(
    CountryConfig country,
    ExchangeRate? rate,
    TransactionLimits? transactionLimits,
  ) {
    final policyMaxUsdc = transactionLimits?.effectiveMaxFor(
      TransactionLimitOperation.deposit,
    );
    final apiMax = policyMaxUsdc != null && policyMaxUsdc > 0
        ? _isXOF
              ? rate?.convertBack(policyMaxUsdc)
              : policyMaxUsdc
        : null;

    if (_isXOF) {
      return (
        country.minDepositAmount,
        _minPositive(country.maxDepositAmount, apiMax),
      );
    }
    if (country.primaryCurrency == 'XOF' && rate != null) {
      return (
        rate.convert(country.minDepositAmount),
        _minPositive(rate.convert(country.maxDepositAmount), apiMax),
      );
    }
    return (
      country.minDepositAmount,
      _minPositive(country.maxDepositAmount, apiMax),
    );
  }

  double _minPositive(double fallback, double? cap) {
    if (cap == null || cap <= 0) return fallback;
    return cap < fallback ? cap : fallback;
  }

  List<double> _quickAmounts(CountryConfig country) {
    if (_isXOF || country.primaryCurrency == 'USD') {
      return country.quickDepositAmounts;
    }
    return const [10, 20, 50, 100];
  }

  String _formatAmount(double amount, [String? currency]) {
    if ((currency ?? _currency) == 'USD') {
      return '\$${amount.toStringAsFixed(amount >= 100 ? 0 : 2)}';
    }
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '${amount.toStringAsFixed(0)} XOF';
  }

  String _formatTimestamp(DateTime timestamp, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return l10n.deposit_timeJustNow;
    if (diff.inMinutes < 60) return l10n.deposit_timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.deposit_timeHoursAgo(diff.inHours);
    return l10n.deposit_timeDaysAgo(diff.inDays);
  }
}

class _CurrencyTab extends StatelessWidget {
  const _CurrencyTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold : colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? colors.gold : colors.borderSubtle,
          ),
        ),
        child: AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: isSelected ? colors.onGold : colors.textSecondary,
        ),
      ),
    );
  }
}

CountryConfig _effectiveCountry(WidgetRef ref) {
  final selectedCountry = ref.watch(selectedCountryProvider);
  final userCountryCode = ref.watch(
    userStateMachineProvider.select((state) => state.countryCode),
  );
  return SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
}

class _QuickAmountButton extends StatelessWidget {
  const _QuickAmountButton({
    required this.amount,
    required this.currency,
    required this.onTap,
    required this.colors,
  });

  final double amount;
  final String currency;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    String label;
    if (currency == 'XOF') {
      if (amount >= 1000) {
        label = '${(amount / 1000).toStringAsFixed(0)}K';
      } else {
        label = amount.toStringAsFixed(0);
      }
    } else {
      label = '\$${amount.toStringAsFixed(0)}';
    }

    return AppCard(
      variant: AppCardVariant.flat,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      borderRadius: AppRadius.md,
      onTap: onTap,
      child: Center(
        child: AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}
