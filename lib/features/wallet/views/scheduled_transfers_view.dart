import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/recurring_transfers/views/recurring_transfers_list_view.dart';

/// Backward-compatible route for the older wallet "scheduled transfers" entry.
///
/// The production implementation lives in the recurring transfers feature,
/// which is wired to the `/recurring-transfers` API. Keeping this wrapper
/// prevents legacy routes from rendering local demo transfers.
class ScheduledTransfersView extends StatelessWidget {
  const ScheduledTransfersView({super.key});

  @override
  Widget build(BuildContext context) => const RecurringTransfersListView();
}
