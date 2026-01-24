import 'package:flutter/material.dart';
import '../../tokens/index.dart';
import '../primitives/index.dart';

/// Balance Display Card
/// Shows total balance with change percentage
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.currency,
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
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.gold500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.gold500,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const AppText(
                'Total Balance',
                variant: AppTextVariant.cardLabel,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Balance
          if (isLoading)
            _buildLoadingBalance()
          else
            _buildBalance(),

          const SizedBox(height: AppSpacing.sm),

          // Change indicator
          if (changePercent != null && !isLoading) _buildChangeIndicator(),

          const SizedBox(height: AppSpacing.xl),

          // Action button
          if (onDepositTap != null)
            AppButton(
              label: 'Deposit Funds',
              onPressed: onDepositTap,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
        ],
      ),
    );
  }

  Widget _buildBalance() {
    return AppText(
      _formatCurrency(balance, currency),
      variant: AppTextVariant.balance,
      color: AppColors.textPrimary,
    );
  }

  Widget _buildLoadingBalance() {
    return Container(
      width: 200,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }

  Widget _buildChangeIndicator() {
    final isPositive = (changePercent ?? 0) >= 0;
    final color = isPositive ? AppColors.successText : AppColors.errorText;
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
            color: AppColors.textTertiary,
          ),
        ],
      ],
    );
  }

  String _formatCurrency(double amount, String currency) {
    // Simple formatting - in production use intl package
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '\$$wholePart.${parts[1]}';
  }
}
