import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  testWidgets('settings surfaces profile, security, devices, and sessions', (
    tester,
  ) async {
    final driver = KoridoFlowDriver(tester);

    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.goToRoute('/settings');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Settings', 'Paramètres']) &&
          driver.hasAnyText(['Awa Kone']) &&
          driver.hasAnyText(['Devices', 'Appareils']) &&
          driver.hasAnyText(['Active Sessions', 'Sessions actives']),
      reason: 'settings overview with profile and account controls',
    );

    await driver.goToRoute('/settings/profile');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Profile', 'Profil']) &&
          driver.hasAnyText(['Awa']) &&
          driver.hasAnyText(['Kone']) &&
          driver.hasAnyText(['awa.kone@example.com']),
      reason: 'profile details screen',
    );

    await driver.goToRoute('/settings/security');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Security', 'Sécurité']) &&
          driver.hasAnyText(['Security Score', 'Score de sécurité']) &&
          driver.hasAnyText(['Change PIN', 'Changer le code PIN']) &&
          driver.hasAnyText(['Devices', 'Appareils']) &&
          driver.hasAnyText(['Active Sessions', 'Sessions actives']),
      reason: 'security settings screen',
    );

    await driver.goToRoute('/settings/devices');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Devices', 'Appareils']) &&
          driver.hasAnyText(['THIS DEVICE', 'CET APPAREIL']) &&
          driver.hasAnyText(['OTHER DEVICES', 'AUTRES APPAREILS']) &&
          driver.hasAnyText(['iPhone 15 Pro', 'MacBook Pro', 'Galaxy S23']),
      reason: 'registered devices loaded from the mock API',
    );

    await driver.goToRoute('/settings/sessions');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Active Sessions', 'Sessions actives']) &&
          driver.hasAnyText(['Current session', 'Session actuelle']) &&
          driver.hasAnyText(['iPhone']) &&
          driver.hasAnyText(['Abidjan']),
      reason: 'active sessions loaded from the mock API',
    );

    await driver.goToRoute('/settings/notifications');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Notifications']) &&
          driver.hasAnyText(['Push Notifications', 'Notifications push']) &&
          driver.hasAnyText([
            'Email Notifications',
            'Notifications par email',
          ]) &&
          driver.hasAnyText(['SMS Notifications', 'Notifications SMS']),
      reason: 'notification preferences screen',
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pump(const Duration(milliseconds: 250));
    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Save Preferences',
        'Enregistrer les préférences',
      ]),
      reason: 'notification preference dirty state',
    );

    await driver.goToRoute('/settings/help');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText([
            'Search help articles',
            'Rechercher des articles',
          ]) &&
          driver.hasAnyText([
            'Frequently Asked Questions',
            'Questions fréquentes',
          ]) &&
          driver.hasAnyText(['Transferts']),
      reason: 'help center screen',
    );

    final searchField = find.byType(TextFormField).evaluate().isNotEmpty
        ? find.byType(TextFormField).first
        : find.byType(TextField).first;
    await tester.enterText(searchField, 'transfert');
    await driver.dismissKeyboard();

    await driver.pumpUntil(
      () => driver.hasAnyText(['Transferts']),
      reason: 'filtered help article results',
    );
  });
}
