import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';

/// Capture golden images of all critical screens
/// Run with: flutter test integration_test/golden/capture_screens_test.dart --update-goldens
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => MockConfig.enableAllMocks());

  group('Capture Golden Screens', () {
    late AuthRobot authRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    testWidgets('1. Login Screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/01_login_screen.png'),
      );
    });

    testWidgets('2. OTP Screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/02_otp_screen.png'),
      );
    });

    testWidgets('3. Identity Verification Screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await authRobot.completeLogin(skipKycPrompt: true);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/03_identity_verification.png'),
      );
    });

    testWidgets('4. After Start Verification', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await authRobot.completeLogin();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/04_after_start_verification.png'),
      );
    });
  });
}
