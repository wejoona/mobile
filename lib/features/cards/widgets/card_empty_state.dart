import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

/// Empty state when user has no virtual cards.
class CardEmptyState extends StatelessWidget {
  const CardEmptyState({
    super.key,
    this.onCreateCard,
  });

  final VoidCallback? onCreateCard;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.credit_card_outlined,
      title: 'Aucune carte',
      description:
          'Créez une carte virtuelle pour effectuer des paiements en ligne avec votre solde Korido.',
      action: onCreateCard != null
          ? EmptyStateAction(
              label: 'Créer une carte',
              onPressed: onCreateCard!,
            )
          : null,
    );
  }
}
