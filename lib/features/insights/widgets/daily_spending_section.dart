import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/features/insights/models/insights_period.dart';
import 'package:usdc_wallet/features/insights/providers/insights_provider.dart';
import 'package:usdc_wallet/features/insights/widgets/daily_spending_chart.dart';

/// Daily spending section with bar chart for week view
class DailySpendingSection extends ConsumerWidget {
  const DailySpendingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final trends = ref.watch(spendingTrendProvider);
    final period = ref.watch(selectedPeriodProvider);

    // Only show for week period
    if (period != InsightsPeriod.week || trends.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate average and max spending
    final avgSpending = trends.map((t) => t.amount).reduce((a, b) => a + b) / trends.length;
    final maxDay = trends.reduce((a, b) => a.amount > b.amount ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.insights_daily_spending,
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: l10n.insights_daily_average,
                  value: '\$${avgSpending.toStringAsFixed(2)}',
                  icon: Icons.trending_flat,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  label: l10n.insights_highest_day,
                  value: '\$${maxDay.amount.toStringAsFixed(2)}',
                  icon: Icons.trending_up,
                  color: AppColors.gold500,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Bar chart
          DailySpendingChart(dailyTrends: trends),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
