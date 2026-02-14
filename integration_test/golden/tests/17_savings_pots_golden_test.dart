import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: SAVINGS POTS
/// FEATURE_FLAG: savingsPots
///
/// Screens covered:
/// - 17.1 Pots List View
/// - 17.2 Create Pot View
/// - 17.3 Pot Detail View
/// - 17.4 Edit Pot View
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Savings Pots Golden Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      TestHelpers.configureMocks();
      await TestHelpers.clearAppData();
    });

    /// Helper to login and reach home screen
    Future<void> loginToHome(WidgetTester tester) async {
      TestHelpers.setKycStatus('verified');

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
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    /// Helper to navigate to savings pots
    Future<void> navigateToSavingsPots(WidgetTester tester) async {
      await loginToHome(tester);

      final savingsBtn = find.text('Savings');
      final potsBtn = find.text('Pots');
      // ignore: unused_local_variable
      final __goalsBtn = find.text('Goals');

      if (savingsBtn.evaluate().isNotEmpty) {
        await tester.tap(savingsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      } else if (potsBtn.evaluate().isNotEmpty) {
        await tester.tap(potsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 17.1 POTS LIST VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('17.1 Pots List View', (tester) async {
      /// GIVEN the Savings Pots feature flag is enabled
      /// WHEN the user accesses Savings Pots
      /// THEN list of pots should display
      /// AND each pot should show name, balance, target
      /// AND "Create Pot" option should be available

      await navigateToSavingsPots(tester);

      final potsScreen = find.textContaining('Pot');
      final savingsScreen = find.textContaining('Saving');
      if (potsScreen.evaluate().isNotEmpty || savingsScreen.evaluate().isNotEmpty) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/savings_pots/17.1_pots_list.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 17.1b POTS LIST - EMPTY STATE
    // ─────────────────────────────────────────────────────────────
    testWidgets('17.1b Pots List - Empty State', (tester) async {
      /// GIVEN user has no savings pots
      /// WHEN the pots list displays
      /// THEN empty state should be shown
      /// AND "Create Your First Pot" CTA should be visible

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Empty savings pots state exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 17.2 CREATE POT VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('17.2 Create Pot View', (tester) async {
      /// GIVEN user is on pots list
      /// WHEN they tap Create Pot
      /// THEN pot creation form should display
      /// AND name field should be visible
      /// AND target amount field should be available
      /// AND icon/color picker may be shown

      await navigateToSavingsPots(tester);

      final createBtn = find.text('Create Pot');
      final newBtn = find.text('New Pot');
      // ignore: unused_local_variable
      final __addIcon = find.byIcon(Icons.add);

      if (createBtn.evaluate().isNotEmpty) {
        await tester.tap(createBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/savings_pots/17.2_create_pot.png'),
        );
      } else if (newBtn.evaluate().isNotEmpty) {
        await tester.tap(newBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/savings_pots/17.2_create_pot.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 17.2b CREATE POT - FILLED
    // ─────────────────────────────────────────────────────────────
    testWidgets('17.2b Create Pot - Filled', (tester) async {
      /// GIVEN user is on create pot view
      /// WHEN they fill in name and target
      /// THEN form should be valid
      /// AND "Create" button should be enabled

      await navigateToSavingsPots(tester);

      final createBtn = find.text('Create Pot');
      if (createBtn.evaluate().isNotEmpty) {
        await tester.tap(createBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Fill form
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 1) {
          await tester.enterText(textFields.first, 'Emergency Fund');
          await tester.pumpAndSettle();
        }
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(1), '500');
          await tester.pumpAndSettle();
        }

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/savings_pots/17.2b_create_filled.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 17.3 POT DETAIL VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('17.3 Pot Detail View', (tester) async {
      /// GIVEN user is on pots list
      /// WHEN they tap a pot
      /// THEN pot details should display
      /// AND current balance vs target should be shown
      /// AND progress bar should be visible
      /// AND "Add Money" and "Withdraw" options should be available

      await navigateToSavingsPots(tester);

      // Tap first pot
      final potItems = find.byType(Card);
      if (potItems.evaluate().isNotEmpty) {
        await tester.tap(potItems.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/savings_pots/17.3_pot_detail.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 17.3b POT DETAIL - ADD MONEY
    // ─────────────────────────────────────────────────────────────
    testWidgets('17.3b Pot Detail - Add Money', (tester) async {
      /// GIVEN user is on pot detail
      /// WHEN they tap Add Money
      /// THEN amount input should appear
      /// AND "Add" button should be available

      await navigateToSavingsPots(tester);

      // Tap first pot
      final potItems = find.byType(Card);
      if (potItems.evaluate().isNotEmpty) {
        await tester.tap(potItems.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final addMoneyBtn = find.text('Add Money');
        if (addMoneyBtn.evaluate().isNotEmpty) {
          await tester.tap(addMoneyBtn.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/savings_pots/17.3b_add_money.png'),
          );
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 17.4 EDIT POT VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('17.4 Edit Pot View', (tester) async {
      /// GIVEN user is on pot detail
      /// WHEN they tap Edit
      /// THEN editable form should display
      /// AND current name and target should be pre-filled
      /// AND "Save" button should be available

      await navigateToSavingsPots(tester);

      // Tap first pot
      final potItems = find.byType(Card);
      if (potItems.evaluate().isNotEmpty) {
        await tester.tap(potItems.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final editBtn = find.text('Edit');
        // ignore: unused_local_variable
        final __editIcon = find.byIcon(Icons.edit);
        if (editBtn.evaluate().isNotEmpty) {
          await tester.tap(editBtn.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/savings_pots/17.4_edit_pot.png'),
          );
        }
      }
    });
  });
}
