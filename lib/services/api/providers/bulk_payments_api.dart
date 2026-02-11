/// Bulk Payments API — create, list, get
library;

import 'package:dio/dio.dart';

class BulkPaymentsApi {
  BulkPaymentsApi(this._dio);
  final Dio _dio;

  /// GET /bulk-payments
  Future<Response> list() => _dio.get('/bulk-payments');

  /// POST /bulk-payments
  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/bulk-payments', data: data);

  /// GET /bulk-payments/:id
  Future<Response> getById(String id) => _dio.get('/bulk-payments/$id');
}
