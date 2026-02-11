import 'package:usdc_wallet/providers/missing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';

/// Deposit Amount Screen
class DepositAmountScreen extends ConsumerStatefulWidget {
  const DepositAmountScreen({super.key});

  @override
  ConsumerState<DepositAmountScreen> createState() => _DepositAmountScreenState();
}

class _DepositAmountScreenState extends ConsumerState<DepositAmountScreen> {
  final _amountController = TextEditingController();
  bool _isXOF = true; // Toggle between XOF and USD
  String? _amountError;

  // Limits
  static const double _minXOF = 500;
  static const double _maxXOF = 5000000;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final exchangeRateAsync = ref.watch(exchangeRateProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.deposit_title,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exchange Rate Card
                      exchangeRateAsync.when(
                        data: (rate) => _buildExchangeRateCard(rate, colors, l10n),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Amount Input Card
                      exchangeRateAsync.when(
                        data: (rate) => _buildAmountCard(rate, colors, l10n),
                        loading: () => _buildLoadingCard(colors, l10n),
                        error: (err, _) => _buildErrorCard(colors, l10n),
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
                        data: (rate) => _buildQuickAmounts(rate, colors),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Min/Max Info
                      _buildLimitsInfo(colors, l10n),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Continue Button
              exchangeRateAsync.when(
                data: (rate) => AppButton(
                  label: l10n.action_continue,
                  onPressed: _canContinue() ? () => _handleContinue(rate) : null,
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

  Widget _buildExchangeRateCard(ExchangeRate rate, ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Row(
        children: [
          Icon(
            Icons.currency_exchange,
            color: colors.gold,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '1 USD = ${rate.rate.toStringAsFixed(2)} XOF',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
                AppText(
                  l10n.deposit_rateUpdated(
                    _formatTimestamp(rate.timestamp),
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

  Widget _buildAmountCard(ExchangeRate rate, ThemeColors colors, AppLocalizations l10n) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final convertedAmount = _isXOF ? rate.convert(amount) : rate.convertBack(amount);

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currency Toggle
          Row(
            children: [
              _CurrencyTab(
                label: 'XOF',
                isSelected: _isXOF,
                onTap: () => setState(() => _isXOF = true),
                colors: colors,
              ),
              const SizedBox(width: AppSpacing.sm),
              _CurrencyTab(
                label: 'USD',
                isSelected: !_isXOF,
                onTap: () => setState(() => _isXOF = false),
                colors: colors,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Amount Input
          Row(
            children: [
              AppText(
                _isXOF ? 'XOF' : 'USD',
                variant: AppTextVariant.titleLarge,
                color: colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: AppTypography.displaySmall.copyWith(
                    color: _amountError != null ? colors.error : colors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: colors.textTertiary),
                  ),
                  onChanged: (_) => _validateAmount(rate),
                ),
              ),
            ],
          ),

          if (_amountError != null) ...[
            const SizedBox(height: AppSpacing.xs),
            AppText(
              _amountError!,
              variant: AppTextVariant.bodySmall,
              color: colors.errorText,
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
          Divider(color: colors.borderSubtle, height: 1),
          const SizedBox(height: AppSpacing.lg),

          // Conversion Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                _isXOF ? l10n.deposit_youWillReceive : l10n.deposit_youWillPay,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
              AppText(
                _isXOF
                    ? '\$${convertedAmount.toStringAsFixed(2)}'
                    : '${convertedAmount.toStringAsFixed(0)} XOF',
                variant: AppTextVariant.titleMedium,
                color: colors.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts(ExchangeRate rate, ThemeColors colors) {
    final amounts = _isXOF
        ? [5000.0, 10000.0, 25000.0, 50000.0]
        : [10.0, 20.0, 50.0, 100.0];

    return Row(
      children: amounts.map((amount) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: amount != amounts.last ? AppSpacing.sm : 0,
            ),
            child: _QuickAmountButton(
              amount: amount,
              currency: _isXOF ? 'XOF' : 'USD',
              onTap: () => _setAmount(amount, rate),
              colors: colors,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLimitsInfo(ThemeColors colors, AppLocalizations l10n) {
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
                  'Min: ${_formatAmount(_minXOF)} XOF • Max: ${_formatAmount(_maxXOF)} XOF',
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

  Widget _buildErrorCard(ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Center(
        child: AppText(
          l10n.common_error,
          variant: AppTextVariant.bodyMedium,
          color: AppColors.errorText,
        ),
      ),
    );
  }

  void _validateAmount(ExchangeRate rate) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final amountXOF = _isXOF ? amount : rate.convertBack(amount);

    setState(() {
      if (_amountController.text.isEmpty) {
        _amountError = null;
      } else if (amountXOF < _minXOF) {
        _amountError = 'Minimum ${_formatAmount(_minXOF)} XOF';
      } else if (amountXOF > _maxXOF) {
        _amountError = 'Maximum ${_formatAmount(_maxXOF)} XOF';
      } else {
        _amountError = null;
      }
    });
  }

  void _setAmount(double amount, ExchangeRate rate) {
    _amountController.text = amount.toStringAsFixed(_isXOF ? 0 : 2);
    _validateAmount(rate);
  }

  bool _canContinue() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount > 0 && _amountError == null;
  }

  void _handleContinue(ExchangeRate rate) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_isXOF) {
      ref.read(depositProvider.notifier).setAmountXOF(amount, rate);
    } else {
      ref.read(depositProvider.notifier).setAmountUSD(amount, rate);
    }
    context.push('/deposit/provider');
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
        ),
        child: AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: isSelected ? colors.textInverse : colors.textSecondary,
        ),
      ),
    );
  }
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Center(
          child: AppText(
            label,
            variant: AppTextVariant.labelMedium,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
