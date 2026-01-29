/// Flutter Mock API
///
/// A comprehensive API mocking framework for Flutter applications.
///
/// ## Features
/// - Contract-first API design
/// - Dio interceptor for transparent mocking
/// - Realistic data generation
/// - Configurable network simulation (delays, failures)
/// - Pattern matching for dynamic routes
/// - OpenAPI spec generation from contracts
///
/// ## Quick Start
///
/// ```dart
/// import 'package:flutter_mock_api/flutter_mock_api.dart';
///
/// // 1. Create interceptor
/// final mockInterceptor = MockInterceptor();
///
/// // 2. Register handlers
/// mockInterceptor.register(
///   method: 'GET',
///   path: '/users/:id',
///   handler: (options) async {
///     final userId = options.extractPathParams('/users/:id')['id'];
///     return MockResponse.success({'id': userId, 'name': 'John'});
///   },
/// );
///
/// // 3. Add to Dio
/// final dio = Dio();
/// if (MockConfig.useMocks) {
///   dio.interceptors.add(mockInterceptor);
/// }
/// ```
library flutter_mock_api;

export 'src/mock_config.dart';
export 'src/mock_interceptor.dart';
export 'src/api_contract.dart';
export 'src/mock_response.dart';
export 'src/mock_data_generator.dart';
export 'src/mock_registry.dart';
