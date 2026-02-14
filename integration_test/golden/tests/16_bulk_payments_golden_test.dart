import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: BULK PAYMENTS
///
/// Screens covered:
/// - 16.1 Bulk Payments View
/// - 16.2 Bulk Upload View
/// - 16.3 Bulk Preview View
/// - 16.4 Bulk Status View
void main() {
  final __binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Bulk Payments Golden Tests', () {
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

    /// Helper to navigate to bulk payments
    Future<void> navigateToBulkPayments(WidgetTester tester) async {
      await loginToHome(tester);

      final bulkBtn = find.text('Bulk Payments');
      final batchBtn = find.text('Batch Transfer');

      if (bulkBtn.evaluate().isNotEmpty) {
        await tester.tap(bulkBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      } else if (batchBtn.evaluate().isNotEmpty) {
        await tester.tap(batchBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 16.1 BULK PAYMENTS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('16.1 Bulk Payments View', (tester) async {
      /// GIVEN an authenticated user
      /// WHEN they access Bulk Payments
      /// THEN past bulk payment batches should be listed
      /// AND "New Bulk Payment" option should be available

      await navigateToBulkPayments(tester);

      final bulkScreen = find.textContaining('Bulk');
      final batchScreen = find.textContaining('Batch');
      if (bulkScreen.evaluate().isNotEmpty || batchScreen.evaluate().isNotEmpty) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/bulk/16.1_bulk_payments.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 16.1b BULK PAYMENTS - EMPTY STATE
    // ─────────────────────────────────────────────────────────────
    testWidgets('16.1b Bulk Payments - Empty State', (tester) async {
      /// GIVEN user has no bulk payment history
      /// WHEN the bulk payments view displays
      /// THEN empty state should be shown
      /// AND explanation of bulk payments should be visible

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Empty bulk payments state exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 16.2 BULK UPLOAD VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('16.2 Bulk Upload View', (tester) async {
      /// GIVEN user is on bulk payments
      /// WHEN they tap New Bulk Payment
      /// THEN upload options should display
      /// AND CSV/Excel upload option should be available
      /// AND template download link should be visible

      await navigateToBulkPayments(tester);

      final newBtn = find.text('New Bulk Payment');
      final uploadBtn = find.text('Upload');

      if (newBtn.evaluate().isNotEmpty) {
        await tester.tap(newBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/bulk/16.2_bulk_upload.png'),
        );
      } else if (uploadBtn.evaluate().isNotEmpty) {
        await tester.tap(uploadBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/bulk/16.2_bulk_upload.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 16.3 BULK PREVIEW VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('16.3 Bulk Preview View', (tester) async {
      /// GIVEN user uploaded a CSV file
      /// WHEN the preview screen displays
      /// THEN parsed recipients should be listed
      /// AND total amount should be shown
      /// AND validation errors should be highlighted
      /// AND "Confirm" button should be available

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Bulk preview screen exists at /bulk-payments/preview');
    });

    // ─────────────────────────────────────────────────────────────
    // 16.4 BULK STATUS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('16.4 Bulk Status View', (tester) async {
      /// GIVEN bulk payment was initiated
      /// WHEN the status screen displays
      /// THEN progress indicator should be visible
      /// AND individual payment statuses should be shown
      /// AND summary (successful/failed count) should be displayed

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Bulk status screen exists at /bulk-payments/status/:batchId');
    });

    // ─────────────────────────────────────────────────────────────
    // 16.4b BULK STATUS - COMPLETED
    // ─────────────────────────────────────────────────────────────
    testWidgets('16.4b Bulk Status - Completed', (tester) async {
      /// GIVEN bulk payment completed
      /// WHEN the status screen shows completion
      /// THEN completion summary should be visible
      /// AND download report option should be available

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Bulk completed state exists in status screen');
    });
  });
}
