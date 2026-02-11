import 'package:flutter/material.dart';
import '../../../design/components/states/empty_state.dart';

/// Empty state shown when the user has no transactions.
class TransactionsEmptyState extends StatelessWidget {
  const TransactionsEmptyState({
    super.key,
    this.onSendMoney,
    this.onDeposit,
  });

  final VoidCallback? onSendMoney;
  final VoidCallback? onDeposit;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No transactions yet',
      description:
          'Your transaction history will appear here once you send or receive money.',
      action: onSendMoney != null
          ? EmptyStateAction(
              label: 'Send Money',
              onPressed: onSendMoney!,
            )
          : null,
    );
  }
}
