/// Beneficiaries API — CRUD
library;

import 'package:dio/dio.dart';

class BeneficiariesApi {
  BeneficiariesApi(this._dio);
  final Dio _dio;

  /// GET /beneficiaries
  Future<Response> list({bool? favorites, bool? recent, String? type}) =>
      _dio.get(
        '/beneficiaries',
        queryParameters: {
          if (favorites != null) 'favorites': favorites,
          if (recent != null) 'recent': recent,
          if (type != null) 'type': type,
        },
      );

  /// POST /beneficiaries
  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/beneficiaries', data: data);

  /// GET /beneficiaries/:id
  Future<Response> getById(String id) => _dio.get('/beneficiaries/$id');

  /// PUT /beneficiaries/:id
  Future<Response> update(String id, Map<String, dynamic> data) =>
      _dio.put('/beneficiaries/$id', data: data);

  /// POST /beneficiaries/:id/favorite
  Future<Response> toggleFavorite(String id) =>
      _dio.post('/beneficiaries/$id/favorite');

  /// DELETE /beneficiaries/:id
  Future<Response> delete(String id) => _dio.delete('/beneficiaries/$id');
}
