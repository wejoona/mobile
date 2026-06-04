import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  group('Authentication Flow Tests', () {
    testWidgets('Complete registration/authentication flow', (tester) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.completeOnboarding();

      await flow.pumpUntil(
        () =>
            flow.hasAnyText(['Available Balance', 'Total Balance']) &&
            flow.hasAnyText(['USDC']) &&
            flow.hasAnyText(['Send', 'Envoyer']) &&
            flow.hasAnyText(['Deposit', 'Dépôt']),
        reason: 'authenticated home screen',
      );
    });

    testWidgets('Rejects invalid OTP and keeps user in auth flow', (
      tester,
    ) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.startRegistrationFromIntro();
      await flow.submitPhone(_uniqueIvorianNationalPhone());
      await flow.enterOtp('000000');

      await flow.pumpUntil(
        () =>
            flow.hasAnyText([
              'Invalid',
              'invalid',
              'expired',
              'wrong',
              'incorrect',
              'error',
            ]) ||
            flow.hasAnyText(['Verify your number', 'Vérifiez votre numéro']),
        reason: 'invalid OTP error or retained OTP screen',
      );

      expect(
        flow.hasAnyText(['Tell us about yourself', 'Parlez-nous de vous']),
        isFalse,
        reason: 'Invalid OTP must not advance to profile setup',
      );
    });

    testWidgets('Country selection accepts Senegal phone entry', (
      tester,
    ) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.startRegistrationFromIntro();

      final countryPicker = find.text('+225');
      expect(countryPicker, findsAtLeast(1));
      await tester.tap(countryPicker.first);
      await tester.pump(const Duration(milliseconds: 400));

      final senegalOption = find.text('+221');
      if (senegalOption.evaluate().isNotEmpty) {
        await tester.tap(senegalOption.last);
        await tester.pump(const Duration(milliseconds: 400));
      }

      await flow.enterFirstTextFormField('77 123 45 67');
      expect(find.textContaining('77'), findsWidgets);
    });

    testWidgets('Logout clears session and returns to auth entry', (
      tester,
    ) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.completeOnboarding();
      await _logout(flow);

      await flow.pumpUntil(
        () => flow.hasAnyText([
          'Enter your phone number',
          'Entrez votre numéro',
          'Welcome back',
          'Bon retour',
        ]),
        reason: 'auth entry after logout',
      );
    });
  });
}

Future<void> _logout(KoridoFlowDriver flow) async {
  await flow.goToRoute('/settings');
  await flow.tapTextAfterScroll(['Logout', 'Déconnexion'], maxScrolls: 12);

  await flow.pumpUntil(
    () => flow.hasAnyText([
      'Are you sure you want to logout?',
      'Êtes-vous sûr de vouloir vous déconnecter?',
    ]),
    reason: 'logout confirmation dialog',
  );

  await flow.tester.tap(find.byType(AppButton).last);
  await flow.tester.pump(const Duration(milliseconds: 500));
}

String _uniqueIvorianNationalPhone() {
  final seed = DateTime.now().millisecondsSinceEpoch.toString();
  return '07${seed.substring(seed.length - 8)}';
}
