import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/bill_payments/views/bill_payments_view.dart';

/// Backward-compatible wallet route for bill payments.
///
/// The production flow lives in `features/bill_payments` and calls the
/// `/bill-payments` API. This wrapper prevents legacy navigation from showing
/// hardcoded billers, fake account validation, or simulated payment success.
class BillPayView extends StatelessWidget {
  const BillPayView({super.key});

  @override
  Widget build(BuildContext context) => const BillPaymentsView();
}
