import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

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
      title: 'Aucune transaction',
      description:
          'Votre historique de transactions apparaîtra ici dès que vous enverrez ou recevrez de l\'argent.',
      action: onSendMoney != null
          ? EmptyStateAction(
              label: 'Envoyer de l\'argent',
              onPressed: onSendMoney!,
            )
          : null,
    );
  }
}
