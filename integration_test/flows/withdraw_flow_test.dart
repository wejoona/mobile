import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  group('Withdraw Flow Tests', () {
    testWidgets('Withdraw screen renders methods and amount entry', (
      tester,
    ) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.completeOnboarding();
      await flow.pushRoute('/withdraw');

      await flow.pumpUntil(
        () =>
            flow.hasAnyText(['Withdrawal Method', 'Méthode de retrait']) &&
            flow.hasAnyText(['Amount to Withdraw', 'Montant à retirer']) &&
            flow.hasAnyText(['Mobile Money']),
        reason: 'withdraw method and amount screen',
      );
    });

    testWidgets('Complete withdraw to mobile money', (tester) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.completeOnboarding();
      await flow.pushRoute('/withdraw');

      await flow.pumpUntil(
        () =>
            flow.hasAnyText(['Withdrawal Method', 'Méthode de retrait']) &&
            flow.hasAnyText(['Amount to Withdraw', 'Montant à retirer']),
        reason: 'withdraw screen',
      );

      await flow.enterFirstTextFormField('2');
      await flow.tapText(['Mobile Money']);

      await flow.pumpUntil(
        () => flow.hasAnyText(['Mobile Money Number', 'Numéro Mobile Money']),
        reason: 'mobile money phone field',
      );
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.last, '0711223344');
      await flow.dismissKeyboard();

      final submitButton = find.byType(AppButton).last;
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pump(const Duration(milliseconds: 350));

      await flow.pumpUntil(
        () => flow.hasAnyText(['Confirmer le retrait', 'Confirm Withdrawal']),
        reason: 'withdraw PIN confirmation sheet',
      );
      await flow.enterPin(KoridoFlowDriver.defaultPin);

      await flow.pumpUntil(
        () =>
            flow.hasAnyText([
              'Demande de retrait soumise avec succès',
              'Withdrawal request submitted successfully',
            ]) ||
            flow.hasAnyText(['Total Balance', 'Solde total']),
        reason: 'withdrawal submitted and returned home',
      );
    });
  });
}
