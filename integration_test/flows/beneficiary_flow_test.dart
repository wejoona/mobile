import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockConfig.enableAllMocks();
  });

  group('Beneficiary Flow Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginAndNavigateToBeneficiaries(WidgetTester tester) async {
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

      // Navigate to beneficiaries
      // This might be in settings or have its own menu item
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await TestHelpers.scrollUntilVisible(
        tester,
        find.text('Beneficiaries'),
      );
      await tester.tap(find.text('Beneficiaries'));
      await tester.pumpAndSettle();
    }

    testWidgets('View beneficiaries list', (tester) async {
      try {
        await loginAndNavigateToBeneficiaries(tester);

        // Verify on beneficiaries screen
        expect(find.text('Beneficiaries'), findsWidgets);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'beneficiaries_list_error');
        rethrow;
      }
    });

    testWidgets('Add new beneficiary', (tester) async {
      try {
        await loginAndNavigateToBeneficiaries(tester);

        // Tap add button
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Enter beneficiary details
        await tester.enterText(
          find.widgetWithText(TextField, 'Name'),
          'Test Beneficiary',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Phone'),
          '+225 07 11 22 33 44',
        );
        await tester.pumpAndSettle();

        // Save
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Verify added
        expect(find.text('Test Beneficiary'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'add_beneficiary_error');
        rethrow;
      }
    });

    testWidgets('Edit beneficiary', (tester) async {
      try {
        await loginAndNavigateToBeneficiaries(tester);

        // Find a beneficiary
        final beneficiary = find.text('Test Beneficiary');
        if (beneficiary.evaluate().isNotEmpty) {
          // Tap to open detail
          await tester.tap(beneficiary);
          await tester.pumpAndSettle();

          // Tap edit
          await tester.tap(find.byIcon(Icons.edit));
          await tester.pumpAndSettle();

          // Edit name
          final nameField = find.widgetWithText(TextField, 'Name');
          await tester.enterText(nameField, 'Updated Beneficiary');
          await tester.pumpAndSettle();

          // Save
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          // Verify updated
          expect(find.text('Updated Beneficiary'), findsOneWidget);
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'edit_beneficiary_error');
        rethrow;
      }
    });

    testWidgets('Delete beneficiary', (tester) async {
      try {
        await loginAndNavigateToBeneficiaries(tester);

        // Find a beneficiary
        final beneficiary = find.text('Test Beneficiary');
        if (beneficiary.evaluate().isNotEmpty) {
          // Long press or swipe to delete
          await tester.longPress(beneficiary);
          await tester.pumpAndSettle();

          // Confirm delete
          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          // Verify deleted
          expect(beneficiary, findsNothing);
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'delete_beneficiary_error');
        rethrow;
      }
    });

    testWidgets('Mark beneficiary as favorite', (tester) async {
      try {
        await loginAndNavigateToBeneficiaries(tester);

        // Find a beneficiary
        final beneficiary = find.text('Test Beneficiary');
        if (beneficiary.evaluate().isNotEmpty) {
          // Tap to open detail
          await tester.tap(beneficiary);
          await tester.pumpAndSettle();

          // Tap favorite icon
          await tester.tap(find.byIcon(Icons.favorite_border));
          await tester.pumpAndSettle();

          // Should change to filled favorite
          expect(find.byIcon(Icons.favorite), findsOneWidget);
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'favorite_beneficiary_error');
        rethrow;
      }
    });

    testWidgets('Search beneficiaries', (tester) async {
      try {
        await loginAndNavigateToBeneficiaries(tester);

        // Tap search
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        // Enter search query
        await tester.enterText(find.byType(TextField), 'Test');
        await tester.pumpAndSettle();

        // Should filter results
        expect(find.text('Test Beneficiary'), findsWidgets);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'search_beneficiary_error');
        rethrow;
      }
    });
  });
}
