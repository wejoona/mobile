import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/insights/providers/insights_provider.dart';
import 'package:usdc_wallet/features/insights/widgets/spending_chart.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

/// Spending insights screen.
class InsightsView extends ConsumerWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(spendingInsightsProvider);
    final period = ref.watch(insightsPeriodProvider);
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.insights_title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
      ),
      body: insightsAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: colors.gold)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insights_outlined,
                  color: colors.errorText,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  l10n.insights_error(UserFacingErrors.message(e)),
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (insights) {
          final hasData =
              insights.transactionCount > 0 ||
              insights.totalSpent > 0 ||
              insights.totalReceived > 0 ||
              insights.categoryBreakdown.isNotEmpty;

          if (!hasData) {
            return _InsightsEmptyState(l10n: l10n);
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _PeriodSelector(
                selected: period,
                onChanged: (value) =>
                    ref.read(insightsPeriodProvider.notifier).state = value,
              ),
              const SizedBox(height: AppSpacing.lg),
              SpendingSummaryHeader(
                totalSpent: insights.totalSpent,
                totalReceived: insights.totalReceived,
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (insights.categoryBreakdown.isNotEmpty) ...[
                AppText(
                  l10n.insights_categories,
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.md),
                SpendingChart(
                  categories: insights.categoryBreakdown,
                  totalSpent: insights.totalSpent,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final InsightsPeriod selected;
  final ValueChanged<InsightsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: InsightsPeriod.values.map((period) {
          final isSelected = period == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              selected: isSelected,
              label: AppText(
                period.label,
                variant: AppTextVariant.labelMedium,
                color: isSelected ? colors.canvas : colors.textSecondary,
              ),
              selectedColor: colors.gold,
              backgroundColor: colors.container,
              side: BorderSide(
                color: isSelected ? colors.gold : colors.borderSubtle,
              ),
              onSelected: (_) => onChanged(period),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InsightsEmptyState extends StatelessWidget {
  const _InsightsEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: colors.gold.withValues(alpha: 0.22)),
              ),
              child: Icon(
                Icons.insights_outlined,
                color: colors.gold,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              l10n.insights_empty_title,
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.insights_empty_description,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
