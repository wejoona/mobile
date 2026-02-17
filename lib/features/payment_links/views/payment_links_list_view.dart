import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/payment_links/providers/payment_links_provider.dart';
import 'package:usdc_wallet/features/payment_links/widgets/payment_link_card.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Payment links list screen.
class PaymentLinksListView extends ConsumerWidget {
  const PaymentLinksListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(paymentLinksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.paymentLinks_title),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), tooltip: 'Créer un lien', onPressed: () {}),
        ],
      ),
      body: linksAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: ShimmerList(itemCount: 3)),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.paymentLinks_error(e.toString()))),
        data: (links) {
          if (links.isEmpty) {
            return const EmptyState(
              icon: Icons.link_rounded,
              title: 'No payment links',
              subtitle: 'Create a payment link to receive money from anyone',
              actionLabel: 'Create Link',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(paymentLinksProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: links.length,
              itemBuilder: (_, i) => PaymentLinkCard(link: links[i]),
            ),
          );
        },
      ),
    );
  }
}
