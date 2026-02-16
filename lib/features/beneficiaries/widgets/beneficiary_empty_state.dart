import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

/// Empty state when user has no saved beneficiaries.
class BeneficiaryEmptyState extends StatelessWidget {
  const BeneficiaryEmptyState({
    super.key,
    this.onAddBeneficiary,
  });

  final VoidCallback? onAddBeneficiary;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.people_outline,
      title: 'Aucun bénéficiaire enregistré',
      description:
          'Enregistrez vos bénéficiaires fréquents pour des transferts plus rapides.',
      action: onAddBeneficiary != null
          ? EmptyStateAction(
              label: 'Ajouter un bénéficiaire',
              onPressed: onAddBeneficiary!,
            )
          : null,
    );
  }
}
