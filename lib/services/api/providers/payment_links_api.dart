/// Payment Links API — CRUD, pay, deactivate
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';

class PaymentLinksApi {
  PaymentLinksApi(this._dio);
  final Dio _dio;

  /// GET /payment-links
  Future<Response> list() => _dio.get('/payment-links');

  /// POST /payment-links
  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/payment-links', data: data);

  /// GET /payment-links/:id
  Future<Response> getById(String id) => _dio.get('/payment-links/$id');

  /// POST /payment-links/code/:code/pay
  Future<Response> payByCode(
    String code,
    Map<String, dynamic> data, {
    required String pinToken,
    required String idempotencyKey,
  }) => _dio.post(
    '/payment-links/code/$code/pay',
    data: data,
    options: Options(
      headers: transactionHeaders(
        pinToken: pinToken,
        idempotencyKey: idempotencyKey,
      ),
    ),
  );

  /// POST /payment-links/code/:code/pay
  Future<Response> pay(
    String code,
    Map<String, dynamic> data, {
    required String pinToken,
    required String idempotencyKey,
  }) =>
      payByCode(code, data, pinToken: pinToken, idempotencyKey: idempotencyKey);

  /// PATCH /payment-links/:id/cancel
  Future<Response> deactivate(String id) =>
      _dio.patch('/payment-links/$id/cancel');
}
