import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  group('Onboarding Flow Tests', () {
    testWidgets('Intro sequence reaches phone entry', (tester) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.startRegistrationFromIntro();

      await flow.pumpUntil(
        () =>
            flow.hasAnyText([
              'Enter your phone number',
              'Entrez votre numéro',
            ]) &&
            flow.hasAnyText(['Terms of Service', 'Conditions d’utilisation']) &&
            flow.hasAnyText(['Privacy Policy', 'Politique de confidentialité']),
        reason: 'phone entry with legal consent',
      );
    });

    testWidgets('Complete onboarding reaches authenticated home', (
      tester,
    ) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.completeOnboarding();
      await flow.waitForHome();
    });

    testWidgets('Terms consent is required before OTP', (tester) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.startRegistrationFromIntro();
      await flow.enterFirstTextFormField(_uniqueIvorianNationalPhone());
      await flow.tapText(['Continue', 'Continuer']);
      await tester.pump(const Duration(milliseconds: 750));

      expect(
        flow.hasAnyText(['Enter your phone number', 'Entrez votre numéro']),
        isTrue,
        reason: 'User should remain on phone entry without terms consent',
      );
      expect(
        find.byKey(const ValueKey('security_code_input')),
        findsNothing,
        reason: 'OTP input must not be shown without terms consent',
      );
    });

    testWidgets('PIN confirmation mismatch keeps user on PIN setup', (
      tester,
    ) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.startRegistrationFromIntro();
      await flow.submitPhone(_uniqueIvorianNationalPhone());
      await flow.enterOtp('123456');

      await flow.pumpUntil(
        () =>
            flow.hasAnyText(['Tell us about yourself', 'Parlez-nous de vous']),
        reason: 'profile setup screen',
      );
      await flow.submitProfile();

      await flow.pumpUntil(
        () => flow.hasAnyText(['Create your PIN', 'Créez votre PIN']),
        reason: 'PIN setup screen',
      );
      await flow.enterPin(KoridoFlowDriver.defaultPin);

      await flow.pumpUntil(
        () => flow.hasAnyText(['Confirm your PIN', 'Confirmez votre PIN']),
        reason: 'PIN confirmation screen',
      );
      await flow.enterPin('739252');
      await tester.pump(const Duration(milliseconds: 750));

      expect(
        flow.hasAnyText([
              'match',
              'correspond',
              'Confirm your PIN',
              'Confirmez votre PIN',
            ]) ||
            find.byKey(const ValueKey('pin_digit_0')).evaluate().isNotEmpty,
        isTrue,
        reason: 'Mismatched PIN confirmation must not complete onboarding',
      );
    });
  });
}

String _uniqueIvorianNationalPhone() {
  final seed = DateTime.now().millisecondsSinceEpoch.toString();
  return '07${seed.substring(seed.length - 8)}';
}
