import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';
import '../models/index.dart';

/// Payment Links Repository
class PaymentLinksRepository {
  final Dio _dio;

  PaymentLinksRepository(this._dio);

  /// Get all payment links
  Future<List<PaymentLink>> getPaymentLinks() async {
    final response = await _dio.get('/payment-links');
    return (response.data['payment_links'] as List)
        .map((json) => PaymentLink.fromJson(json))
        .toList();
  }

  /// Get single payment link
  Future<PaymentLink> getPaymentLink(String id) async {
    final response = await _dio.get('/payment-links/$id');
    return PaymentLink.fromJson(response.data);
  }

  /// Create payment link
  Future<PaymentLink> createPaymentLink(CreateLinkRequest request) async {
    final response = await _dio.post(
      '/payment-links',
      data: request.toJson(),
    );
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
