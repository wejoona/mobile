import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';

class LimitWarningBanner extends StatelessWidget {
  final TransactionLimits limits;
  final bool showDailyWarning;
  final bool showMonthlyWarning;

  const LimitWarningBanner({
    super.key,
    required this.limits,
    this.showDailyWarning = true,
    this.showMonthlyWarning = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    // Determine what to show
    final bool showDaily = showDailyWarning && (limits.isDailyNearLimit || limits.isDailyAtLimit);
    final bool showMonthly = showMonthlyWarning && (limits.isMonthlyNearLimit || limits.isMonthlyAtLimit);

    if (!showDaily && !showMonthly) {
      return const SizedBox.shrink();
    }

    // Prioritize daily limit warnings
    final bool isAtLimit = limits.isDailyAtLimit || limits.isMonthlyAtLimit;
    final bool isNearLimit = limits.isDailyNearLimit || limits.isMonthlyNearLimit;
    final String message = _getMessage(l10n, limits, showDaily, showMonthly);

    return GestureDetector(
      onTap: () => context.push('/settings/limits'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isAtLimit
              ? AppColors.errorBase.withValues(alpha: 0.1)
              : AppColors.warningBase.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isAtLimit
                ? AppColors.errorBase.withValues(alpha: 0.3)
                : AppColors.warningBase.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isAtLimit ? Icons.block : Icons.warning_amber_rounded,
              color: isAtLimit ? AppColors.errorBase : AppColors.warningBase,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    isAtLimit ? l10n.limits_limitReached : l10n.limits_approachingLimit,
                    variant: AppTextVariant.labelMedium,
                    color: isAtLimit ? AppColors.errorBase : AppColors.warningBase,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    message,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getMessage(AppLocalizations l10n, TransactionLimits limits, bool showDaily, bool showMonthly) {
    if (limits.isDailyAtLimit) {
      return '${l10n.limits_dailyLimitReached} \$${limits.dailyLimit.toStringAsFixed(0)}';
    }
    if (limits.isMonthlyAtLimit) {
      return '${l10n.limits_monthlyLimitReached} \$${limits.monthlyLimit.toStringAsFixed(0)}';
    }
    if (limits.isDailyNearLimit) {
      return '\$${limits.dailyRemaining.toStringAsFixed(2)} ${l10n.limits_remainingToday}';
    }
    if (limits.isMonthlyNearLimit) {
      return '\$${limits.monthlyRemaining.toStringAsFixed(2)} ${l10n.limits_remainingThisMonth}';
    }
    return '';
  }
}
