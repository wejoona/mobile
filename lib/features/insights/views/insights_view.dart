import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../models/insights_period.dart';
import '../providers/insights_provider.dart';
import '../widgets/spending_summary_card.dart';
import '../widgets/spending_by_category_section.dart';
import '../widgets/spending_trend_section.dart';
import '../widgets/top_recipients_section.dart';
import '../widgets/empty_insights_state.dart';

class InsightsView extends ConsumerWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final summary = ref.watch(spendingSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          l10n.insights_title,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.gold500),
            onPressed: () => _handleExportReport(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: summary.totalSpent == 0 && summary.totalReceived == 0
            ? const EmptyInsightsState()
            : _buildContent(context, ref, l10n, selectedPeriod),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    InsightsPeriod selectedPeriod,
  ) {
    return CustomScrollView(
      slivers: [
        // Period selector
        SliverToBoxAdapter(
          child: _buildPeriodSelector(context, ref, l10n, selectedPeriod),
        ),

        // Summary card
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: SpendingSummaryCard(),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.sectionGap),
        ),

        // Spending by category
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: SpendingByCategorySection(),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.sectionGap),
        ),

        // Spending trend
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: SpendingTrendSection(),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.sectionGap),
        ),

        // Top recipients
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: TopRecipientsSection(),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.sectionGap),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    InsightsPeriod selectedPeriod,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.screenPadding),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: InsightsPeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(selectedPeriodProvider.notifier).setPeriod(period);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.gold500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    _getPeriodLabel(l10n, period),
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.textInverse
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPeriodLabel(AppLocalizations l10n, InsightsPeriod period) {
    switch (period) {
      case InsightsPeriod.week:
        return l10n.insights_period_week;
      case InsightsPeriod.month:
        return l10n.insights_period_month;
      case InsightsPeriod.year:
        return l10n.insights_period_year;
    }
  }

  Future<void> _handleExportReport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final period = ref.read(selectedPeriodProvider);
    final summary = ref.read(spendingSummaryProvider);

    // Generate simple text report
    final report = '''
${l10n.insights_title} - ${_getPeriodLabel(l10n, period)}

${l10n.insights_total_spent}: \$${summary.totalSpent.toStringAsFixed(2)}
${l10n.insights_total_received}: \$${summary.totalReceived.toStringAsFixed(2)}
${l10n.insights_net_flow}: \$${summary.netFlow.toStringAsFixed(2)}

${l10n.insights_categories}:
${summary.topCategories.map((c) => '- ${c.name}: \$${c.amount.toStringAsFixed(2)} (${c.percentage.toStringAsFixed(1)}%)').join('\n')}

Generated by JoonaPay
''';

    await Share.share(
      report,
      subject: '${l10n.insights_title} - ${_getPeriodLabel(l10n, period)}',
    );
  }
}
