/// Expenses API — CRUD, categories, report
library;

import 'package:dio/dio.dart';

class ExpensesApi {
  ExpensesApi(this._dio);
  final Dio _dio;

  /// GET /expenses
  Future<Response> list() => _dio.get('/expenses');

  /// POST /expenses
  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/expenses', data: data);

  /// GET /expenses/:id
  Future<Response> getById(String id) => _dio.get('/expenses/$id');

  /// DELETE /expenses/:id
  Future<Response> delete(String id) => _dio.delete('/expenses/$id');

  /// GET /expenses/categories
  Future<Response> categories() => _dio.get('/expenses/categories');

  /// GET /expenses/report
  Future<Response> report() => _dio.get('/expenses/report');
}
