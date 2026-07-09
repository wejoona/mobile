import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/utils/formatters.dart';

/// Main wallet balance card shown on home screen.
class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    this.pendingBalance,
    this.isBalanceHidden = false,
    this.onToggleVisibility,
    this.onDeposit,
    this.onSend,
  });

  final double balance;
  final String currency;
  final double? pendingBalance;
  final bool isBalanceHidden;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onDeposit;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Available Balance',
                variant: AppTextVariant.labelLarge,
                color: colors.onGold.withValues(alpha: 0.72),
              ),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isBalanceHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colors.onGold.withValues(alpha: 0.72),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AmountText.fromText(
            isBalanceHidden ? r'$••••••' : formatCurrency(balance, currency),
            size: AmountTextSize.large,
            color: colors.onGold,
          ),
          if (pendingBalance != null && pendingBalance! > 0) ...[
            const SizedBox(height: 4),
            AppText(
              'Pending: ${formatCurrency(pendingBalance!, currency)}',
              variant: AppTextVariant.moneySmall,
              color: colors.onGold.withValues(alpha: 0.64),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Deposit',
                  onTap: onDeposit,
                  labelColor: colors.onGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Send',
                  onTap: onSend,
                  labelColor: colors.onGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.labelColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color labelColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: labelColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: labelColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
