import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/features/payment_links/models/index.dart';

class PaymentLinksService {
  final Dio _dio;

  PaymentLinksService(this._dio);

  /// Create a new payment link
  Future<PaymentLink> createLink(CreateLinkRequest request) async {
    final response = await _dio.post('/payment-links', data: request.toJson());
    return PaymentLink.fromJson(_extractPaymentLink(response.data));
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
    final data = response.data;
    final List items;
    if (data is Map) {
      items =
          _firstList(data, const ['links', 'data', 'items', 'results']) ??
          const [];
    } else if (data is List) {
      items = data;
    } else {
      items = [];
    }
    return items.map((json) => PaymentLink.fromJson(json)).toList();
  }

  /// Get a specific payment link by ID
  Future<PaymentLink> getLink(String id) async {
    final response = await _dio.get('/payment-links/$id');
    return PaymentLink.fromJson(_extractPaymentLink(response.data));
  }

  /// Cancel a payment link
  Future<void> cancelLink(String id) async {
    await _dio.patch('/payment-links/$id/cancel');
  }

  /// Refresh link status (check for updates)
  Future<PaymentLink> refreshLink(String id) async {
    final response = await _dio.get('/payment-links/$id/refresh');
    return PaymentLink.fromJson(_extractPaymentLink(response.data));
  }

  /// Get a payment link by short code (for paying)
  Future<PaymentLink> getLinkByCode(String shortCode) async {
    final response = await _dio.get('/payment-links/code/$shortCode');
    return PaymentLink.fromJson(_extractPaymentLink(response.data));
  }

  /// Pay a payment link
  Future<PaymentResponse> payLink(
    String shortCode, {
    double? amount,
    required String pinToken,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/payment-links/code/$shortCode/pay',
      data: {if (amount != null) 'amount': amount},
      options: Options(
        headers: transactionHeaders(
          pinToken: pinToken,
          idempotencyKey: idempotencyKey,
        ),
      ),
    );
    return PaymentResponse.fromJson(response.data);
  }

  // Aliases used by views
  Future<List<PaymentLink>> getPaymentLinks() => getLinks();
  Future<PaymentLink> createPaymentLink({
    double? amount,
    String? currency,
    String? description,
    Map<String, dynamic>? data,
  }) async {
    final payload =
        data ??
        {
          'amount': amount,
          'currency': currency ?? 'USDC',
          'description': description,
        };
    final response = await _dio.post('/payment-links', data: payload);
    return PaymentLink.fromJson(_extractPaymentLink(response.data));
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
      amount: _readAmount(json, ['amountDecimal', 'amount']),
      status: json['status'] as String,
    );
  }
}

double _readAmount(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

Map<String, dynamic> _extractPaymentLink(Object? data) {
  final value = data is Map
      ? (data['link'] ?? data['paymentLink'] ?? data['data'] ?? data)
      : data;
  return _asStringMap(value);
}

List<dynamic>? _firstList(Map<dynamic, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value is List<dynamic>) return value;
  }
  return null;
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected payment link JSON object');
}
