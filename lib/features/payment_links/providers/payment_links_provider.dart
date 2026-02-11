import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/payment_link.dart';
import 'package:usdc_wallet/services/service_providers.dart';

/// Payment links list provider — wired to PaymentLinksService.
final paymentLinksProvider = FutureProvider<List<PaymentLink>>((ref) async {
  final service = ref.watch(paymentLinksServiceProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 2), () => link.close());

  final data = await service.getPaymentLinks();
  final items = (data['data'] as List?) ?? [];
  return items.map((e) => PaymentLink.fromJson(e as Map<String, dynamic>)).toList();
});

/// Active payment links only.
final activePaymentLinksProvider = Provider<List<PaymentLink>>((ref) {
  final links = ref.watch(paymentLinksProvider).valueOrNull ?? [];
  return links.where((l) => l.isActive).toList();
});

/// Payment link actions delegate.
final paymentLinkActionsProvider = Provider((ref) => ref.watch(paymentLinksServiceProvider));
