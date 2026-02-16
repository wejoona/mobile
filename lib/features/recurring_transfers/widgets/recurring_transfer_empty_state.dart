import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

/// Empty state when user has no recurring transfers.
class RecurringTransferEmptyState extends StatelessWidget {
  const RecurringTransferEmptyState({
    super.key,
    this.onSetup,
  });

  final VoidCallback? onSetup;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.repeat_outlined,
      title: 'Aucun virement récurrent',
      description:
          'Configurez des virements automatiques pour envoyer de l\'argent régulièrement.',
      action: onSetup != null
          ? EmptyStateAction(
              label: 'Configurer un virement',
              onPressed: onSetup!,
            )
          : null,
    );
  }
}
