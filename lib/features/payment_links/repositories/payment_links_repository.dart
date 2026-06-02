import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/payment_links/models/index.dart';

/// Payment Links Repository
class PaymentLinksRepository {
  final Dio _dio;

  PaymentLinksRepository(this._dio);

  /// Get all payment links
  Future<List<PaymentLink>> getPaymentLinks() async {
    final response = await _dio.get('/payment-links');
    final data = response.data;
    final links = data is List
        ? data
        : data is Map
        ? (data['links'] ?? data['payment_links'] ?? data['data']) as List? ??
              []
        : const [];
    return links
        .map((json) => PaymentLink.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  /// Get single payment link
  Future<PaymentLink> getPaymentLink(String id) async {
    final response = await _dio.get('/payment-links/$id');
    return PaymentLink.fromJson(response.data);
  }

  /// Create payment link
  Future<PaymentLink> createPaymentLink(CreateLinkRequest request) async {
    final response = await _dio.post('/payment-links', data: request.toJson());
    return PaymentLink.fromJson(response.data);
  }

  /// Delete payment link
  Future<void> deletePaymentLink(String id) async {
    await _dio.delete('/payment-links/$id');
  }
}

/// Payment Links Repository Provider
final paymentLinksRepositoryProvider = Provider<PaymentLinksRepository>((ref) {
  final dio = ref.read(dioProvider);
  return PaymentLinksRepository(dio);
});
