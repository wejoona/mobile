import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Balance Display Card
/// Shows total balance with change percentage
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.balance,
    required this.currency,
    super.key,
    this.changePercent,
    this.changeAmount,
    this.onDepositTap,
    this.onWithdrawTap,
    this.isLoading = false,
  });

  final double balance;
  final String currency;
  final double? changePercent;
  final double? changeAmount;
  final VoidCallback? onDepositTap;
  final VoidCallback? onWithdrawTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: colors.gold,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const AppText('Total Balance', variant: AppTextVariant.cardLabel),
              const Spacer(),
              StatusPill(
                label: currency,
                tone: StatusTone.brand,
                compact: true,
                emphasis: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Balance
          if (isLoading)
            _buildLoadingBalance(colors)
          else
            _buildBalance(colors),

          const SizedBox(height: AppSpacing.sm),

          // Change indicator
          if (changePercent != null && !isLoading)
            _buildChangeIndicator(colors),

          const SizedBox(height: AppSpacing.xl),

          // Action button
          if (onDepositTap != null)
            AppButton(
              label: 'Deposit Funds',
              onPressed: onDepositTap,
              isFullWidth: true,
            ),
        ],
      ),
    );
  }

  Widget _buildBalance(ThemeColors colors) => AmountText(
    amount: balance,
    currencyCode: currency,
    color: colors.textPrimary,
  );

  Widget _buildLoadingBalance(ThemeColors colors) => Container(
    width: 200,
    height: 42,
    decoration: BoxDecoration(
      color: colors.elevated,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
  );

  Widget _buildChangeIndicator(ThemeColors colors) {
    final isPositive = (changePercent ?? 0) >= 0;
    final color = isPositive ? colors.successText : colors.errorText;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final sign = isPositive ? '+' : '';

    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: AppSpacing.xs),
        AppText(
          '$sign${changePercent?.toStringAsFixed(1)}%',
          variant: AppTextVariant.percentage,
          color: color,
        ),
        if (changeAmount != null) ...[
          const SizedBox(width: AppSpacing.sm),
          AppText(
            '($sign\$${changeAmount?.toStringAsFixed(2)})',
            variant: AppTextVariant.bodySmall,
            color: colors.textTertiary,
          ),
        ],
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('balance', balance))
      ..add(StringProperty('currency', currency))
      ..add(DoubleProperty('changePercent', changePercent))
      ..add(DoubleProperty('changeAmount', changeAmount))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onDepositTap', onDepositTap))
      ..add(
        ObjectFlagProperty<VoidCallback?>.has('onWithdrawTap', onWithdrawTap),
      )
      ..add(FlagProperty('isLoading', value: isLoading, ifTrue: 'loading'));
  }
}
