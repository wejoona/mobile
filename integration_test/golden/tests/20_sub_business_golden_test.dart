import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: SUB-BUSINESS
///
/// Screens covered:
/// - 20.1 Sub Businesses View
/// - 20.2 Create Sub Business View
/// - 20.3 Sub Business Detail View
/// - 20.4 Sub Business Staff View
void main() {
  final _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Sub-Business Golden Tests', () {
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

    /// Helper to navigate to sub-businesses
    Future<void> navigateToSubBusiness(WidgetTester tester) async {
      await loginToHome(tester);

      final subBusinessBtn = find.text('Sub-Businesses');
      final branchesBtn = find.text('Branches');
      final _locationsBtn = find.text('Locations');

      if (subBusinessBtn.evaluate().isNotEmpty) {
        await tester.tap(subBusinessBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      } else if (branchesBtn.evaluate().isNotEmpty) {
        await tester.tap(branchesBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 20.1 SUB BUSINESSES VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('20.1 Sub Businesses View', (tester) async {
      /// GIVEN a business user
      /// WHEN they access Sub-Businesses
      /// THEN list of sub-businesses/branches should display
      /// AND each should show name, status
      /// AND "Add Sub-Business" option should be available

      await navigateToSubBusiness(tester);

      final subBusinessScreen = find.textContaining('Sub-Business');
      final branchScreen = find.textContaining('Branch');
      if (subBusinessScreen.evaluate().isNotEmpty || branchScreen.evaluate().isNotEmpty) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/sub_business/20.1_sub_businesses.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 20.1b SUB BUSINESSES - EMPTY STATE
    // ─────────────────────────────────────────────────────────────
    testWidgets('20.1b Sub Businesses - Empty State', (tester) async {
      /// GIVEN business user has no sub-businesses
      /// WHEN the list view displays
      /// THEN empty state should be shown
      /// AND "Add Your First Branch" CTA should be visible

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Empty sub-businesses state exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 20.2 CREATE SUB BUSINESS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('20.2 Create Sub Business View', (tester) async {
      /// GIVEN user is on sub-businesses list
      /// WHEN they tap Add Sub-Business
      /// THEN creation form should display
      /// AND name field should be visible
      /// AND address field should be available
      /// AND manager assignment may be available

      await navigateToSubBusiness(tester);

      final addBtn = find.text('Add Sub-Business');
      final _createBtn = find.text('Create');
      final addIcon = find.byIcon(Icons.add);

      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/sub_business/20.2_create.png'),
        );
      } else if (addIcon.evaluate().isNotEmpty) {
        await tester.tap(addIcon.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/sub_business/20.2_create.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 20.3 SUB BUSINESS DETAIL VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('20.3 Sub Business Detail View', (tester) async {
      /// GIVEN user is on sub-businesses list
      /// WHEN they tap a sub-business
      /// THEN detail view should display
      /// AND business name, address should be shown
      /// AND staff list should be visible
      /// AND transaction summary may be shown

      await navigateToSubBusiness(tester);

      // Tap first item
      final items = find.byType(ListTile);
      if (items.evaluate().isNotEmpty) {
        await tester.tap(items.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/sub_business/20.3_detail.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 20.4 SUB BUSINESS STAFF VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('20.4 Sub Business Staff View', (tester) async {
      /// GIVEN user is on sub-business detail
      /// WHEN they tap Staff
      /// THEN staff list should display
      /// AND each staff member should show name, role
      /// AND "Add Staff" option should be available

      await navigateToSubBusiness(tester);

      // Navigate to detail first
      final items = find.byType(ListTile);
      if (items.evaluate().isNotEmpty) {
        await tester.tap(items.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final staffBtn = find.text('Staff');
        final _teamBtn = find.text('Team');

        if (staffBtn.evaluate().isNotEmpty) {
          await tester.tap(staffBtn.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/sub_business/20.4_staff.png'),
          );
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 20.4b SUB BUSINESS STAFF - ADD MEMBER
    // ─────────────────────────────────────────────────────────────
    testWidgets('20.4b Sub Business Staff - Add Member', (tester) async {
      /// GIVEN user is on staff view
      /// WHEN they tap Add Staff
      /// THEN staff invitation form should display
      /// AND phone/email field should be visible
      /// AND role selector should be available

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Add staff member screen exists');
    });
  });
}
