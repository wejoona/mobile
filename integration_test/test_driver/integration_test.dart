import 'package:integration_test/integration_test_driver.dart';

/// Test driver for integration tests
///
/// This enables running integration tests on real devices and emulators.
/// It handles communication between the Flutter app and the test runner.
///
/// Usage:
/// ```bash
/// flutter drive \
///   --driver=integration_test/test_driver/integration_test.dart \
///   --target=integration_test/app_test.dart
/// ```
Future<void> main() => integrationDriver();
