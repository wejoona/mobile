# Flutter Mock API

A comprehensive API mocking framework for Flutter applications. Build and test features before your backend is ready.

## Features

- **Contract-First Design** - Define API contracts that become backend specifications
- **Dio Interceptor** - Transparent request interception and mocking
- **Realistic Data Generation** - Generate UUIDs, names, emails, amounts, dates
- **Network Simulation** - Configurable delays and failure rates
- **Pattern Matching** - Support for dynamic routes with path parameters
- **OpenAPI Generation** - Generate OpenAPI specs from contracts

## Installation

```yaml
dependencies:
  flutter_mock_api:
    path: ../packages/flutter_mock_api
```

## Quick Start

### 1. Create a Contract

```dart
import 'package:flutter_mock_api/flutter_mock_api.dart';

class UsersContract extends ApiContract {
  @override
  String get serviceName => 'Users';

  @override
  String get basePath => '/users';

  static const getUsers = ApiEndpoint(
    path: '',
    method: HttpMethod.get,
    description: 'Get all users with pagination',
    queryParams: {'page': 'Page number', 'limit': 'Items per page'},
  );

  static const getUser = ApiEndpoint(
    path: '/:id',
    method: HttpMethod.get,
    description: 'Get user by ID',
    pathParams: {'id': 'User ID'},
  );

  static const createUser = ApiEndpoint(
    path: '',
    method: HttpMethod.post,
    description: 'Create a new user',
    requiresAuth: true,
  );

  @override
  List<ApiEndpoint> get endpoints => [getUsers, getUser, createUser];
}
```

### 2. Create Mock Handlers

```dart
final usersMockHandlers = {
  'GET': {
    '': (options) async {
      // GET /users
      return MockResponse.success({
        'users': [
          {'id': '1', 'name': 'John Doe'},
          {'id': '2', 'name': 'Jane Smith'},
        ],
        'total': 2,
      });
    },
    '/:id': (options) async {
      // GET /users/:id
      final params = options.extractPathParams('/users/:id');
      final id = params['id'];
      return MockResponse.success({
        'id': id,
        'name': 'User $id',
        'email': MockDataGenerator.email(),
      });
    },
  },
  'POST': {
    '': (options) async {
      // POST /users
      final data = options.data;
      return MockResponse.created({
        'id': MockDataGenerator.uuid(),
        'name': data['name'],
        'createdAt': DateTime.now().toIso8601String(),
      });
    },
  },
};
```

### 3. Register and Use

```dart
// Create registry
final registry = MockRegistry();

// Register service
registry.registerService(UsersContract(), usersMockHandlers);
registry.markInitialized();

// Add to Dio
final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));

if (MockConfig.useMocks) {
  dio.interceptors.add(registry.interceptor);
}

// Use normally - requests will be mocked!
final response = await dio.get('/users');
print(response.data); // Mock data
```

## Configuration

```dart
// Enable/disable mocks
MockConfig.useMocks = true;

// Simulate network latency
MockConfig.networkDelayMs = 500;

// Simulate random failures (for testing error handling)
MockConfig.simulateRandomFailures = true;
MockConfig.failureRate = 0.1; // 10% failure rate

// Verbose logging
MockConfig.verboseLogging = true;

// Presets
MockConfig.configureForTesting();           // Fast, no delays
MockConfig.configureForRealisticSimulation(); // Slow, some failures
```

## Mock Responses

```dart
// Success responses
MockResponse.success({'id': '123', 'name': 'John'});
MockResponse.created({'id': '456'});
MockResponse.noContent();

// Client errors
MockResponse.badRequest('Invalid email format');
MockResponse.unauthorized('Token expired');
MockResponse.forbidden('Access denied');
MockResponse.notFound('User not found');
MockResponse.validationError('Validation failed', {'email': 'Invalid'});
MockResponse.rateLimited('Too many requests', 60);

// Server errors
MockResponse.serverError('Database error');
MockResponse.serviceUnavailable();
MockResponse.gatewayTimeout();
```

## Data Generation

```dart
// IDs
MockDataGenerator.uuid();        // 'a1b2c3d4-e5f6-4g7h-8i9j-k0l1m2n3o4p5'
MockDataGenerator.shortId();     // 'a1b2c3d4'
MockDataGenerator.reference();   // 'REF1234567890001'

// Personal
MockDataGenerator.fullName();    // 'John Smith'
MockDataGenerator.firstName();   // 'John'
MockDataGenerator.lastName();    // 'Smith'
MockDataGenerator.email();       // 'john.smith42@gmail.com'
MockDataGenerator.phoneNumber(); // '+11234567890'
MockDataGenerator.username();    // 'cool_ninja123'

// Financial
MockDataGenerator.amount();      // 1234.56
MockDataGenerator.intAmount();   // 1234
MockDataGenerator.currencyCode(); // 'USD'
MockDataGenerator.walletAddress(); // '0x1234...'

// Dates
MockDataGenerator.pastDate();    // DateTime 1-30 days ago
MockDataGenerator.futureDate();  // DateTime 1-30 days ahead
MockDataGenerator.isoDatePast(); // ISO 8601 string

// Utilities
MockDataGenerator.pick(['a', 'b', 'c']);  // Random item
MockDataGenerator.pickMany(list, 3);       // 3 random items
MockDataGenerator.boolean();               // true/false
MockDataGenerator.integer(min: 1, max: 100);
MockDataGenerator.loremIpsum(words: 10);
```

## Path Parameters

```dart
mockInterceptor.register(
  method: 'GET',
  path: '/users/:userId/posts/:postId',
  handler: (options) async {
    final params = options.extractPathParams('/users/:userId/posts/:postId');
    // params = {'userId': '123', 'postId': '456'}
    return MockResponse.success({...});
  },
);
```

## Generate OpenAPI Spec

```dart
// Print contracts
registry.printContracts();

// Generate OpenAPI JSON
final json = registry.generateOpenApiJson(
  title: 'My API',
  version: '1.0.0',
  description: 'API documentation',
);
print(json);
```

## Testing

```dart
void main() {
  late MockRegistry registry;

  setUp(() {
    MockConfig.configureForTesting();
    registry = MockRegistry();
    registry.registerService(UsersContract(), usersMockHandlers);
    registry.markInitialized();
  });

  tearDown(() {
    registry.reset();
    registry.clear();
  });

  test('fetches users', () async {
    final dio = Dio();
    dio.interceptors.add(registry.interceptor);

    final response = await dio.get('/users');

    expect(response.statusCode, 200);
    expect(response.data['users'], isNotEmpty);
  });
}
```

## License

MIT
