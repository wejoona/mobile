import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../robots/auth_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockConfig.enableAllMocks();
    MockConfig.networkDelayMs = 0;
  });

  group('Bill Pay Flow Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    testWidgets('Browse bill categories and select provider', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding if present
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        // Login first
        await authRobot.completeLogin();
        await tester.pumpAndSettle();

        // Navigate to bill pay — look for common entry points
        final billPayFinder = find.textContaining(RegExp(r'Bill|Pay Bill|Bills'));
        if (billPayFinder.evaluate().isNotEmpty) {
          await tester.tap(billPayFinder.first);
          await tester.pumpAndSettle();

          // Verify categories are displayed
          // Categories like Electricity, Water, Internet should appear
          expect(
            find.byType(ListView).evaluate().isNotEmpty ||
                find.byType(GridView).evaluate().isNotEmpty,
            isTrue,
            reason: 'Expected a list or grid of bill categories',
          );
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'bill_pay_flow_error');
        rethrow;
      }
    });

    testWidgets('Complete bill payment flow', (tester) async {
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

        // Login
        await authRobot.completeLogin();
        await tester.pumpAndSettle();

        // Navigate to bill pay
        final billPayFinder = find.textContaining(RegExp(r'Bill|Pay Bill|Bills'));
        if (billPayFinder.evaluate().isNotEmpty) {
          await tester.tap(billPayFinder.first);
          await tester.pumpAndSettle();

          // Select first category if available
          final categoryItems = find.byType(InkWell);
          if (categoryItems.evaluate().length > 1) {
            await tester.tap(categoryItems.first);
            await tester.pumpAndSettle();
          }

          // Select first provider if available
          final providerItems = find.byType(Card);
          if (providerItems.evaluate().isNotEmpty) {
            await tester.tap(providerItems.first);
            await tester.pumpAndSettle();
          }

          // Look for amount field or form fields
          final textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            await tester.enterText(textFields.first, '10');
            await tester.pumpAndSettle();
          }

          // Look for a pay/submit button
          final payButton = find.textContaining(RegExp(r'Pay|Submit|Continue'));
          if (payButton.evaluate().isNotEmpty) {
            await tester.tap(payButton.first);
            await tester.pumpAndSettle();
          }
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'bill_pay_complete_error');
        rethrow;
      }
    });
  });
}
