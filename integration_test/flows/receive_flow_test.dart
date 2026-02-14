import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../robots/auth_robot.dart';
import '../robots/wallet_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockConfig.enableAllMocks();
  });

  group('Receive Money Flow Tests', () {
    late AuthRobot authRobot;
    late WalletRobot walletRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginAndNavigateToReceive(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      authRobot = AuthRobot(tester);
      walletRobot = WalletRobot(tester);

      // Skip onboarding
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Login
      await authRobot.completeLogin();

      // Navigate to receive
      await walletRobot.tapReceiveAction();
    }

    testWidgets('View receive QR code screen', (tester) async {
      try {
        await loginAndNavigateToReceive(tester);

        // Verify on receive screen
        expect(find.text('Receive'), findsWidgets);

        // Should show QR code
        expect(find.byType(Image), findsWidgets);

        // Should show wallet address
        expect(find.textContaining('0x'), findsWidgets);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'receive_qr_error');
        rethrow;
      }
    });

    testWidgets('Copy wallet address to clipboard', (tester) async {
      try {
        await loginAndNavigateToReceive(tester);

        // Find and tap copy button
        final copyButton = find.byIcon(Icons.copy);
        if (copyButton.evaluate().isNotEmpty) {
          await tester.tap(copyButton.first);
          await tester.pumpAndSettle();

          // Verify copied message
          expect(
            find.textContaining('Copied'),
            findsWidgets,
          );
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'copy_address_error');
        rethrow;
      }
    });

    testWidgets('Share wallet address', (tester) async {
      try {
        await loginAndNavigateToReceive(tester);

        // Find and tap share button
        final shareButton = find.text('Share');
        if (shareButton.evaluate().isNotEmpty) {
          await tester.tap(shareButton);
          await tester.pumpAndSettle();

          // Share sheet should appear (platform dependent)
          await tester.pump(const Duration(seconds: 1));
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'share_address_error');
        rethrow;
      }
    });

    testWidgets('Save QR code to gallery', (tester) async {
      try {
        await loginAndNavigateToReceive(tester);

        // Find and tap save button
        final saveButton = find.text('Save');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Verify saved message
          expect(
            find.textContaining('Saved'),
            findsWidgets,
          );
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'save_qr_error');
        rethrow;
      }
    });

    testWidgets('Navigate back from receive screen', (tester) async {
      try {
        await loginAndNavigateToReceive(tester);

        // Go back
        await TestHelpers.tapBackButton(tester);

        // Should be on home screen
        walletRobot.verifyOnHomeScreen();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'receive_back_error');
        rethrow;
      }
    });

    testWidgets('View receive amount request', (tester) async {
      try {
        await loginAndNavigateToReceive(tester);

        // Find request amount option
        final requestButton = find.text('Request Amount');
        if (requestButton.evaluate().isNotEmpty) {
          await tester.tap(requestButton);
          await tester.pumpAndSettle();

          // Enter amount
          await tester.tap(find.text('1'));
          await tester.tap(find.text('0'));
          await tester.tap(find.text('0'));
          await tester.tap(find.text('0'));
          await tester.tap(find.text('0'));
          await tester.pumpAndSettle();

          // Generate QR with amount
          await tester.tap(find.text('Generate'));
          await tester.pumpAndSettle();

          // Should show QR with amount
          expect(find.textContaining('10,000'), findsWidgets);
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'request_amount_error');
        rethrow;
      }
    });
  });
}
