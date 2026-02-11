/// Cards API — CRUD, freeze/unfreeze, transactions
library;

import 'package:dio/dio.dart';

class CardsApi {
  CardsApi(this._dio);
  final Dio _dio;

  /// GET /cards
  Future<Response> list() => _dio.get('/cards');

  /// POST /cards — create virtual card
  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/cards', data: data);

  /// GET /cards/:id
  Future<Response> getById(String id) => _dio.get('/cards/$id');

  /// DELETE /cards/:id
  Future<Response> delete(String id) => _dio.delete('/cards/$id');

  /// POST /cards/:id/freeze
  Future<Response> freeze(String id) => _dio.post('/cards/$id/freeze');

  /// POST /cards/:id/unfreeze
  Future<Response> unfreeze(String id) => _dio.post('/cards/$id/unfreeze');

  /// GET /cards/:id/transactions
  Future<Response> transactions(String id) =>
      _dio.get('/cards/$id/transactions');
}
