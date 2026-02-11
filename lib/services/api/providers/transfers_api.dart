/// Transfers API — internal, external, history
library;

import 'package:dio/dio.dart';

class TransfersApi {
  TransfersApi(this._dio);
  final Dio _dio;

  /// POST /transfers/internal
  Future<Response> sendInternal(Map<String, dynamic> data) =>
      _dio.post('/transfers/internal', data: data);

  /// POST /transfers/external
  Future<Response> sendExternal(Map<String, dynamic> data) =>
      _dio.post('/transfers/external', data: data);

  /// GET /transfers — list transfer history
  Future<Response> list({int? page, int? limit}) =>
      _dio.get('/transfers', queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      });

  /// GET /transfers/:id
  Future<Response> getById(String id) => _dio.get('/transfers/$id');
}
