import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// In-flight request tracker
class InFlightRequest {
  final Completer<Response> completer;
  final DateTime startedAt;
  int waiters;

  InFlightRequest({
    required this.completer,
    required this.startedAt,
    this.waiters = 0,
  });
}

/// Request Deduplication Interceptor
/// Prevents duplicate identical requests from being sent simultaneously
/// Returns the same Future for duplicate requests
class RequestDeduplicationInterceptor extends Interceptor {
  final Map<String, InFlightRequest> _inFlightRequests = {};
  final Duration _timeout;

  RequestDeduplicationInterceptor({
    Duration timeout = const Duration(seconds: 30),
  }) : _timeout = timeout;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only deduplicate GET requests
    if (options.method != 'GET') {
      return handler.next(options);
    }

    final key = _generateKey(options);

    // Check if there's an in-flight request
    final inFlight = _inFlightRequests[key];

    if (inFlight != null) {
      // Check if request hasn't timed out
      final age = DateTime.now().difference(inFlight.startedAt);

      if (age < _timeout) {
        if (kDebugMode) {
          AppLogger('Debug').debug(
            '[DeduplicationInterceptor] Deduplicating request: ${options.path}',
          );
        }

        inFlight.waiters += 1;

        try {
          // Wait for the in-flight request to complete
          final response = await inFlight.completer.future;

          // Return the cached response
          return handler.resolve(
            Response(
              requestOptions: options,
              data: response.data,
              statusCode: response.statusCode,
              statusMessage: response.statusMessage,
              headers: response.headers,
              extra: response.extra,
            ),
            true,
          );
        } catch (e) {
          // If the in-flight request failed, proceed with a new request
          if (kDebugMode) {
            AppLogger('Debug').debug(
              '[DeduplicationInterceptor] In-flight request failed, retrying: ${options.path}',
            );
          }
          _inFlightRequests.remove(key);
        } finally {
          inFlight.waiters -= 1;
        }
      } else {
        // Request timed out, remove it
        if (kDebugMode) {
          AppLogger('Debug').debug(
            '[DeduplicationInterceptor] In-flight request timed out: ${options.path}',
          );
        }
        _inFlightRequests.remove(key);
      }
    }

    // Create new in-flight request tracker
    _inFlightRequests[key] = InFlightRequest(
      completer: Completer<Response>(),
      startedAt: DateTime.now(),
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only handle GET requests
    if (response.requestOptions.method == 'GET') {
      final key = _generateKey(response.requestOptions);
      final inFlight = _inFlightRequests[key];

      if (inFlight != null && !inFlight.completer.isCompleted) {
        // Complete the completer with the response
        inFlight.completer.complete(response);

        if (kDebugMode) {
          AppLogger('Debug').debug(
            '[DeduplicationInterceptor] Request completed: ${response.requestOptions.path}',
          );
        }

        // Clean up after a short delay to allow waiting requests to complete
        Future.delayed(const Duration(milliseconds: 100), () {
          _inFlightRequests.remove(key);
        });
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Only handle GET requests
    if (err.requestOptions.method == 'GET') {
      final key = _generateKey(err.requestOptions);
      final inFlight = _inFlightRequests[key];

      if (inFlight != null) {
        if (inFlight.waiters > 0 && !inFlight.completer.isCompleted) {
          // Complete the completer with error only when duplicate requests are
          // actively waiting for it. Completing an unobserved error creates an
          // uncaught async exception in Dart.
          inFlight.completer.completeError(err);
        }

        if (kDebugMode) {
          AppLogger('Debug').debug(
            '[DeduplicationInterceptor] Request failed: ${err.requestOptions.path}',
          );
        }

        // Clean up immediately on error
        _inFlightRequests.remove(key);
      }
    }

    handler.next(err);
  }

  /// Generate unique key for request
  String _generateKey(RequestOptions options) {
    final queryEntries = options.queryParameters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final queryString = queryEntries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final authKey = _authorizationDedupKey(options.headers['Authorization']);

    return '${options.method}:${options.path}${queryString.isNotEmpty ? '?$queryString' : ''}$authKey';
  }

  String _authorizationDedupKey(Object? authorization) {
    final token = authorization?.toString().trim();
    if (token == null || token.isEmpty) {
      return '';
    }
    return '#auth:${_stableTokenFingerprint(token)}';
  }

  String _stableTokenFingerprint(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16);
  }

  /// Clear all in-flight requests
  void clear() {
    // Complete all pending requests with cancellation error
    for (final entry in _inFlightRequests.entries) {
      if (entry.value.waiters > 0 && !entry.value.completer.isCompleted) {
        entry.value.completer.completeError(
          DioException(
            requestOptions: RequestOptions(path: entry.key),
            type: DioExceptionType.cancel,
            message: 'Request deduplication cleared',
          ),
        );
      }
    }

    _inFlightRequests.clear();

    if (kDebugMode) {
      AppLogger(
        'Debug',
      ).debug('[DeduplicationInterceptor] All in-flight requests cleared');
    }
  }

  /// Get statistics about in-flight requests
  Map<String, dynamic> getStats() {
    final now = DateTime.now();

    return {
      'count': _inFlightRequests.length,
      'requests': _inFlightRequests.entries
          .map(
            (e) => {
              'key': e.key,
              'age': now.difference(e.value.startedAt).inMilliseconds,
              'isCompleted': e.value.completer.isCompleted,
              'waiters': e.value.waiters,
            },
          )
          .toList(),
    };
  }
}
