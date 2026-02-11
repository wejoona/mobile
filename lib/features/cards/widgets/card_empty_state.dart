import 'package:flutter/material.dart';
import '../../../design/components/states/empty_state.dart';

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
      title: 'No cards yet',
      description:
          'Create a virtual card to make online payments with your Korido balance.',
      action: onCreateCard != null
          ? EmptyStateAction(
              label: 'Create Card',
              onPressed: onCreateCard!,
            )
          : null,
    );
  }
}
