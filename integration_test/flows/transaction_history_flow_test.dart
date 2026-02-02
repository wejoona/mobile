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

  group('Transaction History Flow Tests', () {
    late AuthRobot authRobot;
    late WalletRobot walletRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginAndNavigateToTransactions(WidgetTester tester) async {
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

      // Navigate to transactions
      await walletRobot.goToTransactions();
    }

    testWidgets('View transaction history list', (tester) async {
      try {
        await loginAndNavigateToTransactions(tester);

        // Verify on transactions screen
        expect(find.text('Transactions'), findsWidgets);

        // Should show transaction list or empty state
        final hasTx = find.byType(ListView).evaluate().isNotEmpty;
        final isEmpty = find.text('No transactions yet').evaluate().isNotEmpty;
        expect(hasTx || isEmpty, isTrue);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'tx_history_error');
        rethrow;
      }
    });

    testWidgets('Filter transactions by type', (tester) async {
      try {
        await loginAndNavigateToTransactions(tester);

        // Open filter
        final filterButton = find.byIcon(Icons.filter_list);
        if (filterButton.evaluate().isNotEmpty) {
          await tester.tap(filterButton);
          await tester.pumpAndSettle();

          // Select Send type
          await tester.tap(find.text('Send'));
          await tester.pumpAndSettle();

          // Apply
          await tester.tap(find.text('Apply'));
          await tester.pumpAndSettle();

          // Verify filter applied
          expect(find.text('Send'), findsWidgets);
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'tx_filter_error');
        rethrow;
      }
    });

    testWidgets('Search transactions', (tester) async {
      try {
        await loginAndNavigateToTransactions(tester);

        // Tap search
        final searchButton = find.byIcon(Icons.search);
        if (searchButton.evaluate().isNotEmpty) {
          await tester.tap(searchButton);
          await tester.pumpAndSettle();

          // Enter search query
          await tester.enterText(find.byType(TextField).first, 'Fatou');
          await tester.pumpAndSettle();

          // Wait for results
          await tester.pump(const Duration(seconds: 1));
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'tx_search_error');
        rethrow;
      }
    });

    testWidgets('View transaction detail', (tester) async {
      try {
        await loginAndNavigateToTransactions(tester);

        // Find and tap a transaction
        final txList = find.byType(ListView);
        if (txList.evaluate().isNotEmpty) {
          final txItem = find.byType(ListTile).first;
          if (txItem.evaluate().isNotEmpty) {
            await tester.tap(txItem);
            await tester.pumpAndSettle();

            // Verify on detail screen
            expect(find.text('Transaction Details'), findsOneWidget);
          }
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'tx_detail_error');
        rethrow;
      }
    });

    testWidgets('Share transaction receipt', (tester) async {
      try {
        await loginAndNavigateToTransactions(tester);

        // Find and tap a transaction
        final txItem = find.byType(ListTile).first;
        if (txItem.evaluate().isNotEmpty) {
          await tester.tap(txItem);
          await tester.pumpAndSettle();

          // Tap share
          final shareButton = find.text('Share Receipt');
          if (shareButton.evaluate().isNotEmpty) {
            await tester.tap(shareButton);
            await tester.pumpAndSettle();
          }
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'tx_share_error');
        rethrow;
      }
    });

    testWidgets('Pull to refresh transactions', (tester) async {
      try {
        await loginAndNavigateToTransactions(tester);

        // Pull to refresh
        await TestHelpers.pullToRefresh(tester);

        // Wait for refresh to complete
        await TestHelpers.waitForLoadingToComplete(tester);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'tx_refresh_error');
        rethrow;
      }
    });

    testWidgets('Export transactions', (tester) async {
      try {
        await loginAndNavigateToTransactions(tester);

        // Find export option
        final menuButton = find.byIcon(Icons.more_vert);
        if (menuButton.evaluate().isNotEmpty) {
          await tester.tap(menuButton);
          await tester.pumpAndSettle();

          // Tap export
          final exportButton = find.text('Export');
          if (exportButton.evaluate().isNotEmpty) {
            await tester.tap(exportButton);
            await tester.pumpAndSettle();

            // Select format
            await tester.tap(find.text('CSV'));
            await tester.pumpAndSettle();
          }
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'tx_export_error');
        rethrow;
      }
    });

    testWidgets('Filter by date range', (tester) async {
      try {
        await loginAndNavigateToTransactions(tester);

        // Open filter
        final filterButton = find.byIcon(Icons.filter_list);
        if (filterButton.evaluate().isNotEmpty) {
          await tester.tap(filterButton);
          await tester.pumpAndSettle();

          // Select date filter
          await tester.tap(find.text('This Month'));
          await tester.pumpAndSettle();

          // Apply
          await tester.tap(find.text('Apply'));
          await tester.pumpAndSettle();
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'tx_date_filter_error');
        rethrow;
      }
    });
  });
}
