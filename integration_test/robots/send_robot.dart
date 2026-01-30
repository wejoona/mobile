import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';

/// Robot for send money flow
class SendRobot {
  final WidgetTester tester;

  SendRobot(this.tester);

  // Recipient selection
  Future<void> enterPhoneNumber(String phone) async {
    await tester.enterText(find.byType(TextField).first, phone);
    await tester.pumpAndSettle();
  }

  Future<void> selectRecentRecipient(String name) async {
    await TestHelpers.scrollUntilVisible(tester, find.text(name));
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> selectBeneficiary(String name) async {
    // Open beneficiaries
    await tester.tap(find.text('Beneficiaries'));
    await tester.pumpAndSettle();

    // Select beneficiary
    await TestHelpers.scrollUntilVisible(tester, find.text(name));
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> selectFromContacts() async {
    await tester.tap(find.text('Contacts'));
    await tester.pumpAndSettle();

    // Wait for permission dialog (might appear)
    await tester.pump(const Duration(seconds: 1));

    // Select first contact
    final contactList = find.byType(ListView);
    if (contactList.evaluate().isNotEmpty) {
      final firstContact = find.descendant(
        of: contactList,
        matching: find.byType(ListTile),
      ).first;
      await tester.tap(firstContact);
      await tester.pumpAndSettle();
    }
  }

  Future<void> tapContinueFromRecipient() async {
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  // Amount entry
  Future<void> enterAmount(double amount) async {
    final amountStr = amount.toStringAsFixed(0);

    // Tap on amount digits one by one
    for (int i = 0; i < amountStr.length; i++) {
      final digit = amountStr[i];
      await tester.tap(find.text(digit).last);
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pumpAndSettle();
  }

  Future<void> clearAmount() async {
    // Tap backspace multiple times
    final backspace = find.byIcon(Icons.backspace);
    if (backspace.evaluate().isNotEmpty) {
      for (int i = 0; i < 10; i++) {
        await tester.tap(backspace);
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    await tester.pumpAndSettle();
  }

  Future<void> addNote(String note) async {
    await tester.tap(find.text('Add note'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), note);
    await tester.pumpAndSettle();
  }

  Future<void> tapContinueFromAmount() async {
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  // Confirmation
  Future<void> verifyRecipient(String name) {
    expect(find.text(name), findsOneWidget);
  }

  Future<void> verifyAmount(double amount) {
    final amountStr = amount.toStringAsFixed(0);
    expect(find.textContaining(amountStr), findsOneWidget);
  }

  Future<void> tapConfirm() async {
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
  }

  Future<void> tapCancel() async {
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  }

  // PIN verification
  Future<void> enterPin(String pin) async {
    await TestHelpers.enterPin(tester, pin);
  }

  // Result screen
  Future<void> tapDone() async {
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
  }

  Future<void> tapShareReceipt() async {
    await tester.tap(find.text('Share Receipt'));
    await tester.pumpAndSettle();
  }

  Future<void> tapViewReceipt() async {
    await tester.tap(find.text('View Receipt'));
    await tester.pumpAndSettle();
  }

  Future<void> tapSendAgain() async {
    await tester.tap(find.text('Send Again'));
    await tester.pumpAndSettle();
  }

  // Complete send flow
  Future<void> completeSendFlow({
    String? recipient,
    double? amount,
    String? note,
    String? pin,
  }) async {
    // Enter recipient
    await enterPhoneNumber(recipient ?? TestData.testBeneficiaries[0]['phone'] as String);
    await tapContinueFromRecipient();

    // Enter amount
    await enterAmount(amount ?? TestData.smallAmount);

    if (note != null) {
      await addNote(note);
    }

    await tapContinueFromAmount();

    // Confirm
    await tapConfirm();

    // Enter PIN
    await TestHelpers.waitForWidget(tester, find.text('Enter PIN'));
    await enterPin(pin ?? TestData.testPin);

    // Wait for result
    await TestHelpers.waitForLoadingToComplete(tester);
  }

  // Verification helpers
  void verifyOnRecipientScreen() {
    expect(find.text('Send to'), findsOneWidget);
  }

  void verifyOnAmountScreen() {
    expect(find.text('Enter amount'), findsOneWidget);
  }

  void verifyOnConfirmScreen() {
    expect(find.text('Confirm Transfer'), findsOneWidget);
  }

  void verifyOnPinScreen() {
    expect(find.text('Enter PIN'), findsOneWidget);
  }

  void verifySuccess() {
    expect(find.text('Transfer Successful'), findsOneWidget);
  }

  void verifyFailure() {
    expect(find.text('Transfer Failed'), findsOneWidget);
  }

  void verifyInsufficientBalance() {
    expect(find.text('Insufficient balance'), findsOneWidget);
  }
}
