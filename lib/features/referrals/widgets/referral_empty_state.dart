import 'package:flutter/material.dart';
import '../../../design/components/states/empty_state.dart';

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
      title: 'Invite friends',
      description:
          'Share your referral code and earn rewards when friends join Korido.',
      action: onShareCode != null
          ? EmptyStateAction(
              label: 'Share Code',
              onPressed: onShareCode!,
            )
          : null,
    );
  }
}
