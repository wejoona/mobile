import 'dart:async';
import 'package:dio/dio.dart';
import '../../utils/logger.dart';

/// Retry interceptor for transient network failures.
/// Retries GET requests up to [maxRetries] times with exponential backoff.
/// POST/PUT/DELETE are NOT retried to avoid duplicate side effects.
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;
  final Dio dio;
  final _logger = AppLogger('RetryInterceptor');

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.initialDelay = const Duration(milliseconds: 500),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry idempotent requests (GET, HEAD, OPTIONS)
    final method = err.requestOptions.method.toUpperCase();
    if (!['GET', 'HEAD', 'OPTIONS'].contains(method)) {
      return handler.next(err);
    }

    // Only retry on network/timeout errors
    if (!_isRetryable(err)) {
      return handler.next(err);
    }

    final retryCount = err.requestOptions.extra['_retryCount'] as int? ?? 0;
    if (retryCount >= maxRetries) {
      _logger.debug('Max retries ($maxRetries) reached for ${err.requestOptions.path}');
      return handler.next(err);
    }

    final delay = initialDelay * (1 << retryCount); // Exponential backoff
    _logger.debug(
      'Retrying ${err.requestOptions.path} (attempt ${retryCount + 1}/$maxRetries) after ${delay.inMilliseconds}ms',
    );

    await Future.delayed(delay);

    try {
      err.requestOptions.extra['_retryCount'] = retryCount + 1;
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _isRetryable(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        // Retry on 502, 503, 504 (server temporarily unavailable)
        return statusCode != null && [502, 503, 504].contains(statusCode);
      default:
        return false;
    }
  }
}
