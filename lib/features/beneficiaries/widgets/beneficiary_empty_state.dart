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
      title: 'No saved recipients',
      description:
          'Save your frequent recipients for faster transfers next time.',
      action: onAddBeneficiary != null
          ? EmptyStateAction(
              label: 'Add Recipient',
              onPressed: onAddBeneficiary!,
            )
          : null,
    );
  }
}
