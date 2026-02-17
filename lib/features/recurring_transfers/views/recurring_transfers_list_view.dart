import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/recurring_transfers/providers/recurring_transfers_provider.dart';
import 'package:usdc_wallet/features/recurring_transfers/widgets/recurring_transfer_card.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Recurring transfers list screen.
class RecurringTransfersListView extends ConsumerWidget {
  const RecurringTransfersListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersAsync = ref.watch(recurringTransfersProvider);
    final monthlyAmount = ref.watch(monthlyRecurringAmountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recurringTransfers_title),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), tooltip: 'Nouveau virement récurrent', onPressed: () {}),
        ],
      ),
      body: transfersAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: ShimmerList()),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.common_errorFormat(e.toString()))),
        data: (transfers) {
          if (transfers.isEmpty) {
            return const EmptyState(
              icon: Icons.repeat_rounded,
              title: 'No recurring transfers',
              subtitle: 'Set up automatic transfers to save time on regular payments',
              actionLabel: 'Create Recurring',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(recurringTransfersProvider.future),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.analytics_monthlyTotal, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text('\$${monthlyAmount.toStringAsFixed(2)}/mo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                ...transfers.map((t) => RecurringTransferCard(transfer: t)),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
