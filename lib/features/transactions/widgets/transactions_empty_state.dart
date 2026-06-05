import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Empty state shown when the user has no transactions.
class TransactionsEmptyState extends StatelessWidget {
  const TransactionsEmptyState({super.key, this.onSendMoney, this.onDeposit});

  final VoidCallback? onSendMoney;
  final VoidCallback? onDeposit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: l10n.transactions_emptyStateTitle,
      description: l10n.transactions_emptyStateMessage,
      action: onSendMoney != null
          ? EmptyStateAction(label: l10n.send_title, onPressed: onSendMoney!)
          : null,
    );
  }
}
