import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/payment_link.dart';
import '../../../services/api/api_client.dart';

/// Payment links list provider.
final paymentLinksProvider =
    FutureProvider<List<PaymentLink>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 2), () => link.close());

  final response = await dio.get('/payment-links');
  final data = response.data as Map<String, dynamic>;
  final items = data['data'] as List? ?? [];
  return items
      .map((e) => PaymentLink.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Active payment links only.
final activePaymentLinksProvider = Provider<List<PaymentLink>>((ref) {
  final links = ref.watch(paymentLinksProvider).valueOrNull ?? [];
  return links.where((l) => l.isActive).toList();
});

/// Payment link actions.
class PaymentLinkActions {
  final Dio _dio;

  PaymentLinkActions(this._dio);

  Future<PaymentLink> create({
    required double amount,
    String? description,
    String? recipientName,
    Duration? expiry,
  }) async {
    final response = await _dio.post('/payment-links', data: {
      'amount': amount,
      if (description != null) 'description': description,
      if (recipientName != null) 'recipientName': recipientName,
      if (expiry != null) 'expiresInHours': expiry.inHours,
    });
    return PaymentLink.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancel(String linkId) async {
    await _dio.patch('/payment-links/$linkId/cancel');
  }
}

final paymentLinkActionsProvider = Provider<PaymentLinkActions>((ref) {
  return PaymentLinkActions(ref.watch(dioProvider));
});
