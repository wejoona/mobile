import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/mocks/services/kyc/kyc_mock.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await KoridoFlowDriver.resetMocksAndStorage();
    KycMockState.reset();
  });

  group('KYC Flow Tests', () {
    testWidgets('KYC status screen shows startable verification state', (
      tester,
    ) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.completeOnboarding();
      KycMockState.reset();
      await flow.goToRoute('/kyc');

      await flow.pumpUntil(
        () =>
            flow.hasAnyText(['Identity Verification', 'Vérification']) &&
            flow.hasAnyText(['Start Verification', 'Commencer']),
        reason: 'startable KYC status screen',
      );
    });

    testWidgets('Document type screen lists and selects ID options', (
      tester,
    ) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.completeOnboarding();
      await flow.goToRoute('/kyc/document-type');

      await flow.pumpUntil(
        () =>
            flow.hasAnyText(['Select Document Type', 'Type de document']) &&
            flow.hasAnyText(['National ID', 'Carte nationale']) &&
            flow.hasAnyText(['Passport', 'Passeport']) &&
            flow.hasAnyText(["Driver's License", 'Permis']),
        reason: 'document type options',
      );

      await flow.tapText(['National ID', 'Carte nationale']);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(flow.hasAnyText(['Continue', 'Continuer']), isTrue);
    });

    testWidgets('Personal information screen renders required KYC fields', (
      tester,
    ) async {
      final flow = KoridoFlowDriver(tester);

      await flow.launchApp();
      await flow.completeOnboarding();
      await flow.goToRoute('/kyc/personal-info');

      await flow.pumpUntil(
        () =>
            flow.hasAnyText(['Personal Information', 'Informations']) &&
            flow.hasAnyText(['First name', 'Prénom']) &&
            flow.hasAnyText(['Last name', 'Nom']) &&
            flow.hasAnyText(['Date of birth', 'Date de naissance']) &&
            flow.hasAnyText(['Document number']),
        reason: 'KYC personal information form',
      );
    });
  });
}
