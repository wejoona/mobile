/// Devices API — register, list, sessions
library;

import 'package:dio/dio.dart';

class DevicesApi {
  DevicesApi(this._dio);
  final Dio _dio;

  /// POST /devices/register
  Future<Response> register(Map<String, dynamic> data) =>
      _dio.post('/devices/register', data: data);

  /// GET /devices
  Future<Response> list() => _dio.get('/devices');

  /// GET /devices/:id
  Future<Response> getById(String id) => _dio.get('/devices/$id');

  /// DELETE /devices/:id
  Future<Response> delete(String id) => _dio.delete('/devices/$id');

  /// GET /sessions — active sessions
  Future<Response> listSessions() => _dio.get('/sessions');

  /// DELETE /sessions/:id — revoke session
  Future<Response> revokeSession(String id) => _dio.delete('/sessions/$id');
}
