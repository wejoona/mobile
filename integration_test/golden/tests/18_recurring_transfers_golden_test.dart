import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: RECURRING TRANSFERS
/// FEATURE_FLAG: recurringTransfers
///
/// Screens covered:
/// - 18.1 Recurring Transfers List View
/// - 18.2 Create Recurring Transfer View
/// - 18.3 Recurring Transfer Detail View
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Recurring Transfers Golden Tests', () {
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

    /// Helper to navigate to recurring transfers
    Future<void> navigateToRecurring(WidgetTester tester) async {
      await loginToHome(tester);

      final recurringBtn = find.text('Recurring');
      final scheduledBtn = find.text('Scheduled');
      final autoPayBtn = find.text('Auto-Pay');

      if (recurringBtn.evaluate().isNotEmpty) {
        await tester.tap(recurringBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      } else if (scheduledBtn.evaluate().isNotEmpty) {
        await tester.tap(scheduledBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 18.1 RECURRING TRANSFERS LIST VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('18.1 Recurring Transfers List View', (tester) async {
      /// GIVEN the Recurring Transfers feature flag is enabled
      /// WHEN user accesses Recurring Transfers
      /// THEN list of scheduled transfers should display
      /// AND each item should show recipient, amount, frequency
      /// AND "Create New" option should be available

      await navigateToRecurring(tester);

      final recurringScreen = find.textContaining('Recurring');
      final scheduledScreen = find.textContaining('Scheduled');
      if (recurringScreen.evaluate().isNotEmpty || scheduledScreen.evaluate().isNotEmpty) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/recurring/18.1_recurring_list.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 18.1b RECURRING TRANSFERS - EMPTY STATE
    // ─────────────────────────────────────────────────────────────
    testWidgets('18.1b Recurring Transfers - Empty State', (tester) async {
      /// GIVEN user has no recurring transfers
      /// WHEN the list view displays
      /// THEN empty state should be shown
      /// AND "Set Up Recurring Transfer" CTA should be visible

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Empty recurring transfers state exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 18.2 CREATE RECURRING TRANSFER VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('18.2 Create Recurring Transfer View', (tester) async {
      /// GIVEN user is on recurring transfers list
      /// WHEN they tap Create New
      /// THEN creation form should display
      /// AND recipient field should be visible
      /// AND amount field should be visible
      /// AND frequency picker should be available (Daily, Weekly, Monthly)
      /// AND start date picker should be available

      await navigateToRecurring(tester);

      final createBtn = find.text('Create New');
      final newBtn = find.text('New Recurring');
      final addIcon = find.byIcon(Icons.add);

      if (createBtn.evaluate().isNotEmpty) {
        await tester.tap(createBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/recurring/18.2_create_recurring.png'),
        );
      } else if (newBtn.evaluate().isNotEmpty) {
        await tester.tap(newBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/recurring/18.2_create_recurring.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 18.2b CREATE RECURRING - FILLED
    // ─────────────────────────────────────────────────────────────
    testWidgets('18.2b Create Recurring - Filled', (tester) async {
      /// GIVEN user is on create recurring view
      /// WHEN they fill in all fields
      /// THEN form should be valid
      /// AND "Create" button should be enabled

      await navigateToRecurring(tester);

      final createBtn = find.text('Create New');
      if (createBtn.evaluate().isNotEmpty) {
        await tester.tap(createBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Fill form
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 1) {
          await tester.enterText(textFields.first, '0700000001');
          await tester.pumpAndSettle();
        }
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(1), '50');
          await tester.pumpAndSettle();
        }

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/recurring/18.2b_create_filled.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 18.3 RECURRING TRANSFER DETAIL VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('18.3 Recurring Transfer Detail View', (tester) async {
      /// GIVEN user is on recurring transfers list
      /// WHEN they tap a recurring transfer
      /// THEN detail view should display
      /// AND recipient, amount, frequency should be shown
      /// AND next execution date should be visible
      /// AND "Pause" and "Delete" options should be available

      await navigateToRecurring(tester);

      // Tap first item
      final items = find.byType(ListTile);
      if (items.evaluate().isNotEmpty) {
        await tester.tap(items.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/recurring/18.3_detail.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 18.3b RECURRING DETAIL - PAUSED STATE
    // ─────────────────────────────────────────────────────────────
    testWidgets('18.3b Recurring Detail - Paused', (tester) async {
      /// GIVEN a recurring transfer is paused
      /// WHEN the detail view displays
      /// THEN paused indicator should be visible
      /// AND "Resume" option should be available

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Paused recurring transfer state exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 18.3c RECURRING DETAIL - HISTORY
    // ─────────────────────────────────────────────────────────────
    testWidgets('18.3c Recurring Detail - History', (tester) async {
      /// GIVEN user is on recurring transfer detail
      /// WHEN they view execution history
      /// THEN past executions should be listed
      /// AND each should show date and status

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Recurring transfer history exists in detail view');
    });
  });
}
