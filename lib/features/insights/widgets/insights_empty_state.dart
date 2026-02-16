import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

/// Empty state when insufficient data for insights.
class InsightsEmptyState extends StatelessWidget {
  const InsightsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.analytics_outlined,
      title: 'Pas assez de données',
      description:
          'Effectuez quelques transactions et nous vous montrerons vos tendances de dépenses.',
    );
  }
}
