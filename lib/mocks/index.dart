/// JoonaPay Mobile Mocking Framework
///
/// A comprehensive mocking framework for mobile-first development.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:usdc_wallet/mocks/index.dart';
///
/// // In your main.dart or API client setup:
/// if (MockConfig.useMocks) {
///   MockRegistry.initialize();
///   dio.interceptors.add(MockRegistry.interceptor);
/// }
/// ```
///
/// ## Structure
///
/// - `mock_config.dart` - Global mock configuration
/// - `mock_registry.dart` - Central registry for all mocks
/// - `base/` - Base classes and utilities
///   - `api_contract.dart` - Contract interface definitions
///   - `mock_interceptor.dart` - Dio interceptor
///   - `mock_data_generator.dart` - Fake data generation
/// - `services/` - Mock implementations by API domain
///   - `auth/` - Authentication mocks
///   - `wallet/` - Wallet mocks
///   - `transactions/` - Transaction mocks
///   - ... more services
///
/// ## Adding a New Mock Service
///
/// 1. Create folder: `lib/mocks/services/your_service/`
/// 2. Create contract: `your_service_contract.dart`
/// 3. Create mock: `your_service_mock.dart`
/// 4. Register in `mock_registry.dart`
///
/// See existing services for examples.
library mocks;

// Configuration
export 'mock_config.dart';

// Registry
export 'mock_registry.dart';

// Base classes
export 'base/api_contract.dart';
export 'base/mock_interceptor.dart';
export 'base/mock_data_generator.dart';

// Service contracts (API interfaces)
export 'services/auth/auth_contract.dart';
export 'services/wallet/wallet_contract.dart';
export 'services/transactions/transactions_contract.dart';

// Service mocks (implementations)
export 'services/auth/auth_mock.dart';
export 'services/wallet/wallet_mock.dart';
export 'services/transactions/transactions_mock.dart';
