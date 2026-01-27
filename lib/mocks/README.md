# JoonaPay Mobile Mocking Framework

A comprehensive mocking framework for mobile-first development. Build full features at the mobile level with mock APIs, then use the contracts as specifications for backend implementation.

## Quick Start

```dart
import 'package:usdc_wallet/mocks/index.dart';

// In your API client setup (e.g., api_client.dart):
final dio = Dio(BaseOptions(baseUrl: 'https://api.joonapay.com'));

// Add mock interceptor in debug mode
if (MockConfig.useMocks) {
  MockRegistry.initialize();
  dio.interceptors.add(MockRegistry.interceptor);
}
```

## Features

- **Contract-First Design**: Define API contracts that serve as specifications
- **Realistic Mock Data**: Generate realistic West African names, phone numbers, currencies
- **Configurable**: Enable/disable mocks globally or per-service
- **Network Simulation**: Configurable delays and random failures
- **State Management**: Mock state persists during session for realistic flows

## Directory Structure

```
lib/mocks/
├── mock_config.dart           # Global configuration
├── mock_registry.dart         # Central registry
├── index.dart                 # Public exports
├── base/
│   ├── api_contract.dart      # Contract base classes
│   ├── mock_interceptor.dart  # Dio interceptor
│   └── mock_data_generator.dart # Fake data utilities
└── services/
    ├── auth/
    │   ├── auth_contract.dart # Auth API interface
    │   └── auth_mock.dart     # Auth mock implementation
    ├── wallet/
    │   ├── wallet_contract.dart
    │   └── wallet_mock.dart
    ├── transactions/
    │   ├── transactions_contract.dart
    │   └── transactions_mock.dart
    └── ... more services
```

## Configuration

```dart
// Enable/disable all mocks
MockConfig.useMocks = true;

// Configure per-service
MockConfig.mockAuth = true;
MockConfig.mockWallet = true;
MockConfig.mockTransactions = false;  // Use real API for transactions

// Simulate network conditions
MockConfig.networkDelayMs = 500;
MockConfig.simulateRandomFailures = true;
MockConfig.failureRate = 0.1;  // 10% failure rate
```

## Adding a New Mock Service

### 1. Create the Contract

```dart
// lib/mocks/services/kyc/kyc_contract.dart
import '../../base/api_contract.dart';

class KycSubmissionRequest {
  final String documentType;
  final String documentFront;
  // ...
}

class KycContract extends ApiContract {
  @override
  String get serviceName => 'KYC';

  @override
  String get basePath => '/kyc';

  static const submitKyc = ApiEndpoint(
    path: '/submit',
    method: HttpMethod.post,
    description: 'Submit KYC documents',
    requestType: KycSubmissionRequest,
    requiresAuth: true,
  );

  @override
  List<ApiEndpoint> get endpoints => [submitKyc];
}
```

### 2. Create the Mock

```dart
// lib/mocks/services/kyc/kyc_mock.dart
import '../../base/mock_interceptor.dart';
import '../../base/api_contract.dart';

class KycMockState {
  static String? currentKycStatus;
  // Add state as needed
}

class KycMock {
  static void register(MockInterceptor interceptor) {
    interceptor.register(
      method: 'POST',
      path: '/kyc/submit',
      handler: _handleSubmitKyc,
    );
  }

  static Future<MockResponse> _handleSubmitKyc(RequestOptions options) async {
    // Implement mock logic
    return MockResponse.success({'status': 'pending'});
  }
}
```

### 3. Register in MockRegistry

```dart
// In mock_registry.dart
import 'services/kyc/kyc_mock.dart';
import 'services/kyc/kyc_contract.dart';

// In initialize():
KycMock.register(_interceptor);

// In printContracts():
final contracts = [
  AuthContract(),
  WalletContract(),
  TransactionsContract(),
  KycContract(),  // Add here
];
```

### 4. Export in index.dart

```dart
export 'services/kyc/kyc_contract.dart';
export 'services/kyc/kyc_mock.dart';
```

## API Contract as Backend Specification

Once your feature works with mocks, the contract file becomes the specification for backend implementation:

```dart
// Print all contracts
MockRegistry.printContracts();

// Generate OpenAPI spec
final spec = MockRegistry.generateOpenApiSpec();
print(jsonEncode(spec));
```

Output:
```
=== Auth API Contract ===
Base path: /auth
Endpoints:
  POST /login - Request OTP for login
  POST /register - Register a new user and request OTP
  POST /verify-otp - Verify OTP and get auth tokens
  ...
```

## Testing with Mocks

```dart
void main() {
  setUp(() {
    MockConfig.useMocks = true;
    MockRegistry.initialize();
    MockRegistry.reset();  // Reset state between tests
  });

  test('login flow', () async {
    final dio = Dio();
    dio.interceptors.add(MockRegistry.interceptor);

    // Request OTP
    final response = await dio.post('/auth/login', data: {
      'phone': '+2250123456789'
    });
    expect(response.statusCode, 200);

    // Verify OTP (dev OTP is always 123456)
    final verifyResponse = await dio.post('/auth/verify-otp', data: {
      'phone': '+2250123456789',
      'otp': '123456'
    });
    expect(verifyResponse.statusCode, 200);
    expect(verifyResponse.data['accessToken'], isNotNull);
  });
}
```

## Mock Data Generator

```dart
import 'package:usdc_wallet/mocks/index.dart';

// Generate fake data
MockDataGenerator.uuid();           // 'a1b2c3d4-...'
MockDataGenerator.fullName();       // 'Amadou Diallo'
MockDataGenerator.phoneNumber();    // '+225012345678'
MockDataGenerator.walletAddress();  // '0x1234...'
MockDataGenerator.amount();         // 1234.56
MockDataGenerator.currency();       // 'XOF'
MockDataGenerator.pastDate();       // DateTime(...)
```

## Development Workflow

1. **Design the feature** - Define screens and user flows
2. **Create contract** - Define API endpoints and data types
3. **Implement mock** - Create realistic mock responses
4. **Build UI** - Develop the feature against mocks
5. **Test** - Verify feature works end-to-end
6. **Hand off** - Share contract with backend team
7. **Integrate** - Switch from mock to real API

```dart
// When backend is ready, disable specific mock:
MockConfig.mockAuth = false;  // Use real auth API
MockConfig.mockWallet = true; // Still use mock wallet
```

## Best Practices

1. **Keep contracts minimal** - Only define what's needed
2. **Use realistic data** - MockDataGenerator for West African context
3. **Test error states** - Mock error responses for error handling
4. **Document edge cases** - Add comments for non-obvious behavior
5. **Reset between tests** - Call `MockRegistry.reset()` in setUp
