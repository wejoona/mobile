import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';
import '../robots/settings_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockConfig.enableAllMocks();
  });

  group('KYC Flow Tests', () {
    late AuthRobot authRobot;
    late SettingsRobot settingsRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginAndNavigateToKyc(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      authRobot = AuthRobot(tester);
      settingsRobot = SettingsRobot(tester);

      // Skip onboarding
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Login
      await authRobot.completeLogin();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Navigate to KYC
      await settingsRobot.openKyc();
    }

    testWidgets('View KYC status', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Verify KYC status screen
        expect(find.text('KYC'), findsWidgets);

        // Should show current status
        expect(
          find.textContaining('Status'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_status_error');
        rethrow;
      }
    });

    testWidgets('Select document type', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Start KYC process
        final startButton = find.text('Start KYC');
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton);
          await tester.pumpAndSettle();

          // Select National ID
          await tester.tap(find.text('National ID Card'));
          await tester.pumpAndSettle();

          // Continue
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();

          // Should be on document capture screen
          expect(
            find.textContaining('Capture'),
            findsWidgets,
          );
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_document_type_error');
        rethrow;
      }
    });

    testWidgets('Navigate through KYC steps', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        final startButton = find.text('Start KYC');
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton);
          await tester.pumpAndSettle();

          // Select Passport
          await tester.tap(find.text('Passport'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();

          // Verify on capture screen
          expect(find.textContaining('Passport'), findsWidgets);

          // Note: Actual camera capture would require mocking
          // or device/emulator with camera
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_steps_error');
        rethrow;
      }
    });

    testWidgets('Cancel KYC process', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        final startButton = find.text('Start KYC');
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton);
          await tester.pumpAndSettle();

          // Go back
          await TestHelpers.tapBackButton(tester);

          // Should be back on KYC status
          expect(find.text('KYC'), findsWidgets);
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_cancel_error');
        rethrow;
      }
    });

    testWidgets('View KYC limits by tier', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Look for limits information
        await TestHelpers.scrollUntilVisible(
          tester,
          find.textContaining('Limit'),
        );

        // Verify limits are displayed
        expect(find.textContaining('Daily'), findsWidgets);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_limits_error');
        rethrow;
      }
    });
  });
}
