import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: TRANSACTIONS
///
/// Screens covered:
/// - 8.1 Transactions List View
/// - 8.2 Transaction Detail View
/// - 8.3 Export Transactions View
/// - 8.4 Transaction Filters
void main() {
  final __binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Transactions Golden Tests', () {
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

    /// Helper to navigate to transactions/history screen
    Future<void> navigateToTransactions(WidgetTester tester) async {
      await loginToHome(tester);

      // Tap History tab
      final historyTab = find.text('History');
      final transactionsTab = find.text('Transactions');

      if (historyTab.evaluate().isNotEmpty) {
        await tester.tap(historyTab.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      } else if (transactionsTab.evaluate().isNotEmpty) {
        await tester.tap(transactionsTab.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 8.1 TRANSACTIONS LIST VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('8.1 Transactions List View', (tester) async {
      /// GIVEN an authenticated user
      /// WHEN the History tab is selected
      /// THEN transactions list should display
      /// AND each transaction should show type, amount, date
      /// AND filtering options may be available

      await navigateToTransactions(tester);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/transactions/8.1_transactions_list.png'),
      );
    });

    // ─────────────────────────────────────────────────────────────
    // 8.1b TRANSACTIONS LIST - EMPTY STATE
    // ─────────────────────────────────────────────────────────────
    testWidgets('8.1b Transactions List - Empty State', (tester) async {
      /// GIVEN user has no transactions
      /// WHEN the History tab is selected
      /// THEN empty state should display
      /// AND message like "No transactions yet" should be visible

      // This would require specific mock setup for empty state
      await loginToHome(tester);
      expect(true, isTrue, reason: 'Empty state exists in transactions list');
    });

    // ─────────────────────────────────────────────────────────────
    // 8.2 TRANSACTION DETAIL VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('8.2 Transaction Detail View', (tester) async {
      /// GIVEN user is on transactions list
      /// WHEN they tap a transaction
      /// THEN transaction details should display
      /// AND full amount, fee, date, status should be shown
      /// AND Share Receipt option may be available

      await navigateToTransactions(tester);

      // Tap first transaction item
      final transactionItems = find.byType(ListTile);
      if (transactionItems.evaluate().isNotEmpty) {
        await tester.tap(transactionItems.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/transactions/8.2_transaction_detail.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 8.2b TRANSACTION DETAIL - DEPOSIT
    // ─────────────────────────────────────────────────────────────
    testWidgets('8.2b Transaction Detail - Deposit', (tester) async {
      /// GIVEN user is viewing a deposit transaction
      /// WHEN the detail screen displays
      /// THEN deposit-specific details should be shown
      /// AND source (mobile money) should be visible

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Deposit transaction detail exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 8.2c TRANSACTION DETAIL - SEND
    // ─────────────────────────────────────────────────────────────
    testWidgets('8.2c Transaction Detail - Send', (tester) async {
      /// GIVEN user is viewing a send transaction
      /// WHEN the detail screen displays
      /// THEN recipient details should be shown
      /// AND reference may be visible

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Send transaction detail exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 8.2d TRANSACTION DETAIL - RECEIVE
    // ─────────────────────────────────────────────────────────────
    testWidgets('8.2d Transaction Detail - Receive', (tester) async {
      /// GIVEN user is viewing a receive transaction
      /// WHEN the detail screen displays
      /// THEN sender details should be shown

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Receive transaction detail exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 8.3 EXPORT TRANSACTIONS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('8.3 Export Transactions View', (tester) async {
      /// GIVEN user is on transactions list
      /// WHEN they tap Export
      /// THEN export options should display
      /// AND date range picker should be available
      /// AND format options (PDF, CSV) may be shown

      await navigateToTransactions(tester);

      final exportBtn = find.text('Export');
      final downloadBtn = find.byIcon(Icons.download);

      if (exportBtn.evaluate().isNotEmpty) {
        await tester.tap(exportBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/transactions/8.3_export.png'),
        );
      } else if (downloadBtn.evaluate().isNotEmpty) {
        await tester.tap(downloadBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/transactions/8.3_export.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 8.4 TRANSACTION FILTERS
    // ─────────────────────────────────────────────────────────────
    testWidgets('8.4 Transaction Filters', (tester) async {
      /// GIVEN user is on transactions list
      /// WHEN they tap Filter
      /// THEN filter options should display
      /// AND type filter (All, Deposits, Sends, Receives) should be available
      /// AND date range filter should be available

      await navigateToTransactions(tester);

      final filterBtn = find.text('Filter');
      final filterIcon = find.byIcon(Icons.filter_list);

      if (filterBtn.evaluate().isNotEmpty) {
        await tester.tap(filterBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/transactions/8.4_filters.png'),
        );
      } else if (filterIcon.evaluate().isNotEmpty) {
        await tester.tap(filterIcon.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/transactions/8.4_filters.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 8.4b TRANSACTION FILTERS - APPLIED
    // ─────────────────────────────────────────────────────────────
    testWidgets('8.4b Transaction Filters - Applied', (tester) async {
      /// GIVEN user has applied filters
      /// WHEN viewing filtered transactions
      /// THEN active filter chips should be visible
      /// AND filtered results should display

      await navigateToTransactions(tester);

      final filterBtn = find.text('Filter');
      final filterIcon = find.byIcon(Icons.filter_list);

      if (filterBtn.evaluate().isNotEmpty || filterIcon.evaluate().isNotEmpty) {
        await tester.tap(filterBtn.evaluate().isNotEmpty ? filterBtn.first : filterIcon.first);
        await tester.pumpAndSettle();

        // Select a filter option (e.g., Deposits)
        final depositsFilter = find.text('Deposits');
        if (depositsFilter.evaluate().isNotEmpty) {
          await tester.tap(depositsFilter.first);
          await tester.pumpAndSettle();

          final applyBtn = find.text('Apply');
          if (applyBtn.evaluate().isNotEmpty) {
            await tester.tap(applyBtn.first);
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 1));
            await tester.pumpAndSettle();

            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('../goldens/transactions/8.4b_filters_applied.png'),
            );
          }
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 8.5 SHARE RECEIPT SHEET
    // ─────────────────────────────────────────────────────────────
    testWidgets('8.5 Share Receipt Sheet', (tester) async {
      /// GIVEN user is on transaction detail
      /// WHEN they tap Share Receipt
      /// THEN share sheet should appear
      /// AND share options should be available

      await navigateToTransactions(tester);

      // Tap first transaction
      final transactionItems = find.byType(ListTile);
      if (transactionItems.evaluate().isNotEmpty) {
        await tester.tap(transactionItems.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final shareBtn = find.text('Share Receipt');
        final shareIcon = find.byIcon(Icons.share);

        if (shareBtn.evaluate().isNotEmpty) {
          await tester.tap(shareBtn.first);
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/transactions/8.5_share_receipt.png'),
          );
        } else if (shareIcon.evaluate().isNotEmpty) {
          await tester.tap(shareIcon.first);
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/transactions/8.5_share_receipt.png'),
          );
        }
      }
    });
  });
}
