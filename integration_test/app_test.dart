import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';

// Import all flow tests
import 'flows/auth_flow_test.dart' as auth_flow;
import 'flows/send_money_flow_test.dart' as send_money_flow;
import 'flows/deposit_flow_test.dart' as deposit_flow;
import 'flows/withdraw_flow_test.dart' as withdraw_flow;
import 'flows/kyc_flow_test.dart' as kyc_flow;
import 'flows/settings_flow_test.dart' as settings_flow;
import 'flows/beneficiary_flow_test.dart' as beneficiary_flow;
import 'flows/receive_flow_test.dart' as receive_flow;
import 'flows/transaction_history_flow_test.dart' as transaction_history_flow;
import 'flows/pin_security_flow_test.dart' as pin_security_flow;
import 'flows/error_scenarios_flow_test.dart' as error_scenarios_flow;
import 'flows/onboarding_flow_test.dart' as onboarding_flow;
import 'flows/wallet_flow_test.dart' as wallet_flow;
import 'flows/bill_pay_flow_test.dart' as bill_pay_flow;
import 'flows/app_smoke_test.dart' as app_smoke;

/// Main integration test entry point
///
/// This runs all integration tests in sequence.
/// To run specific tests, use the individual flow test files.
///
/// Run with:
/// ```
/// flutter test integration_test/app_test.dart
/// ```
///
/// Or run on device:
/// ```
/// flutter drive \
///   --driver=integration_test/test_driver/integration_test.dart \
///   --target=integration_test/app_test.dart
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Enable mocks globally
  setUpAll(() {
    MockConfig.enableAllMocks();
  });

  group('JoonaPay Integration Tests', () {
    // Core flows
    auth_flow.main();
    onboarding_flow.main();

    // Money flows
    send_money_flow.main();
    receive_flow.main();
    deposit_flow.main();
    withdraw_flow.main();

    // Feature flows
    kyc_flow.main();
    settings_flow.main();
    beneficiary_flow.main();
    transaction_history_flow.main();

    // Wallet & payments
    wallet_flow.main();
    bill_pay_flow.main();

    // Security & error handling
    pin_security_flow.main();
    error_scenarios_flow.main();

    // Smoke tests
    app_smoke.main();
  });
}
