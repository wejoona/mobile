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
      title: 'No payment links',
      description:
          'Create a payment link to receive money from anyone, even without a Korido account.',
      action: onCreateLink != null
          ? EmptyStateAction(
              label: 'Create Link',
              onPressed: onCreateLink!,
            )
          : null,
    );
  }
}
