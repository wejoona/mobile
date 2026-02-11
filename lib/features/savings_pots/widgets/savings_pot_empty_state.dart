import 'package:flutter/material.dart';
import '../../../design/components/states/empty_state.dart';

/// Empty state when user has no savings pots.
class SavingsPotEmptyState extends StatelessWidget {
  const SavingsPotEmptyState({
    super.key,
    this.onCreatePot,
  });

  final VoidCallback? onCreatePot;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.savings_outlined,
      title: 'Start saving',
      description:
          'Create a savings pot to set aside funds for your goals.',
      action: onCreatePot != null
          ? EmptyStateAction(
              label: 'Create Pot',
              onPressed: onCreatePot!,
            )
          : null,
    );
  }
}
