/// Payment Links API — CRUD, pay, deactivate
library;

import 'package:dio/dio.dart';

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

  /// POST /payment-links/:id/pay
  Future<Response> pay(String id, Map<String, dynamic> data) =>
      _dio.post('/payment-links/$id/pay', data: data);

  /// POST /payment-links/:id/deactivate
  Future<Response> deactivate(String id) =>
      _dio.post('/payment-links/$id/deactivate');
}
