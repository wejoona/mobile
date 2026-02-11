/// Mock Registry
///
/// Central registry for all mock services.
/// Use this to initialize and configure the mocking framework.
library;

import 'package:flutter/foundation.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_mock.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_contract.dart';
import 'package:usdc_wallet/mocks/services/wallet/wallet_mock.dart';
import 'package:usdc_wallet/mocks/services/wallet/wallet_contract.dart';
import 'package:usdc_wallet/mocks/services/transactions/transactions_mock.dart';
import 'package:usdc_wallet/mocks/services/transactions/transactions_contract.dart';
import 'package:usdc_wallet/mocks/services/sessions/sessions_mock.dart';
import 'package:usdc_wallet/mocks/services/feature_flags/feature_flags_mock.dart';
import 'package:usdc_wallet/mocks/services/feature_flags/feature_flags_contract.dart';
import 'package:usdc_wallet/mocks/services/devices/devices_mock.dart';
import 'package:usdc_wallet/mocks/services/kyc/kyc_mock.dart';
import 'package:usdc_wallet/mocks/services/deposit/deposit_mock.dart';
import 'package:usdc_wallet/mocks/services/pin/pin_mock.dart';
import 'package:usdc_wallet/mocks/services/transfers/transfers_mock.dart';
import 'package:usdc_wallet/mocks/services/bill_payments/bill_payments_mock.dart';
import 'package:usdc_wallet/mocks/services/bill_payments/bill_payments_contract.dart';
import 'package:usdc_wallet/mocks/services/notifications/notifications_mock.dart';
import 'package:usdc_wallet/mocks/services/external_transfer/external_transfer_mock.dart';
import 'package:usdc_wallet/mocks/services/savings_pots/savings_pots_mock.dart';
import 'package:usdc_wallet/mocks/services/contacts/contacts_sync_mock.dart';
import 'package:usdc_wallet/mocks/services/recurring_transfers/recurring_transfers_mock.dart';
import 'package:usdc_wallet/mocks/services/limits/limits_mock.dart';
import 'package:usdc_wallet/mocks/services/payment_links/payment_links_mock.dart';
import 'package:usdc_wallet/mocks/services/beneficiaries/beneficiaries_mock.dart';
import 'package:usdc_wallet/mocks/services/beneficiaries/beneficiaries_contract.dart';
import 'package:usdc_wallet/mocks/services/business/business_mock.dart';
import 'package:usdc_wallet/mocks/services/bulk_payments/bulk_payments_mock.dart';
import 'package:usdc_wallet/mocks/services/sub_business/sub_business_mock.dart';
import 'package:usdc_wallet/mocks/services/cards/cards_mock.dart';
import 'package:usdc_wallet/mocks/services/bank_linking/bank_linking_mock.dart';
import 'package:usdc_wallet/mocks/services/referrals/referrals_mock.dart';
import 'package:usdc_wallet/mocks/services/contacts/contacts_mock.dart';
import 'package:usdc_wallet/mocks/services/user/user_mock.dart';
import 'package:usdc_wallet/mocks/services/wallet/wallet_stats_mock.dart';

/// Mock Registry
///
/// Manages all mock services and provides a central point for:
/// - Registering mock handlers
/// - Printing API contracts
/// - Resetting mock state
class MockRegistry {
  static final MockInterceptor _interceptor = MockInterceptor();
  static bool _isInitialized = false;
  static final _logger = AppLogger('MockRegistry');

  /// Get the mock interceptor (for adding to Dio)
  static MockInterceptor get interceptor => _interceptor;

  /// Initialize all mock services
  static void initialize() {
    if (_isInitialized) return;

    _logger.info('Initializing Mock Registry');

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
    LimitsMock.register(_interceptor);
    PaymentLinksMock.register(_interceptor);
    BeneficiariesMock.register(_interceptor);
    BusinessMock.register(_interceptor);
    BulkPaymentsMock.register(_interceptor);
    SubBusinessMock.register(_interceptor);
    CardsMock.register(_interceptor);
    BankLinkingMock.register(_interceptor);
    ReferralsMock.register(_interceptor);
    ContactsMock.register(_interceptor);
    UserMock.register(_interceptor);
    WalletStatsMock.register(_interceptor);

    // Add more mock services here as they are created:
    // MerchantMock.register(_interceptor);
    // RatesMock.register(_interceptor);

    _isInitialized = true;

    _logger.info('Mock Registry Initialized');
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
    BeneficiariesMockState.reset();
    BulkPaymentsMockState.reset();
    CardsMockState.reset();

    _logger.info('Mock State Reset');
  }

  /// Clear all mock handlers
  static void clear() {
    _interceptor.clear();
    _isInitialized = false;
  }

  /// Print all API contracts
  static void printContracts() {
    if (!kDebugMode) return;

    _logger.info('JoonaPay API Contracts');

    final contracts = [
      AuthContract(),
      WalletContract(),
      TransactionsContract(),
      FeatureFlagsContract(),
      BillPaymentsContract(),
      BeneficiariesContract(),
    ];

    for (final contract in contracts) {
      contract.printContract();
    }
  }

  /// Generate OpenAPI spec for all contracts
  static Map<String, dynamic> generateOpenApiSpec() {
    final contracts = [
      AuthContract(),
      WalletContract(),
      TransactionsContract(),
      FeatureFlagsContract(),
      BillPaymentsContract(),
      BeneficiariesContract(),
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
      BeneficiariesContract(),
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
