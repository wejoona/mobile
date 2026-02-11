import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/features/insights/providers/insights_provider.dart';
import 'spending_pie_chart.dart';

class SpendingByCategorySection extends ConsumerWidget {
  const SpendingByCategorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(spendingByCategoryProvider);

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

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
            l10n.insights_categories,
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Pie chart
          SpendingPieChart(categories: categories),

          const SizedBox(height: AppSpacing.xxl),

          // Legend
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  // Color indicator
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Category name
                  Expanded(
                    child: AppText(
                      category.name,
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // Amount and percentage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(
                        '\$${category.amount.toStringAsFixed(2)}',
                        variant: AppTextVariant.bodyMedium,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      AppText(
                        '${category.percentage.toStringAsFixed(1)}%',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
