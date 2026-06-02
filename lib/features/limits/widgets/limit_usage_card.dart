import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/primitives/progress_bar.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/limit.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Card showing transaction limit usage.
class LimitUsageCard extends StatelessWidget {
  const LimitUsageCard({super.key, required this.limits});

  final TransactionLimits limits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.limits_transactionLimits,
            variant: AppTextVariant.titleSmall,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.lg),
          _LimitRow(
            label: l10n.limits_dailyLimits,
            used: limits.dailyUsed,
            limit: limits.dailyLimit,
          ),
          const SizedBox(height: AppSpacing.md),
          _LimitRow(
            label: '7 days',
            used: limits.weeklyUsed,
            limit: limits.weeklyLimit,
          ),
          const SizedBox(height: AppSpacing.md),
          _LimitRow(
            label: l10n.limits_monthlyLimits,
            used: limits.monthlyUsed,
            limit: limits.monthlyLimit,
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: colors.borderSubtle),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                l10n.limits_maxPerTransaction,
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
              AppText(
                '\$${limits.singleTransactionMax.toStringAsFixed(2)}',
                variant: AppTextVariant.monoMedium,
                color: colors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({
    required this.label,
    required this.used,
    required this.limit,
  });

  final String label;
  final double used;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final usage = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final color = usage > 0.9
        ? colors.errorText
        : (usage > 0.7 ? colors.warningText : colors.gold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              label,
              variant: AppTextVariant.bodySmall,
              color: colors.textPrimary,
            ),
            AppText(
              '\$${used.toStringAsFixed(2)} / \$${limit.toStringAsFixed(2)}',
              variant: AppTextVariant.monoSmall,
              color: colors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ProgressBar(value: usage, height: 6, color: color),
      ],
    );
  }
}
