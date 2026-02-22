import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/payment_links/models/payment_link.dart';
import 'package:usdc_wallet/services/service_providers.dart';

/// Payment links list provider — wired to PaymentLinksService.
final paymentLinksProvider = FutureProvider<List<PaymentLink>>((ref) async {
  final service = ref.watch(paymentLinksServiceProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 2), () => link.close());
  ref.onDispose(() => timer.cancel());

  return await service.getPaymentLinks();
});

/// Active payment links only.
final activePaymentLinksProvider = Provider<List<PaymentLink>>((ref) {
  final links = ref.watch(paymentLinksProvider).value ?? [];
  return links.where((l) => l.isActive).toList();
});

/// Payment link actions delegate.
final paymentLinkActionsProvider = Provider((ref) => ref.watch(paymentLinksServiceProvider));

/// Adapter: wraps raw list for views needing .links / .currentLink.
class PaymentLinksState {
  final bool isLoading;
  final String? error;
  final List<PaymentLink> links;
  PaymentLink? get currentLink => links.isNotEmpty ? links.first : null;
  const PaymentLinksState({this.isLoading = false, this.error, this.links = const []});
}

final paymentLinksStateProvider = Provider<PaymentLinksState>((ref) {
  final async = ref.watch(paymentLinksProvider);
  return PaymentLinksState(
    isLoading: async.isLoading,
    error: async.error?.toString(),
    links: async.value ?? [],
  );
});
