import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/deposit_method_provider.dart';

/// Run 364: Deposit method selection card widget
class DepositMethodCard extends StatelessWidget {
  final DepositMethodInfo method;
  final bool isSelected;
  final VoidCallback onTap;

  const DepositMethodCard({
    super.key,
    required this.method,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${method.name}: ${method.description}'
          '${isSelected ? ", selectionne" : ""}',
      button: true,
      child: GestureDetector(
        onTap: method.isAvailable ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.gold.withOpacity(0.08)
                : AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.gold : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Opacity(
            opacity: method.isAvailable ? 1.0 : 0.4,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _methodIcon,
                    color: isSelected ? AppColors.gold : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(method.name, style: AppTextStyle.labelLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        method.description,
                        style: AppTextStyle.bodySmall,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      method.feePercent > 0
                          ? '${method.feePercent}%'
                          : 'Gratuit',
                      style: AppTextStyle.labelSmall,
                      color: method.feePercent == 0
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      _estimatedTimeLabel,
                      style: AppTextStyle.bodySmall,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _methodIcon {
    switch (method.method) {
      case DepositMethod.mobileMoney:
        return Icons.phone_android;
      case DepositMethod.bankTransfer:
        return Icons.account_balance;
      case DepositMethod.card:
        return Icons.credit_card;
      case DepositMethod.crypto:
        return Icons.currency_bitcoin;
    }
  }

  String get _estimatedTimeLabel {
    final mins = method.estimatedTime.inMinutes;
    if (mins < 60) return '~${mins}min';
    final hours = method.estimatedTime.inHours;
    return '~${hours}h';
  }
}
