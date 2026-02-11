import 'package:flutter/material.dart';
import '../../../design/components/states/empty_state.dart';

/// Empty state for deposit methods when none are available.
class DepositEmptyState extends StatelessWidget {
  const DepositEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: 'No deposit methods available',
      description:
          'Deposit methods will be available once your account is verified.',
    );
  }
}
