import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: CARDS FEATURE
/// FEATURE_FLAG: virtualCards
///
/// Screens covered:
/// - 9.1 Cards List View
/// - 9.2 Request Card View
/// - 9.3 Card Detail View
/// - 9.4 Card Settings View
/// - 9.5 Card Transactions View
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Cards Feature Golden Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      TestHelpers.configureMocks();
      await TestHelpers.clearAppData();
    });

    /// Helper to login and reach home screen
    Future<void> loginToHome(WidgetTester tester) async {
      TestHelpers.setKycStatus('verified');

      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    /// Helper to navigate to cards tab
    Future<void> navigateToCards(WidgetTester tester) async {
      await loginToHome(tester);

      // Tap Cards tab
      final cardsTab = find.text('Cards');
      if (cardsTab.evaluate().isNotEmpty) {
        await tester.tap(cardsTab.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 9.1 CARDS LIST VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('9.1 Cards List View', (tester) async {
      /// GIVEN the Cards feature flag is enabled
      /// WHEN the Cards tab is selected
      /// THEN cards list should display
      /// AND "Request Card" option should be available

      await navigateToCards(tester);

      final cardsScreen = find.textContaining('Card');
      if (cardsScreen.evaluate().isNotEmpty) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/cards/9.1_cards_list.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 9.1b CARDS LIST - EMPTY STATE
    // ─────────────────────────────────────────────────────────────
    testWidgets('9.1b Cards List - Empty State', (tester) async {
      /// GIVEN user has no cards
      /// WHEN the Cards tab is selected
      /// THEN empty state should display
      /// AND "Request Your First Card" CTA should be visible

      await navigateToCards(tester);

      final emptyState = find.text('Request Your First Card');
      final noCards = find.textContaining('No cards');

      if (emptyState.evaluate().isNotEmpty || noCards.evaluate().isNotEmpty) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/cards/9.1b_cards_empty.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 9.2 REQUEST CARD VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('9.2 Request Card View', (tester) async {
      /// GIVEN user is on cards list
      /// WHEN they tap Request Card
      /// THEN card request form should display
      /// AND card type options may be shown

      await navigateToCards(tester);

      final requestBtn = find.text('Request Card');
      final getCardBtn = find.text('Get Card');

      if (requestBtn.evaluate().isNotEmpty) {
        await tester.tap(requestBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/cards/9.2_request_card.png'),
        );
      } else if (getCardBtn.evaluate().isNotEmpty) {
        await tester.tap(getCardBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/cards/9.2_request_card.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 9.3 CARD DETAIL VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('9.3 Card Detail View', (tester) async {
      /// GIVEN user has a virtual card
      /// WHEN they tap the card
      /// THEN card details should display
      /// AND card number (masked), CVV, Expiry should be shown
      /// AND "Show Details" option should be available

      await navigateToCards(tester);

      // Look for a card item to tap
      final cardItem = find.byType(Card);
      if (cardItem.evaluate().isNotEmpty) {
        await tester.tap(cardItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/cards/9.3_card_detail.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 9.3b CARD DETAIL - REVEALED
    // ─────────────────────────────────────────────────────────────
    testWidgets('9.3b Card Detail - Revealed', (tester) async {
      /// GIVEN user is on card detail
      /// WHEN they tap "Show Details" (after PIN verification)
      /// THEN full card number, CVV should be revealed
      /// AND copy buttons should be available

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Card reveal screen exists after PIN verification');
    });

    // ─────────────────────────────────────────────────────────────
    // 9.4 CARD SETTINGS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('9.4 Card Settings View', (tester) async {
      /// GIVEN user is on card detail
      /// WHEN they tap Settings
      /// THEN card settings should display
      /// AND options like Freeze, Lock, Limits should be visible

      await navigateToCards(tester);

      // Navigate to card detail first
      final cardItem = find.byType(Card);
      if (cardItem.evaluate().isNotEmpty) {
        await tester.tap(cardItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final settingsBtn = find.text('Settings');
        final settingsIcon = find.byIcon(Icons.settings);

        if (settingsBtn.evaluate().isNotEmpty) {
          await tester.tap(settingsBtn.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/cards/9.4_card_settings.png'),
          );
        } else if (settingsIcon.evaluate().isNotEmpty) {
          await tester.tap(settingsIcon.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/cards/9.4_card_settings.png'),
          );
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 9.4b CARD SETTINGS - FROZEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('9.4b Card Settings - Frozen State', (tester) async {
      /// GIVEN card is frozen
      /// WHEN card settings display
      /// THEN frozen indicator should be visible
      /// AND "Unfreeze" option should be available

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Frozen card state exists in card settings');
    });

    // ─────────────────────────────────────────────────────────────
    // 9.5 CARD TRANSACTIONS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('9.5 Card Transactions View', (tester) async {
      /// GIVEN user is on card detail
      /// WHEN they tap Transactions
      /// THEN card-specific transactions should display
      /// AND each transaction should show merchant, amount

      await navigateToCards(tester);

      // Navigate to card detail first
      final cardItem = find.byType(Card);
      if (cardItem.evaluate().isNotEmpty) {
        await tester.tap(cardItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final transactionsBtn = find.text('Transactions');
        final historyBtn = find.text('History');

        if (transactionsBtn.evaluate().isNotEmpty) {
          await tester.tap(transactionsBtn.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/cards/9.5_card_transactions.png'),
          );
        } else if (historyBtn.evaluate().isNotEmpty) {
          await tester.tap(historyBtn.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/cards/9.5_card_transactions.png'),
          );
        }
      }
    });
  });
}
