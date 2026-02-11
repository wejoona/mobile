import 'package:dio/dio.dart';
import 'package:usdc_wallet/features/payment_links/models/index.dart';

class PaymentLinksService {
  final Dio _dio;

  PaymentLinksService(this._dio);

  /// Create a new payment link
  Future<PaymentLink> createLink(CreateLinkRequest request) async {
    final response = await _dio.post('/payment-links', data: request.toJson());
    return PaymentLink.fromJson(response.data);
  }

  /// Get all payment links for the current user
  Future<List<PaymentLink>> getLinks({
    PaymentLinkStatus? status,
    int? limit,
    int? offset,
  }) async {
    final response = await _dio.get(
      '/payment-links',
      queryParameters: {
        if (status != null) 'status': status.toJson(),
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
    return (response.data['links'] as List)
        .map((json) => PaymentLink.fromJson(json))
        .toList();
  }

  /// Get a specific payment link by ID
  Future<PaymentLink> getLink(String id) async {
    final response = await _dio.get('/payment-links/$id');
    return PaymentLink.fromJson(response.data);
  }

  /// Cancel a payment link
  Future<void> cancelLink(String id) async {
    await _dio.patch('/payment-links/$id/cancel');
  }

  /// Refresh link status (check for updates)
  Future<PaymentLink> refreshLink(String id) async {
    final response = await _dio.get('/payment-links/$id/refresh');
    return PaymentLink.fromJson(response.data);
  }

  /// Get a payment link by short code (for paying)
  Future<PaymentLink> getLinkByCode(String shortCode) async {
    final response = await _dio.get('/payment-links/code/$shortCode');
    return PaymentLink.fromJson(response.data);
  }

  /// Pay a payment link
  Future<PaymentResponse> payLink(String shortCode) async {
    final response = await _dio.post('/payment-links/code/$shortCode/pay');
    return PaymentResponse.fromJson(response.data);
  }

  // Aliases used by views
  Future<List<PaymentLink>> getPaymentLinks() => getLinks();
  Future<PaymentLink> createPaymentLink({double? amount, String? currency, String? description, Map<String, dynamic>? data}) async {
    final payload = data ?? {'amount': amount, 'currency': currency ?? 'USDC', 'description': description};
    final response = await _dio.post('/payment-links', data: payload);
    return PaymentLink.fromJson(response.data);
  }
  Future<PaymentLink> loadLink(String linkId) => getLink(linkId);
}

/// Response from paying a link
class PaymentResponse {
  final String transactionId;
  final double amount;
  final String status;

  const PaymentResponse({
    required this.transactionId,
    required this.amount,
    required this.status,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}
