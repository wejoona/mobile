import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Request deduplication interceptor for Dio.
///
/// Prevents duplicate simultaneous requests to the same endpoint.
/// When multiple requests to the same URL are made simultaneously,
/// only one network request is made and the response is shared.
///
/// ## Use Cases
/// - Multiple widgets loading the same data on mount
/// - Pull-to-refresh triggered multiple times quickly
/// - User double-tapping a button
///
/// ## Usage
///
/// ```dart
/// final dedupeInterceptor = DeduplicationInterceptor();
///
/// // Add as FIRST interceptor (before cache, auth, etc.)
/// dio.interceptors.insert(0, dedupeInterceptor);
///
/// // Check stats
/// print(dedupeInterceptor.stats);
///
/// // Clear in-flight requests (e.g., on logout)
/// dedupeInterceptor.clear();
/// ```
class DeduplicationInterceptor extends Interceptor {
  /// In-flight requests by key.
  final Map<String, Completer<Response>> _inFlight = {};

  /// Counter for deduplicated requests.
  int _deduplicatedCount = 0;

  /// Total requests processed.
  int _totalCount = 0;

  /// Whether to log activity (debug mode only).
  final bool enableLogging;

  /// HTTP methods to deduplicate (default: GET only).
  final Set<String> deduplicateMethods;

  DeduplicationInterceptor({
    this.enableLogging = true,
    this.deduplicateMethods = const {'GET'},
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _totalCount++;

    // Only deduplicate configured methods
    if (!deduplicateMethods.contains(options.method.toUpperCase())) {
      handler.next(options);
      return;
    }

    final key = _generateKey(options);

    // Check if request is already in flight
    if (_inFlight.containsKey(key)) {
      _deduplicatedCount++;
      _log('DEDUPE: Waiting for in-flight request: ${options.path}');

      try {
        // Wait for the in-flight request to complete
        final response = await _inFlight[key]!.future;

        // Return a copy of the response
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: response.statusCode,
            data: response.data,
            headers: response.headers,
          ),
          true,
        );
      } catch (e) {
        // If the original request failed, propagate the error
        if (e is DioException) {
          handler.reject(DioException(
            requestOptions: options,
            error: e.error,
            type: e.type,
            response: e.response,
          ));
        } else {
          handler.reject(DioException(
            requestOptions: options,
            error: e,
            type: DioExceptionType.unknown,
          ));
        }
      }
      return;
    }

    // First request - create completer and proceed
    _inFlight[key] = Completer<Response>();
    _log('REQUEST: ${options.path} (in-flight: ${_inFlight.length})');

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    final key = _generateKey(response.requestOptions);

    // Complete the in-flight request
    if (_inFlight.containsKey(key)) {
      final completer = _inFlight.remove(key);
      if (completer != null && !completer.isCompleted) {
        completer.complete(response);
      }
      _log('COMPLETE: ${response.requestOptions.path}');
    }

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final key = _generateKey(err.requestOptions);

    // Complete the in-flight request with error
    if (_inFlight.containsKey(key)) {
      final completer = _inFlight.remove(key);
      if (completer != null && !completer.isCompleted) {
        completer.completeError(err);
      }
      _log('ERROR: ${err.requestOptions.path}');
    }

    handler.next(err);
  }

  /// Generate unique key for a request.
  String _generateKey(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.write(options.method);
    buffer.write(':');
    buffer.write(options.uri.toString());
    return buffer.toString();
  }

  void _log(String message) {
    if (enableLogging && kDebugMode) {
      debugPrint('[DeduplicationInterceptor] $message');
    }
  }

  // ============================================
  // MANAGEMENT
  // ============================================

  /// Clear all in-flight requests.
  ///
  /// Useful when logging out or resetting state.
  /// Pending completers will be completed with a cancellation error.
  void clear() {
    for (final entry in _inFlight.entries) {
      if (!entry.value.isCompleted) {
        entry.value.completeError(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Request cancelled: interceptor cleared',
            type: DioExceptionType.cancel,
          ),
        );
      }
    }
    _inFlight.clear();
    _log('Cleared all in-flight requests');
  }

  /// Number of currently in-flight requests.
  int get inFlightCount => _inFlight.length;

  /// List of currently in-flight request keys.
  List<String> get inFlightRequests => _inFlight.keys.toList();

  /// Get statistics.
  DeduplicationStats get stats => DeduplicationStats(
        total: _totalCount,
        deduplicated: _deduplicatedCount,
        inFlight: _inFlight.length,
      );

  /// Reset statistics.
  void resetStats() {
    _totalCount = 0;
    _deduplicatedCount = 0;
  }
}

/// Deduplication statistics.
class DeduplicationStats {
  final int total;
  final int deduplicated;
  final int inFlight;

  const DeduplicationStats({
    required this.total,
    required this.deduplicated,
    required this.inFlight,
  });

  /// Actual network requests made.
  int get networkRequests => total - deduplicated;

  /// Deduplication rate (0.0 to 1.0).
  double get deduplicationRate => total > 0 ? deduplicated / total : 0.0;

  /// Deduplication rate as percentage string.
  String get deduplicationRatePercent =>
      '${(deduplicationRate * 100).toStringAsFixed(1)}%';

  /// Requests saved (not made due to deduplication).
  int get requestsSaved => deduplicated;

  @override
  String toString() {
    return 'DeduplicationStats(total: $total, deduplicated: $deduplicated, rate: $deduplicationRatePercent)';
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'deduplicated': deduplicated,
        'networkRequests': networkRequests,
        'deduplicationRate': deduplicationRate,
        'inFlight': inFlight,
      };
}
