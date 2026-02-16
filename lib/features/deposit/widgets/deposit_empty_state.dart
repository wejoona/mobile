import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

/// Empty state for deposit methods when none are available.
class DepositEmptyState extends StatelessWidget {
  const DepositEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Aucune méthode de dépôt disponible',
      description:
          'Les méthodes de dépôt seront disponibles une fois votre compte vérifié.',
    );
  }
}
