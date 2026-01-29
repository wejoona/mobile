/// Mock Registry
///
/// Central registry for all mock services.
/// Use this to initialize and configure the mocking framework.
library;

import 'package:flutter/foundation.dart';
import 'base/mock_interceptor.dart';
import 'mock_config.dart';
import 'services/auth/auth_mock.dart';
import 'services/auth/auth_contract.dart';
import 'services/wallet/wallet_mock.dart';
import 'services/wallet/wallet_contract.dart';
import 'services/transactions/transactions_mock.dart';
import 'services/transactions/transactions_contract.dart';
import 'services/sessions/sessions_mock.dart';
import 'services/feature_flags/feature_flags_mock.dart';
import 'services/feature_flags/feature_flags_contract.dart';
import 'services/devices/devices_mock.dart';
import 'services/kyc/kyc_mock.dart';
import 'services/deposit/deposit_mock.dart';
import 'services/pin/pin_mock.dart';
import 'services/transfers/transfers_mock.dart';
import 'services/bill_payments/bill_payments_mock.dart';
import 'services/bill_payments/bill_payments_contract.dart';
import 'services/notifications/notifications_mock.dart';
import 'services/external_transfer/external_transfer_mock.dart';
import 'services/savings_pots/savings_pots_mock.dart';
import 'services/contacts/contacts_sync_mock.dart';
import 'services/recurring_transfers/recurring_transfers_mock.dart';

/// Mock Registry
///
/// Manages all mock services and provides a central point for:
/// - Registering mock handlers
/// - Printing API contracts
/// - Resetting mock state
class MockRegistry {
  static final MockInterceptor _interceptor = MockInterceptor();
  static bool _isInitialized = false;

  /// Get the mock interceptor (for adding to Dio)
  static MockInterceptor get interceptor => _interceptor;

  /// Initialize all mock services
  static void initialize() {
    if (_isInitialized) return;

    if (kDebugMode) {
      print('=== Initializing Mock Registry ===');
    }

    // Register all mock handlers
    AuthMock.register(_interceptor);
    WalletMock.register(_interceptor);
    TransactionsMock.register(_interceptor);
    SessionsMock.register(_interceptor);
    FeatureFlagsMock.register(_interceptor);
    DevicesMock.register(_interceptor);
    KycMock.register(_interceptor);
    DepositMock.register(_interceptor);
    PinMock.register(_interceptor);
    TransfersMock.register(_interceptor);
    BillPaymentsMock.register(_interceptor);
    NotificationsMock.register(_interceptor);
    ExternalTransferMock.register(_interceptor);
    SavingsPotsMock.register(_interceptor);
    ContactsSyncMock.register(_interceptor);
    RecurringTransfersMock.register(_interceptor);

    // Add more mock services here as they are created:
    // MerchantMock.register(_interceptor);
    // RatesMock.register(_interceptor);

    _isInitialized = true;

    if (kDebugMode) {
      print('=== Mock Registry Initialized ===');
    }
  }

  /// Reset all mock state (useful for testing)
  static void reset() {
    AuthMockState.reset();
    WalletMockState.reset();
    TransactionsMockState.reset();
    DevicesMockState.reset();
    KycMockState.reset();
    TransfersMockState.reset();
    BillPaymentsMockState.reset();

    if (kDebugMode) {
      print('=== Mock State Reset ===');
    }
  }

  /// Clear all mock handlers
  static void clear() {
    _interceptor.clear();
    _isInitialized = false;
  }

  /// Print all API contracts
  static void printContracts() {
    print('\n========================================');
    print('       JoonaPay API Contracts');
    print('========================================\n');

    final contracts = [
      AuthContract(),
      WalletContract(),
      TransactionsContract(),
      FeatureFlagsContract(),
      BillPaymentsContract(),
    ];

    for (final contract in contracts) {
      contract.printContract();
      print('');
    }

    print('========================================\n');
  }

  /// Generate OpenAPI spec for all contracts
  static Map<String, dynamic> generateOpenApiSpec() {
    final contracts = [
      AuthContract(),
      WalletContract(),
      TransactionsContract(),
      FeatureFlagsContract(),
      BillPaymentsContract(),
    ];

    final allPaths = <String, dynamic>{};

    for (final contract in contracts) {
      final spec = contract.toOpenApiSpec();
      final paths = spec['paths'] as Map<String, dynamic>;
      allPaths.addAll(paths);
    }

    return {
      'openapi': '3.0.0',
      'info': {
        'title': 'JoonaPay USDC Wallet API',
        'version': '1.0.0',
        'description': 'API for JoonaPay USDC Wallet mobile app',
      },
      'servers': [
        {'url': 'https://api.joonapay.com', 'description': 'Production'},
        {'url': 'https://staging-api.joonapay.com', 'description': 'Staging'},
        {'url': 'http://localhost:3000', 'description': 'Development'},
      ],
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

  /// Get list of all registered endpoints
  static List<String> getRegisteredEndpoints() {
    final contracts = [
      AuthContract(),
      WalletContract(),
      TransactionsContract(),
      FeatureFlagsContract(),
      BillPaymentsContract(),
    ];

    final endpoints = <String>[];
    for (final contract in contracts) {
      for (final endpoint in contract.endpoints) {
        endpoints.add(
          '${endpoint.method.name.toUpperCase()} ${contract.basePath}${endpoint.path}',
        );
      }
    }
    return endpoints;
  }
}

/// Extension to easily add mock interceptor to Dio
extension MockDioExtension on dynamic {
  /// Add mock interceptor if mocking is enabled
  void addMockInterceptorIfEnabled() {
    if (MockConfig.useMocks) {
      MockRegistry.initialize();
      // This would be called like: dio.interceptors.addMockInterceptorIfEnabled();
      // But since we can't know the type at compile time, this is just for documentation
    }
  }
}
