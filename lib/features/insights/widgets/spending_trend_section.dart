import 'package:usdc_wallet/providers/missing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/features/insights/models/spending_trend.dart';
import 'package:usdc_wallet/features/insights/models/insights_period.dart';
import 'package:usdc_wallet/features/insights/providers/insights_provider.dart';
import 'package:usdc_wallet/features/insights/widgets/spending_line_chart.dart';

class SpendingTrendSection extends ConsumerWidget {
  const SpendingTrendSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final trendsAsync = ref.watch(spendingTrendProvider);
    final periodStr = ref.watch(selectedPeriodProvider);
    final period = InsightsPeriod.values.firstWhere(
      (e) => e.name == periodStr,
      orElse: () => InsightsPeriod.month,
    );

    return trendsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (trendsData) {
        final trends = trendsData.map((t) => SpendingTrend.fromJson(t)).toList();
        if (trends.isEmpty) return const SizedBox.shrink();

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
              Text(
                l10n.insights_spending_trend,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SpendingLineChart(trends: trends, period: period),
            ],
          ),
        );
      },
    );
  }
}
