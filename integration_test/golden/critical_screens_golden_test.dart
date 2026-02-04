import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';

/// Golden tests for critical screens
/// These capture visual snapshots and compare against saved goldens.
///
/// To update goldens when UI changes intentionally:
/// flutter test integration_test/golden/critical_screens_golden_test.dart --update-goldens
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockConfig.enableAllMocks();
  });

  group('Critical Screens Golden Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    testWidgets('Login screen golden', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if present
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Capture login screen
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_screen.png'),
      );
    });

    testWidgets('OTP screen golden', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      authRobot = AuthRobot(tester);

      // Skip onboarding
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Enter phone and continue
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();

      // Wait for OTP screen
      await TestHelpers.waitForWidget(tester, find.text('Secure Login'));

      // Capture OTP screen
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/otp_screen.png'),
      );
    });

    testWidgets('Identity Verification screen golden', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      authRobot = AuthRobot(tester);

      // Skip onboarding
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Complete login
      await authRobot.completeLogin(skipKycPrompt: true);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // Should be on Identity Verification screen
      // Capture it
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/identity_verification_screen.png'),
      );
    });

    testWidgets('KYC document type selection golden', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      authRobot = AuthRobot(tester);

      // Skip onboarding
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Complete login and tap Start Verification
      await authRobot.completeLogin();
      await tester.pumpAndSettle();

      // Wait for document selection screen
      await tester.pump(const Duration(seconds: 1));

      // Capture document type selection
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/kyc_document_selection.png'),
      );
    });
  });
}
