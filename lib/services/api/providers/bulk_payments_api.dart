/// Bulk Payments API — create, list, get
library;

import 'package:dio/dio.dart';

class BulkPaymentsApi {
  BulkPaymentsApi(this._dio);
  final Dio _dio;

  /// GET /bulk-payments/batches
  Future<Response> list() => _dio.get('/bulk-payments/batches');

  /// POST /bulk-payments/batches
  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/bulk-payments/batches', data: data);

  /// GET /bulk-payments/batches/:id
  Future<Response> getById(String id) => _dio.get('/bulk-payments/batches/$id');
}
