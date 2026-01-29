/// API Contract Base Classes
///
/// Defines the structure for API contracts that serve as the interface
/// between mobile and backend. When mocks are working correctly,
/// these contracts become the specification for backend implementation.
library;

import 'package:flutter/foundation.dart';
import '../../utils/logger.dart';

/// HTTP methods
enum HttpMethod { get, post, put, patch, delete }

/// API endpoint contract
class ApiEndpoint {
  final String path;
  final HttpMethod method;
  final String description;
  final Type? requestType;
  final Type? responseType;
  final Map<String, String>? pathParams;
  final Map<String, String>? queryParams;
  final bool requiresAuth;

  const ApiEndpoint({
    required this.path,
    required this.method,
    required this.description,
    this.requestType,
    this.responseType,
    this.pathParams,
    this.queryParams,
    this.requiresAuth = true,
  });

  @override
  String toString() {
    return '${method.name.toUpperCase()} $path - $description';
  }
}

/// Base class for API contracts
abstract class ApiContract {
  /// Service name (e.g., 'auth', 'wallet', 'transactions')
  String get serviceName;

  /// Base path for this service (e.g., '/auth', '/wallet')
  String get basePath;

  /// List of all endpoints in this contract
  List<ApiEndpoint> get endpoints;

  /// Generate OpenAPI spec for this contract
  Map<String, dynamic> toOpenApiSpec() {
    final paths = <String, dynamic>{};

    for (final endpoint in endpoints) {
      final fullPath = '$basePath${endpoint.path}';
      final methodName = endpoint.method.name;

      paths[fullPath] ??= {};
      paths[fullPath][methodName] = {
        'summary': endpoint.description,
        'security': endpoint.requiresAuth ? [{'bearerAuth': []}] : [],
        if (endpoint.pathParams != null)
          'parameters': endpoint.pathParams!.entries
              .map((e) => {
                    'name': e.key,
                    'in': 'path',
                    'required': true,
                    'schema': {'type': 'string'},
                    'description': e.value,
                  })
              .toList(),
      };
    }

    return {
      'openapi': '3.0.0',
      'info': {
        'title': '$serviceName API',
        'version': '1.0.0',
      },
      'paths': paths,
    };
  }

  /// Print contract summary
  void printContract() {
    if (!kDebugMode) return;

    final logger = AppLogger(serviceName);
    logger.info('API Contract - Base path: $basePath');
    for (final endpoint in endpoints) {
      logger.debug(endpoint.toString());
    }
  }
}

/// Mock response wrapper
class MockResponse<T> {
  final int statusCode;
  final T? data;
  final String? errorMessage;
  final Map<String, dynamic>? headers;
  final Duration delay;

  const MockResponse({
    this.statusCode = 200,
    this.data,
    this.errorMessage,
    this.headers,
    this.delay = const Duration(milliseconds: 500),
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  factory MockResponse.success(T data, {Duration? delay}) {
    return MockResponse(
      statusCode: 200,
      data: data,
      delay: delay ?? const Duration(milliseconds: 500),
    );
  }

  factory MockResponse.created(T data) {
    return MockResponse(statusCode: 201, data: data);
  }

  factory MockResponse.noContent() {
    return const MockResponse(statusCode: 204);
  }

  factory MockResponse.badRequest(String message) {
    return MockResponse(statusCode: 400, errorMessage: message);
  }

  factory MockResponse.unauthorized([String? message]) {
    return MockResponse(
      statusCode: 401,
      errorMessage: message ?? 'Unauthorized',
    );
  }

  factory MockResponse.forbidden([String? message]) {
    return MockResponse(
      statusCode: 403,
      errorMessage: message ?? 'Forbidden',
    );
  }

  factory MockResponse.notFound([String? message]) {
    return MockResponse(
      statusCode: 404,
      errorMessage: message ?? 'Not found',
    );
  }

  factory MockResponse.serverError([String? message]) {
    return MockResponse(
      statusCode: 500,
      errorMessage: message ?? 'Internal server error',
    );
  }
}
