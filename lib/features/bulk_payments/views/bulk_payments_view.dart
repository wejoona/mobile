import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bulk_payments_provider.dart';
import '../widgets/bulk_payment_card.dart';
import '../../../design/components/primitives/empty_state.dart';

/// Bulk payments list screen.
class BulkPaymentsView extends ConsumerWidget {
  const BulkPaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(bulkPaymentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Payments'),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {})],
      ),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (payments) {
          if (payments.isEmpty) {
            return const EmptyState(
              icon: Icons.groups_rounded,
              title: 'No bulk payments',
              subtitle: 'Pay multiple people at once by uploading a CSV or adding recipients manually',
              actionLabel: 'New Bulk Payment',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(bulkPaymentsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: payments.length,
              itemBuilder: (_, i) => BulkPaymentCard(payment: payments[i]),
            ),
          );
        },
      ),
    );
  }
}
