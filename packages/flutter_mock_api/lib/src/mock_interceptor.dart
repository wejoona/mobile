import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'mock_config.dart';
import 'mock_response.dart';

/// Type definition for mock request handlers.
///
/// Receives the request options and returns a mock response.
typedef MockHandler = Future<MockResponse<dynamic>> Function(
  RequestOptions options,
);

/// Dio interceptor that returns mock responses based on registered handlers.
///
/// Add this interceptor to your Dio instance to enable mocking:
///
/// ```dart
/// final mockInterceptor = MockInterceptor();
///
/// // Register handlers
/// mockInterceptor.register(
///   method: 'GET',
///   path: '/users',
///   handler: (options) async {
///     return MockResponse.success([{'id': '1', 'name': 'John'}]);
///   },
/// );
///
/// // Dynamic routes with path parameters
/// mockInterceptor.register(
///   method: 'GET',
///   path: '/users/:id',
///   handler: (options) async {
///     final params = options.extractPathParams('/users/:id');
///     final id = params['id'];
///     return MockResponse.success({'id': id, 'name': 'User $id'});
///   },
/// );
///
/// // Add to Dio
/// dio.interceptors.add(mockInterceptor);
/// ```
class MockInterceptor extends Interceptor {
  /// Registered handlers by HTTP method and path pattern.
  final Map<String, Map<String, MockHandler>> _handlers = {};

  /// Random instance for failure simulation.
  final _random = Random();

  /// Register a mock handler for a specific endpoint.
  ///
  /// - [method]: HTTP method (GET, POST, PUT, PATCH, DELETE)
  /// - [path]: URL path pattern (supports :param for path parameters)
  /// - [handler]: Function that returns a MockResponse
  void register({
    required String method,
    required String path,
    required MockHandler handler,
  }) {
    final methodUpper = method.toUpperCase();
    _handlers[methodUpper] ??= {};
    _handlers[methodUpper]![path] = handler;

    if (MockConfig.verboseLogging && kDebugMode) {
      debugPrint('[MockInterceptor] Registered: $methodUpper $path');
    }
  }

  /// Register multiple handlers at once.
  void registerAll(Map<String, Map<String, MockHandler>> handlers) {
    handlers.forEach((method, paths) {
      paths.forEach((path, handler) {
        register(method: method, path: path, handler: handler);
      });
    });
  }

  /// Unregister a specific handler.
  void unregister({required String method, required String path}) {
    _handlers[method.toUpperCase()]?.remove(path);
  }

  /// Clear all registered handlers.
  void clear() {
    _handlers.clear();
  }

  /// Get list of all registered endpoints.
  List<String> get registeredEndpoints {
    final endpoints = <String>[];
    _handlers.forEach((method, paths) {
      paths.keys.forEach((path) {
        endpoints.add('$method $path');
      });
    });
    return endpoints;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip if mocking is disabled
    if (!MockConfig.useMocks) {
      handler.next(options);
      return;
    }

    // Find matching handler
    final mockHandler = _findHandler(options.method, options.path);

    if (mockHandler == null) {
      // No handler found, pass through to real API
      if (MockConfig.verboseLogging && kDebugMode) {
        debugPrint(
          '[MockInterceptor] No handler for ${options.method} ${options.path}, passing through',
        );
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
        if (MockConfig.verboseLogging && kDebugMode) {
          debugPrint(
            '[MockInterceptor] Simulated failure for ${options.method} ${options.path}',
          );
        }
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'Simulated network failure',
        );
      }

      // Call the mock handler
      final mockResponse = await mockHandler(options);

      if (MockConfig.verboseLogging && kDebugMode) {
        debugPrint(
          '[MockInterceptor] ${options.method} ${options.path} -> ${mockResponse.statusCode}',
        );
      }

      // Apply response-specific delay
      if (mockResponse.delay.inMilliseconds > 0) {
        await Future.delayed(mockResponse.delay);
      }

      // Return response
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
            data: {
              'error': mockResponse.errorMessage,
              if (mockResponse.data != null) ...mockResponse.data as Map,
            },
          ),
          type: DioExceptionType.badResponse,
        ));
      }
    } catch (e) {
      if (MockConfig.verboseLogging && kDebugMode) {
        debugPrint('[MockInterceptor] Error: $e');
      }
      handler.reject(DioException(
        requestOptions: options,
        error: e,
        type: DioExceptionType.unknown,
      ));
    }
  }

  /// Find a handler matching the request.
  MockHandler? _findHandler(String method, String path) {
    final methodHandlers = _handlers[method.toUpperCase()];
    if (methodHandlers == null) return null;

    // Try exact match first
    if (methodHandlers.containsKey(path)) {
      return methodHandlers[path];
    }

    // Try pattern matching (for paths with :param placeholders)
    for (final entry in methodHandlers.entries) {
      if (_matchesPattern(entry.key, path)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Check if a path matches a pattern with :param placeholders.
  bool _matchesPattern(String pattern, String path) {
    // Convert pattern to regex
    // e.g., '/users/:id/posts' -> '/users/[^/]+/posts'
    final regexPattern = pattern
        .replaceAll('/', '\\/')
        .replaceAll(RegExp(r':[^/]+'), '[^/]+');

    final regex = RegExp('^$regexPattern\$');
    return regex.hasMatch(path);
  }
}

/// Extension to extract path parameters from RequestOptions.
extension MockRequestOptionsExtension on RequestOptions {
  /// Extract path parameters based on a pattern.
  ///
  /// ```dart
  /// // For path '/users/123/posts/456' with pattern '/users/:userId/posts/:postId'
  /// final params = options.extractPathParams('/users/:userId/posts/:postId');
  /// // Returns: {'userId': '123', 'postId': '456'}
  /// ```
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
