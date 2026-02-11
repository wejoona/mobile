import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_mock_api/src/api_contract.dart';
import 'package:flutter_mock_api/src/mock_interceptor.dart';

/// Central registry for managing mock services.
///
/// Use this to organize multiple mock services and generate combined
/// API documentation.
///
/// ```dart
/// // Create registry
/// final registry = MockRegistry();
///
/// // Register services
/// registry.registerService(UsersContract(), usersMockHandlers);
/// registry.registerService(AuthContract(), authMockHandlers);
///
/// // Get interceptor for Dio
/// dio.interceptors.add(registry.interceptor);
///
/// // Print all contracts
/// registry.printContracts();
///
/// // Generate OpenAPI spec
/// final spec = registry.generateOpenApiSpec();
/// ```
class MockRegistry {
  /// The mock interceptor instance.
  final MockInterceptor interceptor = MockInterceptor();

  /// Registered contracts.
  final List<ApiContract> _contracts = [];

  /// Reset callback functions.
  final List<VoidCallback> _resetCallbacks = [];

  /// Whether the registry has been initialized.
  bool _isInitialized = false;

  /// Whether the registry is initialized.
  bool get isInitialized => _isInitialized;

  /// List of registered contracts.
  List<ApiContract> get contracts => List.unmodifiable(_contracts);

  /// Register a service with its contract and handlers.
  ///
  /// [contract] - API contract defining endpoints
  /// [handlers] - Map of endpoint paths to handler functions
  /// [resetCallback] - Optional callback to reset mock state
  void registerService(
    ApiContract contract,
    Map<String, Map<String, MockHandler>> handlers, {
    VoidCallback? resetCallback,
  }) {
    _contracts.add(contract);

    // Register handlers with full paths
    handlers.forEach((method, paths) {
      paths.forEach((path, handler) {
        final fullPath = '${contract.basePath}$path';
        interceptor.register(
          method: method,
          path: fullPath,
          handler: handler,
        );
      });
    });

    if (resetCallback != null) {
      _resetCallbacks.add(resetCallback);
    }

    if (kDebugMode) {
      debugPrint('[MockRegistry] Registered: ${contract.serviceName} (${contract.endpoints.length} endpoints)');
    }
  }

  /// Mark the registry as initialized.
  void markInitialized() {
    _isInitialized = true;
    if (kDebugMode) {
      debugPrint('[MockRegistry] Initialized with ${_contracts.length} services');
    }
  }

  /// Reset all mock state.
  void reset() {
    for (final callback in _resetCallbacks) {
      callback();
    }
    if (kDebugMode) {
      debugPrint('[MockRegistry] State reset');
    }
  }

  /// Clear all handlers and contracts.
  void clear() {
    interceptor.clear();
    _contracts.clear();
    _resetCallbacks.clear();
    _isInitialized = false;
  }

  /// Print all registered contracts to console.
  void printContracts() {
    // ignore: avoid_print
    print('\n========================================');
    // ignore: avoid_print
    print('       API Contracts');
    // ignore: avoid_print
    print('========================================\n');

    for (final contract in _contracts) {
      contract.printSummary();
      // ignore: avoid_print
      print('');
    }

    // ignore: avoid_print
    print('========================================');
    // ignore: avoid_print
    print('Total: ${_contracts.length} services, ${interceptor.registeredEndpoints.length} endpoints');
    // ignore: avoid_print
    print('========================================\n');
  }

  /// Generate combined OpenAPI spec for all contracts.
  Map<String, dynamic> generateOpenApiSpec({
    String title = 'API',
    String version = '1.0.0',
    String? description,
    List<Map<String, String>>? servers,
  }) {
    final allPaths = <String, dynamic>{};
    final allTags = <Map<String, String>>[];

    for (final contract in _contracts) {
      final spec = contract.toOpenApiSpec();
      final paths = spec['paths'] as Map<String, dynamic>;
      allPaths.addAll(paths);

      allTags.add({
        'name': contract.serviceName,
        'description': '${contract.serviceName} API endpoints',
      });
    }

    return {
      'openapi': '3.0.0',
      'info': {
        'title': title,
        'version': version,
        if (description != null) 'description': description,
      },
      'servers': servers ??
          [
            {'url': 'https://api.example.com', 'description': 'Production'},
            {'url': 'https://staging-api.example.com', 'description': 'Staging'},
            {'url': 'http://localhost:3000', 'description': 'Development'},
          ],
      'tags': allTags,
      'components': {
        'securitySchemes': {
          'bearerAuth': {
            'type': 'http',
            'scheme': 'bearer',
            'bearerFormat': 'JWT',
          },
        },
      },
      'paths': allPaths,
    };
  }

  /// Generate OpenAPI spec as JSON string.
  String generateOpenApiJson({
    String title = 'API',
    String version = '1.0.0',
    String? description,
  }) {
    final spec = generateOpenApiSpec(
      title: title,
      version: version,
      description: description,
    );
    return const JsonEncoder.withIndent('  ').convert(spec);
  }

  /// Get list of all registered endpoints.
  List<String> get registeredEndpoints => interceptor.registeredEndpoints;
}
