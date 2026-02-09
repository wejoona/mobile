import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/components/primitives/app_text.dart';
import '../providers/insights_provider.dart';

class SpendingSummaryCard extends ConsumerWidget {
  const SpendingSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final summary = ref.watch(spendingSummaryProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.slate,
            AppColors.graphite,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.borderGold,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                l10n.insights_summary,
                variant: AppTextVariant.titleMedium,
                color: AppColors.textPrimary,
              ),
              if (summary.percentageChange > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: summary.isIncrease
                        ? AppColors.errorBase.withValues(alpha: 0.2)
                        : AppColors.successBase.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        summary.isIncrease
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: summary.isIncrease
                            ? AppColors.errorText
                            : AppColors.successText,
                      ),
                      const SizedBox(width: 4),
                      AppText(
                        '${summary.percentageChange.toStringAsFixed(1)}%',
                        variant: AppTextVariant.bodySmall,
                        color: summary.isIncrease
                            ? AppColors.errorText
                            : AppColors.successText,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Total spent
          _buildStatItem(
            l10n.insights_total_spent,
            '\$${summary.totalSpent.toStringAsFixed(2)}',
            AppColors.errorText,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Total received
          _buildStatItem(
            l10n.insights_total_received,
            '\$${summary.totalReceived.toStringAsFixed(2)}',
            AppColors.successText,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Divider
          Container(
            height: 1,
            color: AppColors.borderSubtle,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Net flow
          _buildStatItem(
            l10n.insights_net_flow,
            '${summary.netFlow >= 0 ? '+' : ''}\$${summary.netFlow.toStringAsFixed(2)}',
            summary.netFlow >= 0 ? AppColors.successText : AppColors.errorText,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color valueColor, {
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: AppText(
            value,
            variant: isLarge ? AppTextVariant.headlineSmall : AppTextVariant.titleMedium,
            color: valueColor,
            fontWeight: FontWeight.bold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
