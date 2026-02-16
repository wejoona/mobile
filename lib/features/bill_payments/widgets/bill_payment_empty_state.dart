import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

/// Empty state when no bill payments history.
class BillPaymentEmptyState extends StatelessWidget {
  const BillPaymentEmptyState({
    super.key,
    this.onPayBill,
  });

  final VoidCallback? onPayBill;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_outlined,
      title: 'Aucun paiement de facture',
      description:
          'Payez vos factures d\'eau, d\'électricité, de téléphone et plus directement depuis votre portefeuille Korido.',
      action: onPayBill != null
          ? EmptyStateAction(
              label: 'Payer une facture',
              onPressed: onPayBill!,
            )
          : null,
    );
  }
}
