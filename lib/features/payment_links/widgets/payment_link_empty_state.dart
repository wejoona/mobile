import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

/// Empty state when user has no payment links.
class PaymentLinkEmptyState extends StatelessWidget {
  const PaymentLinkEmptyState({
    super.key,
    this.onCreateLink,
  });

  final VoidCallback? onCreateLink;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.link_outlined,
      title: 'Aucun lien de paiement',
      description:
          'Créez un lien de paiement pour recevoir de l\'argent de n\'importe qui, même sans compte Korido.',
      action: onCreateLink != null
          ? EmptyStateAction(
              label: 'Créer un lien',
              onPressed: onCreateLink!,
            )
          : null,
    );
  }
}
