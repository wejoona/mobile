import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

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
      title: 'Commencez à épargner',
      description:
          'Créez une cagnotte pour mettre de côté des fonds pour vos objectifs.',
      action: onCreatePot != null
          ? EmptyStateAction(
              label: 'Créer une cagnotte',
              onPressed: onCreatePot!,
            )
          : null,
    );
  }
}
