/// Savings Pots API — CRUD, deposit, withdraw
library;

import 'package:dio/dio.dart';

class SavingsPotsApi {
  SavingsPotsApi(this._dio);
  final Dio _dio;

  /// GET /savings-pots
  Future<Response> list() => _dio.get('/savings-pots');

  /// POST /savings-pots
  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/savings-pots', data: data);

  /// GET /savings-pots/:id
  Future<Response> getById(String id) => _dio.get('/savings-pots/$id');

  /// DELETE /savings-pots/:id
  Future<Response> delete(String id) => _dio.delete('/savings-pots/$id');

  /// POST /savings-pots/:id/deposit
  Future<Response> deposit(String id, {required double amount}) =>
      _dio.post('/savings-pots/$id/deposit', data: {'amount': amount});

  /// POST /savings-pots/:id/withdraw
  Future<Response> withdraw(String id, {required double amount}) =>
      _dio.post('/savings-pots/$id/withdraw', data: {'amount': amount});
}
