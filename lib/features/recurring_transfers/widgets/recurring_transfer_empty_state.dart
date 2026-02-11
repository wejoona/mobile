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
      title: 'No recurring transfers',
      description:
          'Set up automatic transfers to send money on a regular schedule.',
      action: onSetup != null
          ? EmptyStateAction(
              label: 'Set Up Transfer',
              onPressed: onSetup!,
            )
          : null,
    );
  }
}
