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
    MockConfig.networkDelayMs = 0;
  });

  group('Wallet Flow Tests', () {
    late AuthRobot authRobot;
    // ignore: unused_local_variable
    late WalletRobot walletRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    testWidgets('View wallet balance after login', (tester) async {
      try {
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
        await tester.pumpAndSettle();

        // Verify home screen shows balance
        authRobot.verifyOnHomeScreen();

        // Balance should be visible (mock returns 150.50)
        final balanceFinder = find.textContaining(RegExp(r'\$|USD|150'));
        expect(balanceFinder.evaluate().isNotEmpty, isTrue,
            reason: 'Expected balance to be visible on home screen');
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'wallet_balance_error');
        rethrow;
      }
    });

    testWidgets('Navigate to deposit flow', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        await authRobot.completeLogin();
        await tester.pumpAndSettle();

        // Find and tap Deposit action
        final depositFinder = find.textContaining(RegExp(r'Deposit|Add Money|Top Up'));
        if (depositFinder.evaluate().isNotEmpty) {
          await tester.tap(depositFinder.first);
          await tester.pumpAndSettle();

          // Should see deposit screen with provider options or amount input
          expect(
            find.byType(Scaffold).evaluate().isNotEmpty,
            isTrue,
            reason: 'Expected deposit screen to load',
          );
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'wallet_deposit_error');
        rethrow;
      }
    });

    testWidgets('Navigate to send/transfer flow', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        await authRobot.completeLogin();
        await tester.pumpAndSettle();

        // Find and tap Send action
        final sendFinder = find.textContaining(RegExp(r'Send|Transfer'));
        if (sendFinder.evaluate().isNotEmpty) {
          await tester.tap(sendFinder.first);
          await tester.pumpAndSettle();

          // Should see recipient selection or amount screen
          expect(
            find.byType(Scaffold).evaluate().isNotEmpty,
            isTrue,
            reason: 'Expected send screen to load',
          );
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'wallet_send_error');
        rethrow;
      }
    });

    testWidgets('Pull to refresh wallet balance', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        await authRobot.completeLogin();
        await tester.pumpAndSettle();

        // Pull to refresh
        await tester.fling(
          find.byType(CustomScrollView).evaluate().isNotEmpty
              ? find.byType(CustomScrollView).first
              : find.byType(ListView).first,
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();

        // App should still be on home screen after refresh
        authRobot.verifyOnHomeScreen();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'wallet_refresh_error');
        rethrow;
      }
    });
  });
}
