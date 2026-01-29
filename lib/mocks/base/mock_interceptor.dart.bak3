/// Mock Interceptor
///
/// Dio interceptor that intercepts API calls and returns mock data
/// based on the registered mock handlers.
library;

import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../mock_config.dart';
import 'api_contract.dart';

/// Type definition for mock handlers
typedef MockHandler = Future<MockResponse<dynamic>> Function(
  RequestOptions options,
);

/// Mock interceptor for Dio
class MockInterceptor extends Interceptor {
  /// Registered mock handlers by path pattern
  final Map<String, Map<String, MockHandler>> _handlers = {};

  /// Random for simulating failures
  final _random = Random();

  /// Register a mock handler for a specific endpoint
  void register({
    required String method,
    required String path,
    required MockHandler handler,
  }) {
    _handlers[method.toUpperCase()] ??= {};
    _handlers[method.toUpperCase()]![path] = handler;

    if (kDebugMode) {
      print('[MockInterceptor] Registered: ${method.toUpperCase()} $path');
    }
  }

  /// Register handlers from a contract
  void registerContract(
    ApiContract contract,
    Map<ApiEndpoint, MockHandler> handlers,
  ) {
    for (final entry in handlers.entries) {
      final endpoint = entry.key;
      final handler = entry.value;
      final fullPath = '${contract.basePath}${endpoint.path}';
      register(
        method: endpoint.method.name,
        path: fullPath,
        handler: handler,
      );
    }
  }

  /// Unregister all handlers
  void clear() {
    _handlers.clear();
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if mocking is enabled
    if (!MockConfig.useMocks) {
      handler.next(options);
      return;
    }

    // Find matching handler
    final mockHandler = _findHandler(options.method, options.path);

    if (mockHandler == null) {
      // No mock handler, pass through to real API
      if (kDebugMode) {
        print('[MockInterceptor] No handler for ${options.method} ${options.path}, passing through');
      }
      handler.next(options);
      return;
    }

    try {
      // Simulate network delay
      if (MockConfig.networkDelayMs > 0) {
        await Future.delayed(Duration(milliseconds: MockConfig.networkDelayMs));
      }

      // Simulate random failures
      if (MockConfig.simulateRandomFailures &&
          _random.nextDouble() < MockConfig.failureRate) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'Simulated network failure',
        );
      }

      // Call the mock handler
      final mockResponse = await mockHandler(options);

      if (kDebugMode) {
        print('[MockInterceptor] ${options.method} ${options.path} -> ${mockResponse.statusCode}');
      }

      // Apply additional delay if specified
      if (mockResponse.delay.inMilliseconds > 0) {
        await Future.delayed(mockResponse.delay);
      }

      // Return mock response
      if (mockResponse.isSuccess) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: mockResponse.statusCode,
          data: mockResponse.data,
          headers: Headers.fromMap(
            mockResponse.headers?.map((k, v) => MapEntry(k, [v])) ?? {},
          ),
        ));
      } else {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: mockResponse.statusCode,
            data: {'error': mockResponse.errorMessage},
          ),
          type: DioExceptionType.badResponse,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('[MockInterceptor] Error: $e');
      }
      handler.reject(DioException(
        requestOptions: options,
        error: e,
        type: DioExceptionType.unknown,
      ));
    }
  }

  /// Find a handler matching the request
  MockHandler? _findHandler(String method, String path) {
    final methodHandlers = _handlers[method.toUpperCase()];
    if (methodHandlers == null) return null;

    // Try exact match first
    if (methodHandlers.containsKey(path)) {
      return methodHandlers[path];
    }

    // Try pattern matching (for paths with parameters)
    for (final entry in methodHandlers.entries) {
      final pattern = entry.key;
      if (_matchesPattern(pattern, path)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Check if a path matches a pattern (with :param placeholders)
  bool _matchesPattern(String pattern, String path) {
    // Convert pattern to regex
    // e.g., '/users/:id/transactions' -> '/users/[^/]+/transactions'
    final regexPattern = pattern
        .replaceAll('/', '\\/')
        .replaceAll(RegExp(r':[^/]+'), '[^/]+');

    final regex = RegExp('^$regexPattern\$');
    return regex.hasMatch(path);
  }

  /// Extract path parameters from a path
  Map<String, String> extractPathParams(String pattern, String path) {
    final params = <String, String>{};
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');

    if (patternParts.length != pathParts.length) return params;

    for (var i = 0; i < patternParts.length; i++) {
      if (patternParts[i].startsWith(':')) {
        final paramName = patternParts[i].substring(1);
        params[paramName] = pathParts[i];
      }
    }

    return params;
  }
}

/// Extension to extract path parameters from RequestOptions
extension RequestOptionsExtension on RequestOptions {
  /// Extract path parameters based on a pattern
  Map<String, String> extractPathParams(String pattern) {
    final params = <String, String>{};
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');

    if (patternParts.length != pathParts.length) return params;

    for (var i = 0; i < patternParts.length; i++) {
      if (patternParts[i].startsWith(':')) {
        final paramName = patternParts[i].substring(1);
        params[paramName] = pathParts[i];
      }
    }

    return params;
  }
}
