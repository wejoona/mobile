import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';
import '../robots/wallet_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockConfig.enableAllMocks();
  });

  group('Withdraw Flow Tests', () {
    late AuthRobot authRobot;
    late WalletRobot walletRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginAndNavigateToWithdraw(WidgetTester tester) async {
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

      // Navigate to withdraw
      await walletRobot.tapWithdrawAction();
    }

    testWidgets('Complete withdraw to Orange Money', (tester) async {
      try {
        await loginAndNavigateToWithdraw(tester);

        // Verify on withdraw screen
        expect(find.text('Withdraw'), findsWidgets);

        // Enter phone number for mobile money
        final phoneField = find.byType(TextField).first;
        await tester.enterText(phoneField, '07 12 34 56 78');
        await tester.pumpAndSettle();

        // Enter amount
        await tester.tap(find.text('5'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Select Orange Money
        await tester.tap(find.text('Orange Money'));
        await tester.pumpAndSettle();

        // Continue
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Confirm
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // Enter PIN
        await TestHelpers.waitForWidget(tester, find.text('Enter PIN'));
        await TestHelpers.enterPin(tester, TestData.testPin);

        // Wait for result
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify success or pending
        expect(
          find.textContaining('Withdraw'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'withdraw_orange_error');
        rethrow;
      }
    });

    testWidgets('Withdraw with insufficient balance', (tester) async {
      try {
        await loginAndNavigateToWithdraw(tester);

        // Enter phone
        final phoneField = find.byType(TextField).first;
        await tester.enterText(phoneField, '07 12 34 56 78');
        await tester.pumpAndSettle();

        // Enter very large amount
        await tester.tap(find.text('9'));
        await tester.tap(find.text('9'));
        await tester.tap(find.text('9'));
        await tester.tap(find.text('9'));
        await tester.tap(find.text('9'));
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();

        // Try to continue
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Should see error
        expect(
          find.textContaining('Insufficient'),
          findsOneWidget,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'withdraw_insufficient_error');
        rethrow;
      }
    });

    testWidgets('Cancel withdraw flow', (tester) async {
      try {
        await loginAndNavigateToWithdraw(tester);

        // Enter details
        final phoneField = find.byType(TextField).first;
        await tester.enterText(phoneField, '07 12 34 56 78');
        await tester.pumpAndSettle();

        await tester.tap(find.text('5'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Go back
        await TestHelpers.tapBackButton(tester);

        // Should be on home
        walletRobot.verifyOnHomeScreen();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'cancel_withdraw_error');
        rethrow;
      }
    });
  });
}
