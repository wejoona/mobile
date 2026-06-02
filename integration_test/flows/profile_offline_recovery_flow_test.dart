import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/mocks/services/user/user_mock.dart';
import 'package:usdc_wallet/services/offline/pending_transfer_queue.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  testWidgets('updates profile details and removes an existing profile photo', (
    tester,
  ) async {
    UserMockState.setAvatar();

    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.goToRoute('/settings/profile/edit');
    await driver.pumpUntil(
      () => find.byType(TextFormField).evaluate().length >= 3,
      reason: 'profile edit fields',
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Josue');
    await tester.enterText(fields.at(1), 'Kouakou');
    await tester.enterText(fields.at(2), 'josue.kouakou@example.com');
    await driver.dismissKeyboard();

    final saveButton = find.byType(AppButton).last;
    await tester.ensureVisible(saveButton);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(saveButton);
    await tester.pump(const Duration(milliseconds: 350));

    await driver.pumpUntil(
      () =>
          driver.hasAnyText([
            'Profile updated successfully',
            'Profil mis à jour avec succès',
          ]) ||
          driver.hasAnyText(['Settings', 'Paramètres']),
      reason: 'profile update confirmation',
    );

    await driver.goToRoute('/settings/profile');
    await driver.pumpUntil(
      () => driver.hasAnyText(['Josue']) && driver.hasAnyText(['Kouakou']),
      reason: 'updated profile details',
    );

    await driver.goToRoute('/settings/profile/edit');
    await driver.pumpUntil(
      () => find.byIcon(Icons.camera_alt).evaluate().isNotEmpty,
      reason: 'profile photo action',
    );

    await tester.tap(find.byIcon(Icons.camera_alt).last);
    await tester.pump(const Duration(milliseconds: 350));
    await driver.pumpUntil(
      () => driver.hasAnyText(['Remove photo', 'Supprimer la photo']),
      reason: 'remove photo action',
    );
    await driver.tapText(['Remove photo', 'Supprimer la photo']);

    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Profile photo removed',
        'Photo de profil supprimée',
      ]),
      reason: 'profile photo removed confirmation',
    );

    await tester.tap(find.byIcon(Icons.camera_alt).last);
    await tester.pump(const Duration(milliseconds: 350));

    expect(driver.hasAnyText(['Remove photo', 'Supprimer la photo']), isFalse);
  });

  testWidgets('reauthorizes and sends a queued offline transfer', (
    tester,
  ) async {
    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await driver.completeOnboarding();

    final prefs = await SharedPreferences.getInstance();
    final queue = PendingTransferQueue(prefs);
    await queue.clearAll();
    await queue.enqueue(
      PendingTransfer(
        id: 'queued-transfer-1',
        recipientPhone: '+2250711223344',
        recipientName: 'Awa Kone',
        amount: 3.25,
        description: 'Market',
        timestamp: DateTime.now(),
        status: TransferStatus.needsAuthorization,
      ),
    );

    await driver.goToRoute('/offline/pending-transfers');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Pending Transfer', 'Transfert en attente']) &&
          driver.hasAnyText(['Awa Kone']) &&
          driver.hasAnyText(['Needs PIN']),
      reason: 'queued transfer needing PIN',
    );

    await driver.tapText(['Confirm & Send', 'Confirmer & Envoyer']);
    await driver.pumpUntil(
      () => driver.hasAnyText(['Confirm Transfer', 'Confirmer le transfert']),
      reason: 'resumed transfer confirmation',
    );

    await driver.tapText(['Confirm & Send', 'Confirmer & Envoyer']);
    await driver.pumpUntil(
      () => driver.hasAnyText(['Verify PIN', 'Vérifier le code PIN']),
      reason: 'PIN verification for queued transfer',
    );

    await driver.enterPinTextFields(KoridoFlowDriver.defaultPin);
    await driver.pumpUntil(
      () => driver.hasAnyText(['Transfer Successful!', 'Transfert réussi!']),
      reason: 'queued transfer success',
    );

    expect(queue.getQueue(), isEmpty);
  });
}
