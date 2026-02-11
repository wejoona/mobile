/// Bill Payments API — providers, categories, validate, pay, history
library;

import 'package:dio/dio.dart';

class BillPaymentsApi {
  BillPaymentsApi(this._dio);
  final Dio _dio;

  /// GET /bill-payments/providers
  Future<Response> getProviders() => _dio.get('/bill-payments/providers');

  /// GET /bill-payments/categories
  Future<Response> getCategories() => _dio.get('/bill-payments/categories');

  /// POST /bill-payments/validate
  Future<Response> validate(Map<String, dynamic> data) =>
      _dio.post('/bill-payments/validate', data: data);

  /// POST /bill-payments/pay
  Future<Response> pay(Map<String, dynamic> data) =>
      _dio.post('/bill-payments/pay', data: data);

  /// GET /bill-payments/history
  Future<Response> history() => _dio.get('/bill-payments/history');

  /// GET /bill-payments/:id/receipt
  Future<Response> getReceipt(String id) =>
      _dio.get('/bill-payments/$id/receipt');
}
