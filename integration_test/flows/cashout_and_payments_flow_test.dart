import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  testWidgets('completes mobile money withdrawal through API-backed flow', (
    tester,
  ) async {
    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.pushRoute('/withdraw');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Withdrawal Method', 'Méthode de retrait']) &&
          driver.hasAnyText(['Amount to Withdraw', 'Montant à retirer']),
      reason: 'withdraw screen',
    );

    await driver.enterFirstTextFormField('2');
    await driver.tapText(['Mobile Money']);

    await driver.pumpUntil(
      () => driver.hasAnyText(['Mobile Money Number', 'Numéro Mobile Money']),
      reason: 'mobile money phone field',
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.last, '0711223344');
    await driver.dismissKeyboard();

    final submitButton = find.byType(AppButton).last;
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump(const Duration(milliseconds: 350));

    await driver.pumpUntil(
      () => driver.hasAnyText(['Confirmer le retrait', 'Confirm Withdrawal']),
      reason: 'withdraw PIN confirmation sheet',
    );
    await driver.enterPin(KoridoFlowDriver.defaultPin);

    await driver.pumpUntil(
      () =>
          driver.hasAnyText([
            'Demande de retrait soumise avec succès',
            'Withdrawal request submitted successfully',
          ]) ||
          driver.hasAnyText(['Total Balance', 'Solde total']),
      reason: 'withdrawal submitted and returned home',
    );
  });

  testWidgets('pays a utility bill through bill payments API', (tester) async {
    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.goToRoute('/bill-payments');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText([
            'All Providers',
            'Tous les fournisseurs',
            'Bill Payments',
            'Paiement de factures',
          ]) &&
          driver.hasAnyText(['SODECI']),
      reason: 'bill providers list',
    );

    await driver.tapText(['SODECI']);
    await driver.pumpUntil(
      () => driver.hasAnyText(['Pay SODECI', 'Payer SODECI']),
      reason: 'SODECI payment form',
    );

    await driver.enterFirstTextFormField('123456789');
    await driver.tapText(['Verify Account', 'Vérifier le compte']);
    await driver.pumpUntil(
      () =>
          driver.hasAnyText([
            'Account verified successfully',
            'Compte vérifié avec succès',
          ]) ||
          driver.hasAnyText(['John Doe']),
      reason: 'bill account validation',
    );
    await driver.pumpUntil(
      () => find.byType(TextFormField).evaluate().length >= 2,
      reason: 'bill amount field',
    );

    final fields = find.byType(TextFormField);
    await tester.ensureVisible(fields.last);
    await tester.enterText(fields.last, '1000');
    await driver.dismissKeyboard();

    await driver.pumpUntil(
      () => find
          .textContaining('Pay 1100 XOF')
          .hitTestable()
          .evaluate()
          .isNotEmpty,
      reason: 'bill payment button',
    );
    final payButton = find.textContaining('Pay 1100 XOF').hitTestable().first;
    await tester.tap(payButton);
    await tester.pump(const Duration(milliseconds: 350));

    await driver.pumpUntil(
      () => driver.hasAnyText(['Confirm Payment', 'Confirmer le paiement']),
      reason: 'bill payment PIN sheet',
    );
    await driver.enterPin(KoridoFlowDriver.defaultPin);

    await driver.pumpUntil(
      () => driver.hasAnyText(['Payment Successful!', 'Paiement réussi !']),
      reason: 'bill payment success screen',
      timeout: const Duration(seconds: 30),
    );
  });

  testWidgets('completes external wallet transfer with fresh PIN', (
    tester,
  ) async {
    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.goToRoute('/send-external');
    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Send to External Wallet',
        'Send USDC to any wallet address',
        'Transfert externe',
      ]),
      reason: 'external transfer address screen',
    );

    await driver.enterFirstTextFormField(
      '0x1234567890abcdef1234567890abcdef12345678',
    );
    await driver.tapText(['Continue', 'Continuer']);

    await driver.pumpUntil(
      () => driver.hasAnyText(['Enter Amount', 'Entrer le montant']),
      reason: 'external transfer amount screen',
    );
    await driver.enterFirstTextFormField('1');
    await driver.tapText(['Continue', 'Continuer']);

    await driver.pumpUntil(
      () => driver.hasAnyText(['Confirm Transfer', 'Confirmer le transfert']),
      reason: 'external transfer confirmation screen',
    );
    await driver.tapText([
      'Confirm and Send',
      'Confirm & Send',
      'Confirmer et envoyer',
      'Confirmer & Envoyer',
    ]);

    await driver.pumpUntil(
      () => find.byType(TextField).evaluate().isNotEmpty,
      reason: 'external transfer PIN dialog',
    );
    await tester.enterText(
      find.byType(TextField).last,
      KoridoFlowDriver.defaultPin,
    );
    await tester.pump(const Duration(milliseconds: 350));

    await driver.pumpUntil(
      () => driver.hasAnyText(['Transfer Successful', 'Transfert réussi']),
      reason: 'external transfer success screen',
      timeout: const Duration(seconds: 30),
    );
  });
}
