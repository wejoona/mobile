import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  testWidgets('shows transaction history after transfer and applies filter', (
    tester,
  ) async {
    final driver = KoridoFlowDriver(tester);

    await driver.launchApp();
    await driver.completeOnboarding();
    await driver.exerciseTransferFromHome();

    await driver.goToRoute('/transactions');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Transactions']) &&
          driver.hasAnyText(['Transfer Sent', 'Transfert envoyé']) &&
          driver.hasAnyText(['-1.00 USDC', r'- $1.00']),
      reason: 'transactions list with the completed transfer amount',
    );

    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.enterText(find.byType(TextFormField).first, 'transfer');
    await driver.dismissKeyboard();

    await driver.pumpUntil(
      () => driver.hasAnyText(['Transfer Sent', 'Transfert envoyé']),
      reason: 'transactions remain visible after search input',
    );

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byIcon(Icons.filter_list).first);
    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Filter Transactions',
        'Filtrer les transactions',
      ]),
      reason: 'transaction filter sheet',
    );

    await tester.tap(find.text('Sent').last);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.textContaining('Apply Filters').last);
    await tester.pump(const Duration(milliseconds: 500));

    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Sent', 'Envoyés']) &&
          driver.hasAnyText(['Transfer Sent', 'Transfert envoyé']),
      reason: 'sent transaction filter applied',
    );
  });
}
