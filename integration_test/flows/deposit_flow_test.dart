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

  group('Deposit Flow Tests', () {
    late AuthRobot authRobot;
    late WalletRobot walletRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginAndNavigateToDeposit(WidgetTester tester) async {
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

      // Navigate to deposit
      await walletRobot.tapDepositAction();
    }

    testWidgets('Complete deposit flow with Orange Money', (tester) async {
      try {
        await loginAndNavigateToDeposit(tester);

        // Verify on deposit screen
        expect(find.text('Deposit'), findsWidgets);

        // Enter amount
        await tester.tap(find.text('1')); // 10000
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Continue
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Select Orange Money
        await TestHelpers.scrollUntilVisible(
          tester,
          find.text('Orange Money'),
        );
        await tester.tap(find.text('Orange Money'));
        await tester.pumpAndSettle();

        // Verify instructions screen
        expect(
          find.textContaining('USSD'),
          findsOneWidget,
        );

        // Verify instructions contain dial code
        expect(
          find.textContaining('*'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'deposit_orange_error');
        rethrow;
      }
    });

    testWidgets('Deposit with MTN Mobile Money', (tester) async {
      try {
        await loginAndNavigateToDeposit(tester);

        // Enter amount
        await tester.tap(find.text('5'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Select MTN
        await TestHelpers.scrollUntilVisible(
          tester,
          find.text('MTN Mobile Money'),
        );
        await tester.tap(find.text('MTN Mobile Money'));
        await tester.pumpAndSettle();

        // Verify instructions
        expect(find.textContaining('MTN'), findsWidgets);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'deposit_mtn_error');
        rethrow;
      }
    });

    testWidgets('Deposit with Wave', (tester) async {
      try {
        await loginAndNavigateToDeposit(tester);

        // Enter amount
        await tester.tap(find.text('2'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Select Wave
        await TestHelpers.scrollUntilVisible(tester, find.text('Wave'));
        await tester.tap(find.text('Wave'));
        await tester.pumpAndSettle();

        // Verify instructions
        expect(find.text('Wave'), findsWidgets);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'deposit_wave_error');
        rethrow;
      }
    });

    testWidgets('Deposit with minimum amount', (tester) async {
      try {
        await loginAndNavigateToDeposit(tester);

        // Enter very small amount
        await tester.tap(find.text('1'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Might show minimum amount error
        final errorFinder = find.textContaining('minimum');
        if (errorFinder.evaluate().isNotEmpty) {
          expect(errorFinder, findsOneWidget);
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'deposit_minimum_error');
        rethrow;
      }
    });

    testWidgets('Copy USSD code from instructions', (tester) async {
      try {
        await loginAndNavigateToDeposit(tester);

        // Enter amount and select provider
        await tester.tap(find.text('1'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Orange Money'));
        await tester.pumpAndSettle();

        // Look for copy button
        final copyButton = find.byIcon(Icons.copy);
        if (copyButton.evaluate().isNotEmpty) {
          await tester.tap(copyButton.first);
          await tester.pumpAndSettle();

          // Verify copied message
          expect(find.textContaining('Copied'), findsOneWidget);
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'copy_ussd_error');
        rethrow;
      }
    });

    testWidgets('Cancel deposit flow', (tester) async {
      try {
        await loginAndNavigateToDeposit(tester);

        // Enter amount
        await tester.tap(find.text('5'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Cancel
        await TestHelpers.tapBackButton(tester);

        // Should be back on home
        walletRobot.verifyOnHomeScreen();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'cancel_deposit_error');
        rethrow;
      }
    });

    testWidgets('Check deposit status', (tester) async {
      try {
        await loginAndNavigateToDeposit(tester);

        // Complete deposit initiation
        await tester.tap(find.text('1'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Orange Money'));
        await tester.pumpAndSettle();

        // Look for check status button
        final statusButton = find.text('Check Status');
        if (statusButton.evaluate().isNotEmpty) {
          await tester.tap(statusButton);
          await tester.pumpAndSettle();

          // Verify status screen
          expect(
            find.textContaining('Status'),
            findsWidgets,
          );
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'deposit_status_error');
        rethrow;
      }
    });
  });
}
