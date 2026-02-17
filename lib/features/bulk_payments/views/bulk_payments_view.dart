import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/bulk_payments/providers/bulk_payments_provider.dart';
import 'package:usdc_wallet/features/bulk_payments/widgets/bulk_payment_card.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Bulk payments list screen.
class BulkPaymentsView extends ConsumerWidget {
  const BulkPaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(bulkPaymentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bulkPayments_title),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), tooltip: 'Nouveau paiement', onPressed: () {})],
      ),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.bulkPayments_error(e.toString()))),
        data: (payments) {
          if (payments.isEmpty) {
            return const EmptyState(
              icon: Icons.groups_rounded,
              title: 'Aucun paiement groupé',
              subtitle: 'Payez plusieurs personnes à la fois en important un CSV ou en ajoutant des bénéficiaires manuellement.',
              actionLabel: 'Nouveau paiement groupé',
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
