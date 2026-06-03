import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/payment_links/views/create_link_view.dart';

/// Backward-compatible wallet route for the old split-bill entry.
///
/// Korido can safely collect money through API-backed payment links today.
/// This wrapper prevents the legacy split UI from showing local pending
/// requests or simulated request-sent success.
class SplitBillView extends StatelessWidget {
  const SplitBillView({super.key});

  @override
  Widget build(BuildContext context) => const CreateLinkView();
}
