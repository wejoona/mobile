import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';
import '../helpers/test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  testWidgets('completes internal transfer from home', (tester) async {
    final flow = KoridoFlowDriver(tester);

    try {
      await flow.launchApp();
      await flow.completeOnboarding();
      await flow.exerciseTransferFromHome();
    } catch (_) {
      await TestHelpers.takeScreenshot(binding, 'send_money_flow_error');
      rethrow;
    }
  });

  testWidgets('continues from contacts and beneficiaries pickers', (
    tester,
  ) async {
    final flow = KoridoFlowDriver(tester);

    try {
      await flow.launchApp();
      await flow.completeOnboarding();

      await flow.tapText(['Send', 'Envoyer']);
      await flow.pumpUntil(
        () => flow.hasAnyText([
          'Select Recipient',
          'Sélectionner le destinataire',
        ]),
        reason: 'send recipient screen',
      );

      await flow.tapText(['Contacts']);
      await flow.pumpUntil(
        () => find
            .byKey(const ValueKey('contact_picker_ct_001'))
            .evaluate()
            .isNotEmpty,
        reason: 'mock contact picker loaded',
      );
      await _tapPickerItem(tester, const ValueKey('contact_picker_ct_001'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller
            ?.text,
        '0708091011',
      );

      await flow.tapText(['Continue', 'Continuer']);
      await flow.pumpUntil(
        () => flow.hasAnyText(['Enter Amount', 'Entrer le montant']),
        reason: 'amount from contact',
      );

      await tester.pageBack();
      await tester.pump(const Duration(milliseconds: 500));
      await flow.pumpUntil(
        () => flow.hasAnyText([
          'Select Recipient',
          'Sélectionner le destinataire',
        ]),
        reason: 'send recipient screen after returning from amount',
      );

      await flow.tapText(['Beneficiaries']);
      await flow.pumpUntil(
        () => find
            .byKey(const ValueKey('beneficiary_picker_ben-2'))
            .evaluate()
            .isNotEmpty,
        reason: 'mock beneficiary picker loaded',
      );
      await _tapPickerItem(tester, const ValueKey('beneficiary_picker_ben-2'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller
            ?.text,
        '0587654321',
      );

      await flow.tapText(['Continue', 'Continuer']);
      await flow.pumpUntil(
        () => flow.hasAnyText(['Enter Amount', 'Entrer le montant']),
        reason: 'amount from beneficiary',
      );
    } catch (_) {
      await TestHelpers.takeScreenshot(binding, 'send_picker_flow_error');
      rethrow;
    }
  });
}

Future<void> _tapPickerItem(WidgetTester tester, Key key) async {
  final row = find.byKey(key);
  await tester.ensureVisible(row);
  await tester.pump(const Duration(milliseconds: 250));
  await tester.tap(row);
}
