/// Config API — public endpoints (no auth required)
library;

import 'package:dio/dio.dart';

class ConfigApi {
  ConfigApi(this._dio);
  final Dio _dio;

  /// GET /config/countries — list of supported countries
  Future<Response> getCountries() => _dio.get('/config/countries');

  /// GET /config/mobile-version — mobile upgrade policy
  Future<Response> getMobileVersionPolicy({
    required String platform,
    required String version,
    required String buildNumber,
  }) {
    return _dio.get(
      '/config/mobile-version',
      queryParameters: {
        'platform': platform,
        'version': version,
        'buildNumber': buildNumber,
      },
    );
  }
}
