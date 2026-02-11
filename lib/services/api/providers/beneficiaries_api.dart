/// Beneficiaries API — CRUD
library;

import 'package:dio/dio.dart';

class BeneficiariesApi {
  BeneficiariesApi(this._dio);
  final Dio _dio;

  /// GET /beneficiaries
  Future<Response> list() => _dio.get('/beneficiaries');

  /// POST /beneficiaries
  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/beneficiaries', data: data);

  /// GET /beneficiaries/:id
  Future<Response> getById(String id) => _dio.get('/beneficiaries/$id');

  /// DELETE /beneficiaries/:id
  Future<Response> delete(String id) => _dio.delete('/beneficiaries/$id');
}
