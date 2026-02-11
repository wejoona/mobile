import 'package:flutter/material.dart';
import '../../../design/components/states/empty_state.dart';

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
      title: 'No bill payments',
      description:
          'Pay your utility bills, airtime, and more directly from your Korido wallet.',
      action: onPayBill != null
          ? EmptyStateAction(
              label: 'Pay a Bill',
              onPressed: onPayBill!,
            )
          : null,
    );
  }
}
