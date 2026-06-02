import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  testWidgets('creates a payment link and opens its details', (tester) async {
    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.goToRoute('/payment-links');
    await driver.pumpUntil(
      () => driver.hasAnyText(['Payment Links', 'Liens de Paiement']),
      reason: 'payment links list',
    );

    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pump(const Duration(milliseconds: 350));
    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Create Payment Link',
        'Créer un Lien de Paiement',
      ]),
      reason: 'payment link creation screen',
    );

    await driver.enterFirstTextFormField('1200');
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'Simulator payment link');
    await driver.dismissKeyboard();

    await driver.tapText(['Create Payment Link', 'Créer un Lien de Paiement']);
    await driver.pumpUntil(
      () => driver.hasAnyText(['Link Created', 'Lien Créé']),
      reason: 'payment link created screen',
      timeout: const Duration(seconds: 30),
    );
    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Your payment link is ready!',
        'Votre lien de paiement est prêt!',
        'Share Link',
        'Partager le lien',
      ]),
      reason: 'payment link created content',
    );

    await driver.tapTextAfterScroll(['View Details', 'Voir les Détails']);
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Link Details', 'Détails du Lien']) &&
          driver.hasAnyText(['Simulator payment link']),
      reason: 'payment link detail screen',
    );
  });

  testWidgets('opens a savings pot and adds money to it', (tester) async {
    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.goToRoute('/savings-pots');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(["Pots d'épargne", 'Savings Pots']) &&
          driver.hasAnyText(['Vacation']),
      reason: 'savings pots list',
    );

    await driver.tapText(['Vacation']);
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Add Money', "Ajouter de l'argent"]) &&
          driver.hasAnyText([
            'Transaction History',
            'Historique des transactions',
          ]),
      reason: 'savings pot detail screen',
    );

    await driver.tapText(['Add Money', "Ajouter de l'argent"]);
    await driver.pumpUntil(
      () => driver.hasAnyText(['Available Balance', 'Solde disponible']),
      reason: 'add money sheet',
    );

    await driver.enterFirstTextFormField('5');
    await driver.tapText(['Add to Pot', 'Ajouter au pot']);
    await driver.pumpUntil(
      () => driver.hasAnyText(['Enter PIN', 'code PIN', 'PIN']),
      reason: 'savings pot PIN sheet',
    );
    await driver.enterPin(KoridoFlowDriver.defaultPin);

    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Money added successfully',
        'Argent ajouté avec succès',
      ]),
      reason: 'savings pot add success',
      timeout: const Duration(seconds: 30),
    );
  });

  testWidgets('opens recurring transfer details from the list', (tester) async {
    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.goToRoute('/recurring-transfers');
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Recurring Transfers', 'Transferts récurrents']) &&
          driver.hasAnyText(['Fatou Diallo']),
      reason: 'recurring transfers list',
    );

    await driver.tapText(['Fatou Diallo']);
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Transfer Details', 'Détails du transfert']) &&
          driver.hasAnyText(['Statistics', 'Statistiques']),
      reason: 'recurring transfer detail screen',
    );
  });

  testWidgets('requests a virtual card and opens its details', (tester) async {
    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await driver.completeOnboarding();

    await driver.goToRoute('/cards');
    await driver.pumpUntil(
      () => driver.hasAnyText(['My Cards', 'Mes cartes', 'Aucune carte']),
      reason: 'cards list or empty state',
    );

    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Create Card',
        'Créer une carte',
        'Demander une carte',
      ]),
      reason: 'card creation action',
    );
    await driver.tapText([
      'Create Card',
      'Créer une carte',
      'Demander une carte',
    ]);
    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Request Card',
        'Demander une carte',
        'Request a Card',
      ]),
      reason: 'request card screen',
    );
    await driver.pumpUntil(
      () => find.byType(TextFormField).evaluate().length >= 2,
      reason: 'card request form fields',
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Awa Kone');
    await tester.enterText(fields.at(1), '100');
    await driver.dismissKeyboard();
    await driver.tapText([
      'Request Virtual Card',
      'Demander une carte virtuelle',
    ]);

    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['My Cards', 'Mes cartes']) &&
          driver.hasAnyText(['Details', 'Détails']),
      reason: 'created card controls',
      timeout: const Duration(seconds: 30),
    );

    await driver.tapText(['Details', 'Détails']);
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Card Details', 'Détails de la carte']) &&
          driver.hasAnyText(['Card Information', 'Informations de la carte']),
      reason: 'card detail screen',
    );
  });
}
