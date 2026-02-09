/// HTTP methods supported by API contracts.
enum HttpMethod { get, post, put, patch, delete }

/// Defines a single API endpoint in a contract.
///
/// Use this to document your API endpoints in a structured way
/// that can be used to generate OpenAPI specs.
///
/// ```dart
/// static const getUsers = ApiEndpoint(
///   path: '/users',
///   method: HttpMethod.get,
///   description: 'Get all users with pagination',
///   queryParams: {
///     'page': 'Page number (default: 1)',
///     'limit': 'Items per page (default: 20)',
///   },
///   requiresAuth: true,
/// );
/// ```
class ApiEndpoint {
  /// URL path (relative to base path)
  final String path;

  /// HTTP method
  final HttpMethod method;

  /// Human-readable description
  final String description;

  /// Request body type (for documentation)
  final Type? requestType;

  /// Response body type (for documentation)
  final Type? responseType;

  /// Path parameters with descriptions
  final Map<String, String>? pathParams;

  /// Query parameters with descriptions
  final Map<String, String>? queryParams;

  /// Whether this endpoint requires authentication
  final bool requiresAuth;

  /// Optional tags for grouping in OpenAPI spec
  final List<String>? tags;

  const ApiEndpoint({
    required this.path,
    required this.method,
    required this.description,
    this.requestType,
    this.responseType,
    this.pathParams,
    this.queryParams,
    this.requiresAuth = true,
    this.tags,
  });

  /// Full method and path string (e.g., "GET /users/:id")
  String get fullPath => '${method.name.toUpperCase()} $path';

  @override
  String toString() => '$fullPath - $description';
}

/// Base class for API contracts.
///
/// Extend this to define your API structure:
///
/// ```dart
/// class UsersContract extends ApiContract {
///   @override
///   String get serviceName => 'Users';
///
///   @override
///   String get basePath => '/users';
///
///   static const getUsers = ApiEndpoint(
///     path: '',
///     method: HttpMethod.get,
///     description: 'Get all users',
///   );
///
///   static const getUser = ApiEndpoint(
///     path: '/:id',
///     method: HttpMethod.get,
///     description: 'Get user by ID',
///     pathParams: {'id': 'User ID'},
///   );
///
///   @override
///   List<ApiEndpoint> get endpoints => [getUsers, getUser];
/// }
/// ```
abstract class ApiContract {
  /// Service name (e.g., 'Users', 'Auth', 'Transactions')
  String get serviceName;

  /// Base path for this service (e.g., '/users', '/auth')
  String get basePath;

  /// List of all endpoints in this contract
  List<ApiEndpoint> get endpoints;

  /// Version of this API contract
  String get version => '1.0.0';

  /// Generate OpenAPI spec for this contract.
  Map<String, dynamic> toOpenApiSpec() {
    final paths = <String, dynamic>{};

    for (final endpoint in endpoints) {
      final fullPath = '$basePath${endpoint.path}';
      final methodName = endpoint.method.name;

      paths[fullPath] ??= {};
      paths[fullPath][methodName] = {
        'summary': endpoint.description,
        'tags': endpoint.tags ?? [serviceName],
        'security': endpoint.requiresAuth ? [{'bearerAuth': <dynamic>[]}] : <dynamic>[],
        if (endpoint.pathParams != null)
          'parameters': [
            ...endpoint.pathParams!.entries.map((e) => {
                  'name': e.key,
                  'in': 'path',
                  'required': true,
                  'schema': {'type': 'string'},
                  'description': e.value,
                }),
          ],
        if (endpoint.queryParams != null)
          'parameters': [
            ...(paths[fullPath][methodName]['parameters'] as List? ?? []),
            ...endpoint.queryParams!.entries.map((e) => {
                  'name': e.key,
                  'in': 'query',
                  'required': false,
                  'schema': {'type': 'string'},
                  'description': e.value,
                }),
          ],
        'responses': {
          '200': {'description': 'Success'},
          if (endpoint.requiresAuth) '401': {'description': 'Unauthorized'},
        },
      };
    }

    return {
      'openapi': '3.0.0',
      'info': {
        'title': '$serviceName API',
        'version': version,
      },
      'paths': paths,
      'components': {
        'securitySchemes': {
          'bearerAuth': {
            'type': 'http',
            'scheme': 'bearer',
            'bearerFormat': 'JWT',
          },
        },
      },
    };
  }

  /// Print a summary of this contract.
  void printSummary() {
    // Using print is intentional for CLI output
    // ignore: avoid_print
    print('=== $serviceName API Contract ===');
    // ignore: avoid_print
    print('Base path: $basePath');
    // ignore: avoid_print
    print('Version: $version');
    // ignore: avoid_print
    print('Endpoints:');
    for (final endpoint in endpoints) {
      // ignore: avoid_print
      print('  ${endpoint.method.name.toUpperCase().padRight(6)} $basePath${endpoint.path}');
      // ignore: avoid_print
      print('         ${endpoint.description}');
    }
  }
}
