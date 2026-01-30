import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Import all flow tests
import 'flows/auth_flow_test.dart' as auth_flow;
import 'flows/send_money_flow_test.dart' as send_money_flow;
import 'flows/deposit_flow_test.dart' as deposit_flow;
import 'flows/withdraw_flow_test.dart' as withdraw_flow;
import 'flows/kyc_flow_test.dart' as kyc_flow;
import 'flows/settings_flow_test.dart' as settings_flow;
import 'flows/beneficiary_flow_test.dart' as beneficiary_flow;

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

  group('JoonaPay Integration Tests', () {
    // Run all flow tests
    auth_flow.main();
    send_money_flow.main();
    deposit_flow.main();
    withdraw_flow.main();
    kyc_flow.main();
    settings_flow.main();
    beneficiary_flow.main();
  });
}
