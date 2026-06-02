import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  testWidgets('shows receive QR and optional requested amount', (tester) async {
    final driver = KoridoFlowDriver(tester);

    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.pushRoute('/receive');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Receive Payment']) &&
          find.byType(QrImageView).evaluate().isNotEmpty,
      reason: 'receive QR screen',
    );

    expect(find.text('Korido'), findsWidgets);
    expect(driver.hasAnyText(['Awa Kone']), isTrue);
    expect(driver.hasAnyText(['Request specific amount']), isTrue);
    expect(driver.hasAnyText(['Share']), isTrue);
    expect(driver.hasAnyText(['Save']), isTrue);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump(const Duration(milliseconds: 250));
    await driver.enterFirstTextFormField('12.50');

    await driver.pumpUntil(
      () => driver.hasAnyText([r'$12.50 USD']),
      reason: 'requested amount shown on QR card',
    );

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pump(const Duration(milliseconds: 350));
    await driver.waitForHome();
  });
}
