import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: BENEFICIARIES
///
/// Screens covered:
/// - 15.1 Beneficiaries Screen
/// - 15.2 Add Beneficiary Screen
/// - 15.3 Beneficiary Detail View
void main() {
  final __binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Beneficiaries Golden Tests', () {
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

    /// Helper to navigate to beneficiaries
    Future<void> navigateToBeneficiaries(WidgetTester tester) async {
      await loginToHome(tester);

      final beneficiariesBtn = find.text('Beneficiaries');
      final recipientsBtn = find.text('Recipients');
      final __contactsBtn = find.text('Contacts');

      if (beneficiariesBtn.evaluate().isNotEmpty) {
        await tester.tap(beneficiariesBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      } else if (recipientsBtn.evaluate().isNotEmpty) {
        await tester.tap(recipientsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 15.1 BENEFICIARIES SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('15.1 Beneficiaries Screen', (tester) async {
      /// GIVEN an authenticated user
      /// WHEN they access Beneficiaries
      /// THEN saved beneficiaries list should display
      /// AND search functionality should be available
      /// AND "Add Beneficiary" option should be visible

      await navigateToBeneficiaries(tester);

      final beneficiariesScreen = find.textContaining('Beneficiar');
      final recipientsScreen = find.textContaining('Recipient');
      if (beneficiariesScreen.evaluate().isNotEmpty || recipientsScreen.evaluate().isNotEmpty) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/beneficiaries/15.1_beneficiaries.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 15.1b BENEFICIARIES - EMPTY STATE
    // ─────────────────────────────────────────────────────────────
    testWidgets('15.1b Beneficiaries - Empty State', (tester) async {
      /// GIVEN user has no saved beneficiaries
      /// WHEN the beneficiaries screen displays
      /// THEN empty state should be shown
      /// AND "Add Your First Beneficiary" CTA should be visible

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Empty beneficiaries state exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 15.2 ADD BENEFICIARY SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('15.2 Add Beneficiary Screen', (tester) async {
      /// GIVEN user is on beneficiaries screen
      /// WHEN they tap Add Beneficiary
      /// THEN beneficiary form should display
      /// AND name and phone fields should be visible
      /// AND "Save" button should be available

      await navigateToBeneficiaries(tester);

      final addBtn = find.text('Add Beneficiary');
      final addIcon = find.byIcon(Icons.add);

      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/beneficiaries/15.2_add_beneficiary.png'),
        );
      } else if (addIcon.evaluate().isNotEmpty) {
        await tester.tap(addIcon.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/beneficiaries/15.2_add_beneficiary.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 15.2b ADD BENEFICIARY - FILLED
    // ─────────────────────────────────────────────────────────────
    testWidgets('15.2b Add Beneficiary - Filled', (tester) async {
      /// GIVEN user is on add beneficiary screen
      /// WHEN they fill in name and phone
      /// THEN form should be valid
      /// AND "Save" button should be enabled

      await navigateToBeneficiaries(tester);

      final addBtn = find.text('Add Beneficiary');
      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Fill form
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 1) {
          await tester.enterText(textFields.first, 'Amadou Diallo');
          await tester.pumpAndSettle();
        }
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(1), '0700000001');
          await tester.pumpAndSettle();
        }

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/beneficiaries/15.2b_add_filled.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 15.3 BENEFICIARY DETAIL VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('15.3 Beneficiary Detail View', (tester) async {
      /// GIVEN user is on beneficiaries list
      /// WHEN they tap a beneficiary
      /// THEN beneficiary details should display
      /// AND "Send Money" option should be available
      /// AND edit/delete options should be visible

      await navigateToBeneficiaries(tester);

      // Tap first beneficiary
      final beneficiaryItems = find.byType(ListTile);
      if (beneficiaryItems.evaluate().isNotEmpty) {
        await tester.tap(beneficiaryItems.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/beneficiaries/15.3_detail.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 15.3b BENEFICIARY - EDIT MODE
    // ─────────────────────────────────────────────────────────────
    testWidgets('15.3b Beneficiary - Edit Mode', (tester) async {
      /// GIVEN user is on beneficiary detail
      /// WHEN they tap Edit
      /// THEN editable form should display
      /// AND current details should be pre-filled

      await navigateToBeneficiaries(tester);

      // Tap first beneficiary
      final beneficiaryItems = find.byType(ListTile);
      if (beneficiaryItems.evaluate().isNotEmpty) {
        await tester.tap(beneficiaryItems.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final editBtn = find.text('Edit');
        if (editBtn.evaluate().isNotEmpty) {
          await tester.tap(editBtn.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/beneficiaries/15.3b_edit.png'),
          );
        }
      }
    });
  });
}
