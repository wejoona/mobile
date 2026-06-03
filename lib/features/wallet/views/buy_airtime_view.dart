import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/bill_payments/views/bill_payments_view.dart';

/// Backward-compatible wallet route for airtime purchases.
///
/// Airtime providers are served by the bill-payments API. This wrapper avoids
/// the older local screen that hardcoded networks, data bundles, and fake
/// purchase completion.
class BuyAirtimeView extends StatelessWidget {
  const BuyAirtimeView({super.key});

  @override
  Widget build(BuildContext context) => const BillPaymentsView();
}
