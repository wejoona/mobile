/// Config API — public endpoints (no auth required)
library;

import 'package:dio/dio.dart';

class ConfigApi {
  ConfigApi(this._dio);
  final Dio _dio;

  /// GET /config/countries — list of supported countries
  Future<Response> getCountries() => _dio.get('/config/countries');
}
