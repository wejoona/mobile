/// Insights API — spending summary, categories, trends, top recipients
library;

import 'package:dio/dio.dart';

class InsightsApi {
  InsightsApi(this._dio);
  final Dio _dio;

  /// GET /insights
  Future<Response> get() => _dio.get('/insights');

  /// GET /insights/summary
  Future<Response> summary() => _dio.get('/insights/summary');

  /// GET /insights/categories
  Future<Response> categories() => _dio.get('/insights/categories');

  /// GET /insights/top-recipients
  Future<Response> topRecipients() => _dio.get('/insights/top-recipients');

  /// GET /insights/trend
  Future<Response> trend() => _dio.get('/insights/trend');
}
