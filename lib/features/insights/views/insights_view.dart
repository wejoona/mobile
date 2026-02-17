import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/insights/providers/insights_provider.dart';
import 'package:usdc_wallet/features/insights/widgets/spending_chart.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Spending insights screen.
class InsightsView extends ConsumerWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(spendingInsightsProvider);
    final period = ref.watch(insightsPeriodProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.insights_title)),
      body: insightsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.insights_error(e.toString()))),
        data: (insights) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<InsightsPeriod>(
                segments: InsightsPeriod.values.map((p) => ButtonSegment(value: p, label: Text(p.label))).toList(),
                selected: {period},
                onSelectionChanged: (s) => ref.read(insightsPeriodProvider.notifier).state = s.first,
              ),
            ),
            SpendingSummaryHeader(totalSpent: insights.totalSpent, totalReceived: insights.totalReceived),
            const SizedBox(height: 16),
            if (insights.categoryBreakdown.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(AppLocalizations.of(context)!.insights_categories, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SpendingChart(categories: insights.categoryBreakdown, totalSpent: insights.totalSpent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
