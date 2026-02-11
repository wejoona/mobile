import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

class UpgradePrompt extends StatelessWidget {
  final String? nextTierName;
  final double? nextTierDailyLimit;
  final double? nextTierMonthlyLimit;

  const UpgradePrompt({
    super.key,
    this.nextTierName,
    this.nextTierDailyLimit,
    this.nextTierMonthlyLimit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return GestureDetector(
      onTap: () => context.push('/kyc'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.gold.withValues(alpha: 0.15),
              AppColors.gold600.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: colors.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up,
                color: colors.gold,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.limits_upgradeTitle,
                    variant: AppTextVariant.labelLarge,
                    color: colors.gold,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    nextTierName != null
                        ? '${l10n.limits_upgradeToTier} $nextTierName'
                        : l10n.limits_upgradeDescription,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                  if (nextTierDailyLimit != null && nextTierMonthlyLimit != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      '\$${nextTierDailyLimit!.toStringAsFixed(0)}/${l10n.limits_day} • \$${nextTierMonthlyLimit!.toStringAsFixed(0)}/${l10n.limits_month}',
                      variant: AppTextVariant.bodySmall,
                      color: colors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: colors.gold,
            ),
          ],
        ),
      ),
    );
  }
}
