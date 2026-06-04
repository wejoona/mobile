import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  group('Error Scenarios Flow Tests', () {
    testWidgets('Invalid OTP does not advance onboarding', (tester) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.startRegistrationFromIntro();
      await flow.submitPhone(_uniqueIvorianNationalPhone());
      await flow.enterOtp('000000');

      await flow.pumpUntil(
        () =>
            flow.hasAnyText(['Invalid', 'invalid', 'expired', 'incorrect']) ||
            flow.hasAnyText(['Verify your number', 'Vérifiez votre numéro']),
        reason: 'invalid OTP feedback',
      );

      expect(
        flow.hasAnyText(['Tell us about yourself', 'Parlez-nous de vous']),
        isFalse,
      );
    });

    testWidgets('Withdraw requires mobile money number', (tester) async {
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

      final submitButton = find.byType(AppButton).last;
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        flow.hasAnyText(['Mobile Money Number', 'Numéro Mobile Money']),
        isTrue,
      );
      expect(
        flow.hasAnyText(['Confirm Withdrawal', 'Confirmer le retrait']),
        isFalse,
      );
    });

    testWidgets('External transfer rejects invalid wallet address', (
      tester,
    ) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.completeOnboarding();
      await flow.goToRoute('/send-external');

      await flow.pumpUntil(
        () => flow.hasAnyText([
          'Send to External Wallet',
          'Send USDC to any wallet address',
          'Transfert externe',
        ]),
        reason: 'external transfer address screen',
      );

      await flow.enterFirstTextFormField('not-a-wallet');
      await flow.tapText(['Continue', 'Continuer']);
      await tester.pump(const Duration(milliseconds: 750));

      expect(
        flow.hasAnyText(['invalid', 'Invalid', 'wallet address', 'adresse']) ||
            find.byType(TextFormField).evaluate().isNotEmpty,
        isTrue,
        reason: 'Invalid wallet should keep user on address entry',
      );
      expect(flow.hasAnyText(['Enter Amount', 'Entrer le montant']), isFalse);
    });
  });
}

String _uniqueIvorianNationalPhone() {
  final seed = DateTime.now().millisecondsSinceEpoch.toString();
  return '07${seed.substring(seed.length - 8)}';
}
