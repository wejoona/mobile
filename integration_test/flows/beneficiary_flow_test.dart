import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await KoridoFlowDriver.resetMocksAndStorage();
  });

  testWidgets('contacts and beneficiaries identify Korido users', (
    tester,
  ) async {
    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.goToRoute('/contacts');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Contacts']) &&
          driver.hasAnyText(['On Korido']) &&
          driver.hasAnyText(['Invite to Korido']),
      reason: 'contacts grouped by Korido membership',
      timeout: const Duration(seconds: 8),
    );

    expect(find.text('Found 3 Korido users!'), findsOneWidget);
    expect(find.text('Amadou Diallo'), findsOneWidget);
    expect(find.text('Fatou Koné'), findsOneWidget);
    expect(find.text('Mariam Bamba'), findsOneWidget);
    expect(find.text('Korido'), findsAtLeastNWidgets(3));
    expect(find.text('Send'), findsAtLeastNWidgets(3));
    expect(find.text('Invite'), findsAtLeastNWidgets(2));

    await tester.tap(find.text('Send').first);
    await tester.pump(const Duration(milliseconds: 500));
    await driver.pumpUntil(
      () => driver.hasAnyText(['Select Recipient']),
      reason: 'send screen from Korido contact',
    );
    final recipientField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(recipientField.controller?.text, '0708091011');

    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 350));

    await driver.enterFirstTextFormField('Ibrahim');
    await driver.pumpUntil(
      () =>
          find.text('Ibrahim Touré').evaluate().isNotEmpty &&
          find.text('Invite').evaluate().isNotEmpty,
      reason: 'filtered non-Korido contact',
    );

    await tester.tap(find.text('Invite').first);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Invite Ibrahim Touré to Korido'), findsOneWidget);
    expect(find.text('Send SMS Invite'), findsOneWidget);
    expect(find.text('Invite via WhatsApp'), findsOneWidget);
    expect(find.text('Copy Invite Link'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 350));

    await driver.goToRoute('/beneficiaries');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Beneficiaries']) &&
          driver.hasAnyText(['Amadou Diallo']) &&
          driver.hasAnyText(['Korido User']),
      reason: 'beneficiaries list with Korido account markers',
    );

    expect(find.text('Korido'), findsAtLeastNWidgets(3));
    await _expectListText(tester, 'Mobile Money');
    await _expectListText(tester, 'Bank Account');
    await _expectListText(tester, 'External Wallet');

    await driver.enterFirstTextFormField('Fatou');
    await driver.pumpUntil(
      () =>
          find.textContaining('Fatou').evaluate().isNotEmpty &&
          find.text('Korido User').evaluate().isNotEmpty,
      reason: 'beneficiary search result with Korido marker',
    );
  });
}

Future<void> _expectListText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).last,
    );
  }
  expect(finder, findsOneWidget);
}
