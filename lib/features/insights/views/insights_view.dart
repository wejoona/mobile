import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/insights_provider.dart';
import '../widgets/spending_chart.dart';

/// Spending insights screen.
class InsightsView extends ConsumerWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(spendingInsightsProvider);
    final period = ref.watch(insightsPeriodProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: insightsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
                child: Text('Spending by Category', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
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
