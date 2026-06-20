/// Mock Interceptor
///
/// Dio interceptor that intercepts API calls and returns mock data
/// based on the registered mock handlers.
library;

import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
export 'package:usdc_wallet/mocks/base/api_contract.dart' show MockResponse;

/// Type definition for mock handlers (single-arg: RequestOptions)
typedef MockHandler =
    Future<MockResponse<dynamic>> Function(RequestOptions options);

/// Legacy mock handler (3-arg: uri, headers, data) used by service mocks
typedef LegacyMockHandler =
    Future<MockResponse<dynamic>> Function(
      Uri uri,
      Map<String, dynamic>? headers,
      dynamic data,
    );

/// Mock interceptor for Dio
class MockInterceptor extends Interceptor {
  /// Registered mock handlers by path pattern
  final Map<String, Map<String, MockHandler>> _handlers = {};

  /// Random for simulating failures
  final _random = Random();

  /// Logger
  static final _logger = AppLogger('MockInterceptor');

  /// Register a mock handler for a specific endpoint.
  /// Accepts either a [MockHandler] (single RequestOptions arg) or a
  /// [LegacyMockHandler] (uri, headers, data) via the [legacyHandler] param.
  void register({
    required String method,
    required String path,
    MockHandler? handler,
    LegacyMockHandler? legacyHandler,
  }) {
    assert(
      handler != null || legacyHandler != null,
      'Provide either handler or legacyHandler',
    );
    final resolvedHandler =
        handler ??
        (RequestOptions options) => legacyHandler!(
          options.uri,
          options.headers.cast<String, dynamic>(),
          options.data,
        );
    _handlers[method.toUpperCase()] ??= {};
    _handlers[method.toUpperCase()]![path] = resolvedHandler;

    _logger.debug('Registered: ${method.toUpperCase()} $path');
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
      register(method: endpoint.method.name, path: fullPath, handler: handler);
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
      if (!MockConfig.blockUnmockedRequests) {
        // No mock handler, pass through to real API.
        _logger.debug(
          'No handler for ${options.method} ${options.path}, passing through',
        );
        handler.next(options);
        return;
      }

      final fallback = _fallbackResponse(options);
      _logger.debug(
        '${options.method} ${options.path} -> ${fallback.statusCode} fallback',
      );
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: fallback.statusCode,
          data: fallback.data,
          headers: Headers.fromMap(
            fallback.headers?.map((k, v) => MapEntry(k, [v])) ?? {},
          ),
        ),
      );
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

      _logger.debug(
        '${options.method} ${options.path} -> ${mockResponse.statusCode}',
      );

      // Apply additional delay if specified
      if (mockResponse.delay.inMilliseconds > 0) {
        await Future.delayed(mockResponse.delay);
      }

      // Return mock response
      if (mockResponse.isSuccess) {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: mockResponse.statusCode,
            data: mockResponse.data,
            headers: Headers.fromMap(
              mockResponse.headers?.map((k, v) => MapEntry(k, [v])) ?? {},
            ),
          ),
        );
      } else {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: mockResponse.statusCode,
              data:
                  mockResponse.data ??
                  {'error': mockResponse.errorMessage ?? 'Mock request failed'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } catch (e) {
      _logger.error('Mock handler error', e);
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  /// Find a handler matching the request
  MockHandler? _findHandler(String method, String path) {
    final methodHandlers = _handlers[method.toUpperCase()];
    if (methodHandlers == null) return null;
    final candidatePaths = _pathCandidates(path);

    // Try exact match first
    for (final candidate in candidatePaths) {
      if (methodHandlers.containsKey(candidate)) {
        return methodHandlers[candidate];
      }
    }

    // Try pattern matching (for paths with parameters)
    for (final entry in methodHandlers.entries) {
      final pattern = entry.key;
      for (final candidate in candidatePaths) {
        if (_matchesPattern(pattern, candidate)) {
          return entry.value;
        }
      }
    }

    return null;
  }

  List<String> _pathCandidates(String path) {
    final normalized = _normalizePath(path);
    final candidates = <String>{path, normalized};
    if (normalized.startsWith('/api/v1/')) {
      candidates.add(normalized.substring('/api/v1'.length));
    } else {
      candidates.add('/api/v1$normalized');
    }
    return candidates.toList();
  }

  String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    final uri = Uri.tryParse(path);
    final parsedPath = uri?.hasAbsolutePath == true ? uri!.path : path;
    return parsedPath.startsWith('/') ? parsedPath : '/$parsedPath';
  }

  /// Check if a path matches a pattern (with :param placeholders)
  bool _matchesPattern(String pattern, String path) {
    final normalizedPath = _normalizePath(path);

    if (_looksLikeRegex(pattern)) {
      final anchored = pattern.startsWith('^') ? pattern : '^$pattern\$';
      return RegExp(anchored).hasMatch(normalizedPath);
    }

    final normalizedPattern = _normalizePath(pattern);

    // Convert pattern to regex
    // e.g., '/users/:id/transactions' -> '/users/[^/]+/transactions'
    final regexPattern = normalizedPattern
        .replaceAll('/', '\\/')
        .replaceAll(RegExp(r':[^/]+'), '[^/]+');

    final regex = RegExp('^$regexPattern\$');
    return regex.hasMatch(normalizedPath);
  }

  bool _looksLikeRegex(String pattern) {
    return pattern.startsWith('^') ||
        pattern.endsWith(r'$') ||
        pattern.contains(r'\w') ||
        pattern.contains('[') ||
        pattern.contains('(');
  }

  MockResponse<dynamic> _fallbackResponse(RequestOptions options) {
    final path = _normalizePath(options.path);
    final method = options.method.toUpperCase();

    if (path == '/config/countries') {
      return MockResponse.success({
        'countries': [
          {
            'code': 'US',
            'name': 'United States',
            'prefix': '1',
            'phoneLength': 10,
            'flag': '🇺🇸',
            'currencies': ['USD'],
            'phoneFormat': 'XXX XXX XXXX',
          },
          {
            'code': 'CI',
            'name': "Côte d'Ivoire",
            'prefix': '225',
            'phoneLength': 10,
            'flag': '🇨🇮',
            'currencies': ['XOF', 'USD'],
            'phoneFormat': 'XX XX XX XX XX',
          },
          {
            'code': 'SN',
            'name': 'Senegal',
            'prefix': '221',
            'phoneLength': 9,
            'flag': 'SN',
            'currencies': ['XOF', 'USDC'],
            'phoneFormat': 'XX XXX XX XX',
          },
          {
            'code': 'ML',
            'name': 'Mali',
            'prefix': '223',
            'phoneLength': 8,
            'flag': 'ML',
            'currencies': ['XOF', 'USDC'],
            'phoneFormat': 'XX XX XX XX',
          },
        ],
      });
    }

    if (path == '/config/mobile-version') {
      return MockResponse.success({
        'platform': options.queryParameters['platform'] ?? 'unknown',
        'currentVersion': options.queryParameters['version'] ?? '1.0.0',
        'currentBuildNumber': options.queryParameters['buildNumber'] ?? '1',
        'latestVersion': '1.0.0',
        'minimumSupportedVersion': '1.0.0',
        'latestBuildNumber': null,
        'minimumSupportedBuildNumber': null,
        'forceUpgrade': false,
        'upgradeRecommended': false,
        'breakingApiChange': false,
        'message': null,
        'appUrl': null,
        'apiUrl': 'http://127.0.0.1:3401/api/v1',
        'checkedAt': DateTime.now().toUtc().toIso8601String(),
      });
    }

    if (path == '/risk/session') {
      return MockResponse.success({
        'success': true,
        'data': {
          'sessionRiskToken': 'mock-risk-token',
          'riskLevel': 'low',
          'deviceTrust': 92,
          'requiredActions': <String>[],
        },
      });
    }

    if (path == '/security/public-key') {
      return MockResponse.success({
        'kty': 'RSA',
        'kid': 'mock-key',
        'n': '',
        'e': 'AQAB',
      });
    }

    if (path == '/wallet/receive') {
      return MockResponse.success({
        'walletAddress': '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        'address': '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        'network': 'polygon',
        'currency': 'USDC',
      });
    }

    if (path.contains('/rate') || path.contains('/rates')) {
      return MockResponse.success({
        'sourceCurrency': 'XOF',
        'targetCurrency': 'USDC',
        'fromCurrency': 'XOF',
        'toCurrency': 'USDC',
        'rate': 1 / 655.957,
        'sourceAmount': 10000,
        'targetAmount': 15.24,
        'fee': 0,
        'expiresAt': DateTime.now()
            .add(const Duration(minutes: 5))
            .toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    if (method == 'DELETE') {
      return MockResponse.success({
        'success': true,
        'message': 'Mock delete completed',
      });
    }

    if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
      return MockResponse.success({
        'success': true,
        'id': 'mock-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'completed',
        'message': 'Mock operation completed',
      });
    }

    return MockResponse.success(_emptyListPayload(path));
  }

  Map<String, dynamic> _emptyListPayload(String path) {
    final parts = path
        .split('/')
        .where(
          (segment) =>
              segment.isNotEmpty && segment != 'api' && segment != 'v1',
        )
        .toList();
    final resource = parts.isEmpty ? null : parts.last;

    if (resource == null) {
      return {'data': <dynamic>[]};
    }

    final normalized = resource.replaceAll('-', '_');
    return {
      normalized: <dynamic>[],
      'items': <dynamic>[],
      'data': <dynamic>[],
      'total': 0,
      'page': 1,
      'limit': 20,
    };
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
