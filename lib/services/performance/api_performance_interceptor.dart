import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'performance_service.dart';
import '../../utils/logger.dart';

/// API Performance Interceptor Provider
final apiPerformanceInterceptorProvider = Provider<ApiPerformanceInterceptor>((ref) {
  final performanceService = ref.watch(performanceServiceProvider);
  return ApiPerformanceInterceptor(performanceService);
});

/// Dio interceptor for tracking API performance
class ApiPerformanceInterceptor extends Interceptor {
  final PerformanceService _performanceService;
  static final _logger = AppLogger('ApiPerformance');

  // Store request start times
  final Map<RequestOptions, DateTime> _requestStartTimes = {};

  ApiPerformanceInterceptor(this._performanceService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Record request start time
    _requestStartTimes[options] = DateTime.now();

    // Start performance trace
    final endpoint = _getEndpointName(options);
    _performanceService.startTrace(
      'api_$endpoint',
      type: MetricType.apiCall,
      attributes: {
        'method': options.method,
        'endpoint': endpoint,
        'path': options.path,
      },
    );

    _logger.debug('API Request: ${options.method} $endpoint');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _trackApiCall(response.requestOptions, statusCode: response.statusCode, isError: false);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _trackApiCall(
      err.requestOptions,
      statusCode: err.response?.statusCode,
      isError: true,
      errorType: err.type.name,
    );
    super.onError(err, handler);
  }

  void _trackApiCall(
    RequestOptions options, {
    int? statusCode,
    required bool isError,
    String? errorType,
  }) {
    final startTime = _requestStartTimes.remove(options);
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime);
    final endpoint = _getEndpointName(options);

    // Track with performance service
    _performanceService.trackApiCall(
      endpoint,
      duration,
      statusCode: statusCode,
      isError: isError,
    );

    // Stop trace with additional attributes
    _performanceService.stopTrace(
      'api_$endpoint',
      additionalAttributes: {
        'status_code': statusCode ?? 0,
        'is_error': isError,
        if (errorType != null) 'error_type': errorType,
        'duration_ms': duration.inMilliseconds,
      },
    );

    // Log results
    if (isError) {
      _logger.warn(
        'API Error: ${options.method} $endpoint - ${duration.inMilliseconds}ms (${statusCode ?? errorType})',
      );
    } else {
      _logger.debug(
        'API Success: ${options.method} $endpoint - ${duration.inMilliseconds}ms ($statusCode)',
      );
    }
  }

  String _getEndpointName(RequestOptions options) {
    // Extract clean endpoint name from path
    final path = options.path;

    // Remove leading slash
    var endpoint = path.startsWith('/') ? path.substring(1) : path;

    // Replace path parameters with placeholders
    endpoint = endpoint.replaceAllMapped(
      RegExp(r'/[0-9a-f-]{8,}'),
      (match) => '/{id}',
    );

    // Replace query parameters
    if (options.queryParameters.isNotEmpty) {
      endpoint = '$endpoint?...';
    }

    return endpoint;
  }

  /// Get performance summary for specific endpoint
  Map<String, dynamic> getEndpointStats(String endpoint) {
    final metrics = _performanceService.getApiMetrics(endpoint);

    if (metrics.isEmpty) {
      return {
        'endpoint': endpoint,
        'total_calls': 0,
        'avg_duration_ms': 0,
        'error_rate': 0,
      };
    }

    final totalCalls = metrics.length;
    final errorCalls = metrics.where((m) => m.attributes?['is_error'] == true).length;
    final totalDuration = metrics.fold<int>(
      0,
      (sum, m) => sum + (m.duration?.inMilliseconds ?? 0),
    );

    return {
      'endpoint': endpoint,
      'total_calls': totalCalls,
      'avg_duration_ms': totalDuration ~/ totalCalls,
      'error_rate': (errorCalls / totalCalls * 100).toStringAsFixed(1),
      'success_calls': totalCalls - errorCalls,
      'error_calls': errorCalls,
    };
  }

  /// Get all API performance stats
  Map<String, dynamic> getAllStats() {
    final apiMetrics = _performanceService.getMetrics(type: MetricType.apiCall);

    if (apiMetrics.isEmpty) {
      return {
        'total_calls': 0,
        'avg_duration_ms': 0,
        'error_rate': 0,
      };
    }

    final totalCalls = apiMetrics.length;
    final errorCalls = apiMetrics.where((m) => m.attributes?['is_error'] == true).length;
    final totalDuration = apiMetrics.fold<int>(
      0,
      (sum, m) => sum + (m.duration?.inMilliseconds ?? 0),
    );

    // Group by endpoint
    final endpointMap = <String, List<PerformanceMetric>>{};
    for (final metric in apiMetrics) {
      final endpoint = metric.attributes?['endpoint'] as String? ?? 'unknown';
      endpointMap.putIfAbsent(endpoint, () => []).add(metric);
    }

    // Find slowest endpoints
    final slowestEndpoints = endpointMap.entries
        .map((e) {
          final avgDuration = e.value.fold<int>(
                0,
                (sum, m) => sum + (m.duration?.inMilliseconds ?? 0),
              ) ~/
              e.value.length;
          return {'endpoint': e.key, 'avg_duration_ms': avgDuration};
        })
        .toList()
      ..sort((a, b) => (b['avg_duration_ms'] as int).compareTo(a['avg_duration_ms'] as int));

    return {
      'total_calls': totalCalls,
      'avg_duration_ms': totalDuration ~/ totalCalls,
      'error_rate': (errorCalls / totalCalls * 100).toStringAsFixed(1),
      'success_calls': totalCalls - errorCalls,
      'error_calls': errorCalls,
      'unique_endpoints': endpointMap.length,
      'slowest_endpoints': slowestEndpoints.take(5).toList(),
    };
  }
}
