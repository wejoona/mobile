import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/providers/missing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/features/insights/models/spending_category.dart';
import 'package:usdc_wallet/features/insights/providers/insights_provider.dart';
import 'package:usdc_wallet/features/insights/widgets/spending_pie_chart.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class SpendingByCategorySection extends ConsumerWidget {
  const SpendingByCategorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(spendingByCategoryProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (categoriesMap) {
        if (categoriesMap.isEmpty) return const SizedBox.shrink();

        // Convert Map<String, double> to List<SpendingCategory>
        final total = categoriesMap.values.fold(0.0, (a, b) => a + b);
        final categoryColors = [
          context.colors.gold,
          context.colors.success,
          context.colors.error,
          context.colors.warning,
          Colors.blue,
          Colors.purple,
        ];
        int colorIdx = 0;
        final categories = categoriesMap.entries.map((e) {
          final cat = SpendingCategory(
            name: e.key,
            amount: e.value,
            percentage: total > 0 ? (e.value / total) * 100 : 0,
            color: categoryColors[colorIdx++ % categoryColors.length],
            transactionCount: 0,
          );
          return cat;
        }).toList();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
          decoration: BoxDecoration(
            color: context.colors.container,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.insights_categories,
                variant: AppTextVariant.titleMedium,
                color: context.colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.xxl),
              SpendingPieChart(categories: categories),
              const SizedBox(height: AppSpacing.xxl),
              ...categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppText(
                          category.name,
                          variant: AppTextVariant.bodyMedium,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText(
                            '\$${category.amount.toStringAsFixed(2)}',
                            variant: AppTextVariant.bodyMedium,
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          AppText(
                            '${category.percentage.toStringAsFixed(1)}%',
                            variant: AppTextVariant.bodySmall,
                            color: context.colors.textSecondary,
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
      },
    );
  }
}
