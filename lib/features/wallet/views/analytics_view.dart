import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/insights/views/insights_view.dart';

/// Backward-compatible route for the older wallet analytics entry.
///
/// The production implementation lives in the insights feature and reads
/// transaction stats from the API. Keeping this wrapper prevents legacy
/// navigation from showing fabricated income, spending, or export reports.
class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) => const InsightsView();
}
