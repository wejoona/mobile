import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/limits/widgets/limit_progress_bar.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class LimitCard extends StatelessWidget {
  final String title;
  final double used;
  final double limit;
  final IconData icon;
  final bool isMonthly;

  const LimitCard({
    super.key,
    required this.title,
    required this.used,
    required this.limit,
    required this.icon,
    this.isMonthly = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final percentage = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final remaining = (limit - used).clamp(0.0, limit);
    final isNearLimit = percentage >= 0.8;
    final isAtLimit = percentage >= 1.0;

    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: colors.gold, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      variant: AppTextVariant.labelMedium,
                      color: colors.textPrimary,
                    ),
                    AppText(
                      '\$${remaining.toStringAsFixed(2)} ${l10n.limits_remaining}',
                      variant: AppTextVariant.bodySmall,
                      color: isAtLimit
                          ? context.colors.error
                          : (isNearLimit ? context.colors.warning : colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    '\$${used.toStringAsFixed(2)}',
                    variant: AppTextVariant.labelMedium,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    '${l10n.limits_of} \$${limit.toStringAsFixed(2)}',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LimitProgressBar(
            percentage: percentage,
            isNearLimit: isNearLimit,
            isAtLimit: isAtLimit,
          ),
        ],
      ),
    );
  }
}
