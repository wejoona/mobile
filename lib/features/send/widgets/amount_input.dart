import 'package:flutter/material.dart';
import 'package:usdc_wallet/config/fee_schedule.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/utils/input_formatters.dart';

/// Approximate USDC to XOF rate (1 USDC ~= 600 XOF).
/// In production this should come from the exchange rate provider.
const double _defaultUsdcToXofRate = 600;

/// Amount input widget with fee preview, balance check, and XOF conversion.
class AmountInput extends StatelessWidget {
  const AmountInput({
    super.key,
    required this.controller,
    required this.availableBalance,
    this.currency = 'USDC',
    this.transferType,
    this.onChanged,
    this.exchangeRate,
  });

  final TextEditingController controller;
  final double availableBalance;
  final String currency;
  final String? transferType;
  final ValueChanged<String>? onChanged;

  /// USDC -> XOF exchange rate. Falls back to approximate rate.
  final double? exchangeRate;

  double get _rate => exchangeRate ?? _defaultUsdcToXofRate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppText(
          'Solde disponible',
          variant: AppTextVariant.bodySmall,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xxs),
        AmountText.fromText(
          formatCurrency(availableBalance, currency),
          size: AmountTextSize.small,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.xxs),
        AppText(
          '~ ${formatXof(availableBalance * _rate)}',
          variant: AppTextVariant.bodySmall,
          color: colors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: AppText(
                r'$',
                variant: AppTextVariant.moneyLarge,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IntrinsicWidth(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  AmountInputFormatter(maxAmount: availableBalance),
                ],
                style: AppTypography.moneyDisplay.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: AppTypography.moneyDisplay.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                textAlign: TextAlign.center,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, child) {
            final amount = double.tryParse(value.text) ?? 0;
            if (amount <= 0) {
              return const SizedBox.shrink();
            }

            return AppText(
              '~ ${formatXof(amount * _rate)}',
              variant: AppTextVariant.titleSmall,
              color: colors.gold,
              fontWeight: FontWeight.w700,
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, child) {
            final amount = double.tryParse(value.text) ?? 0;
            final fee = _calculateFee(amount);
            final total = amount + fee;
            final exceedsBalance = total > availableBalance;

            return Column(
              children: [
                if (fee > 0)
                  AppText(
                    'Frais : ${formatCurrency(fee, currency)} - Total : ${formatCurrency(total, currency)}',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                if (exceedsBalance && amount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: AppText(
                      AppLocalizations.of(context)!.wallet_insufficientBalance,
                      variant: AppTextVariant.bodySmall,
                      color: colors.errorText,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: [1000, 2000, 5000, 10000, 25000].map((xofAmount) {
            final usdcAmount = xofAmount / _rate;
            final label = '${(xofAmount / 1000).toStringAsFixed(0)}k FCFA';

            return _QuickAmountPill(
              label: label,
              onTap: () {
                final value = usdcAmount.toStringAsFixed(2);
                controller.text = value;
                controller.selection = TextSelection.collapsed(
                  offset: value.length,
                );
                onChanged?.call(value);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  double _calculateFee(double amount) {
    if (transferType == 'internal') {
      return FeeSchedule.internalTransfer(amount);
    }
    if (transferType == 'external') {
      return FeeSchedule.externalTransfer(amount);
    }
    return 0;
  }
}

class _QuickAmountPill extends StatelessWidget {
  const _QuickAmountPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.elevated.withValues(alpha: colors.isDark ? 0.72 : 1),
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        splashColor: colors.gold.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: AppText(
            label,
            variant: AppTextVariant.labelMedium,
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
