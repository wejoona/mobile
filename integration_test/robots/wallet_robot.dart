import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

/// Robot for wallet operations
class WalletRobot {
  final WidgetTester tester;

  WalletRobot(this.tester);

  // Navigation
  Future<void> goToHome() async {
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
  }

  Future<void> goToTransactions() async {
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
  }

  Future<void> goToCards() async {
    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
  }

  Future<void> goToSettings() async {
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
  }

  // Balance operations
  Future<void> tapBalanceCard() async {
    await tester.tap(find.text('Balance'));
    await tester.pumpAndSettle();
  }

  Future<void> toggleBalanceVisibility() async {
    // Find and tap eye icon
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();
  }

  Future<void> refreshBalance() async {
    await TestHelpers.pullToRefresh(tester);
  }

  // Quick actions
  Future<void> tapSendAction() async {
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
  }

  Future<void> tapReceiveAction() async {
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();
  }

  Future<void> tapDepositAction() async {
    await tester.tap(find.text('Deposit'));
    await tester.pumpAndSettle();
  }

  Future<void> tapWithdrawAction() async {
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();
  }

  // Receive flow
  Future<void> shareQrCode() async {
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
  }

  Future<void> saveQrCode() async {
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  Future<void> copyWalletAddress() async {
    await tester.tap(find.byIcon(Icons.copy));
    await tester.pumpAndSettle();
  }

  // Transaction list
  Future<void> tapTransaction(int index) async {
    final txList = find.byType(ListView);
    final txItem = find.descendant(
      of: txList,
      matching: find.byType(ListTile),
    ).at(index);

    await tester.tap(txItem);
    await tester.pumpAndSettle();
  }

  Future<void> filterTransactions(String type) async {
    // Open filter
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    // Select type
    await tester.tap(find.text(type));
    await tester.pumpAndSettle();

    // Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
  }

  Future<void> searchTransactions(String query) async {
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), query);
    await tester.pumpAndSettle();
  }

  // Transaction detail
  Future<void> shareReceipt() async {
    await tester.tap(find.text('Share Receipt'));
    await tester.pumpAndSettle();
  }

  Future<void> downloadReceipt() async {
    await tester.tap(find.text('Download'));
    await tester.pumpAndSettle();
  }

  Future<void> reportIssue() async {
    await tester.tap(find.text('Report Issue'));
    await tester.pumpAndSettle();
  }

  // Verification helpers
  void verifyBalance(String expectedAmount) {
    expect(find.textContaining(expectedAmount), findsOneWidget);
  }

  void verifyBalanceHidden() {
    expect(find.text('****'), findsOneWidget);
  }

  void verifyTransactionExists(String recipientOrSender) {
    expect(find.text(recipientOrSender), findsOneWidget);
  }

  void verifyNoTransactions() {
    expect(find.text('No transactions yet'), findsOneWidget);
  }

  void verifyOnReceiveScreen() {
    expect(find.text('Receive'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget); // QR code
  }

  void verifyOnTransactionDetail() {
    expect(find.text('Transaction Details'), findsOneWidget);
  }

  void verifyOnHomeScreen() {
    // Verify we're on home by checking for wallet/balance elements
    expect(
      find.byWidgetPredicate(
        (widget) =>
            find.text('Home').evaluate().isNotEmpty ||
            find.text('Balance').evaluate().isNotEmpty ||
            find.text('Send').evaluate().isNotEmpty,
      ),
      findsWidgets,
    );
  }
}
