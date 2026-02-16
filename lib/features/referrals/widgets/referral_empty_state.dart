import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

/// Empty state when user has no referrals.
class ReferralEmptyState extends StatelessWidget {
  const ReferralEmptyState({
    super.key,
    this.onShareCode,
  });

  final VoidCallback? onShareCode;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.people_outline,
      title: 'Invitez vos amis',
      description:
          'Partagez votre code de parrainage et gagnez des récompenses quand vos amis rejoignent Korido.',
      action: onShareCode != null
          ? EmptyStateAction(
              label: 'Partager le code',
              onPressed: onShareCode!,
            )
          : null,
    );
  }
}
