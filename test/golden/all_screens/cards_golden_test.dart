// Golden tests for Cards feature screens
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/cards/models/virtual_card.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';
import 'package:usdc_wallet/features/cards/views/card_detail_view.dart';
import 'package:usdc_wallet/features/cards/views/card_settings_view.dart';
import 'package:usdc_wallet/features/cards/views/card_transactions_view.dart';
import 'package:usdc_wallet/features/cards/views/cards_list_view.dart';
import 'package:usdc_wallet/features/cards/views/cards_screen.dart';
import 'package:usdc_wallet/features/cards/views/request_card_view.dart';

import '../helpers/golden_test_helper.dart';

/// Mock notifier for CardsState with pre-set data and no async delays
class MockCardsNotifier extends Notifier<CardsState> implements CardsNotifier {
  final CardsState initialState;

  MockCardsNotifier(this.initialState);

  @override
  CardsState build() => initialState;

  @override
  Future<void> loadCards() async {}

  @override
  void selectCard(VirtualCard card) {}

  @override
  Future<void> loadCardTransactions(String cardId) async {
    // No-op in tests - state is already set
  }

  @override
  Future<bool> requestCard({
    required String cardholderName,
    required double spendingLimit,
  }) async => true;

  @override
  Future<bool> freezeCard(String cardId) async => true;

  @override
  Future<bool> unfreezeCard(String cardId) async => true;

  @override
  Future<bool> updateSpendingLimit(String cardId, double newLimit) async => true;

  @override
  void clearError() {}
}

// Test data
final _testCard = VirtualCard(
  id: 'card_001',
  userId: 'user_001',
  cardNumber: '4242424242424242',
  cvv: '123',
  expiryMonth: '12',
  expiryYear: '2028',
  cardholderName: 'John Doe',
  status: CardStatus.active,
  spendingLimit: 5000.0,
  spentAmount: 1250.0,
  currency: 'USD',
  createdAt: DateTime(2024, 1, 15),
);

final _testTransactions = [
  CardTransaction(
    id: 'tx_001',
    cardId: 'card_001',
    merchantName: 'Amazon',
    merchantCategory: 'Shopping',
    amount: 99.99,
    currency: 'USD',
    status: 'completed',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  CardTransaction(
    id: 'tx_002',
    cardId: 'card_001',
    merchantName: 'Uber',
    merchantCategory: 'Transport',
    amount: 25.50,
    currency: 'USD',
    status: 'completed',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

final _loadedState = CardsState(
  isLoading: false,
  cards: [_testCard],
  selectedCard: _testCard,
  transactions: _testTransactions,
  canRequestCard: false,
);

final _emptyState = const CardsState(
  isLoading: false,
  cards: [],
  transactions: [],
  canRequestCard: true,
);

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('CardsScreen Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_emptyState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: false,
            child: CardsScreen(),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/main/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_emptyState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: true,
            child: CardsScreen(),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/main/default_dark.png'),
      );
    });
  });

  group('CardsListView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_loadedState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: false,
            child: CardsListView(),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/list/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_loadedState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: true,
            child: CardsListView(),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/list/default_dark.png'),
      );
    });
  });

  group('CardDetailView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_loadedState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: false,
            child: CardDetailView(cardId: 'card_001'),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/detail/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_loadedState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: true,
            child: CardDetailView(cardId: 'card_001'),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/detail/default_dark.png'),
      );
    });
  });

  group('CardSettingsView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_loadedState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: false,
            child: CardSettingsView(cardId: 'card_001'),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/settings/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_loadedState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: true,
            child: CardSettingsView(cardId: 'card_001'),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/settings/default_dark.png'),
      );
    });
  });

  group('CardTransactionsView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_loadedState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: false,
            child: CardTransactionsView(cardId: 'card_001'),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/transactions/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_loadedState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: true,
            child: CardTransactionsView(cardId: 'card_001'),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/transactions/default_dark.png'),
      );
    });
  });

  group('RequestCardView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_emptyState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: false,
            child: RequestCardView(),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/request/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        ProviderScope(
          overrides: [
            cardsProvider.overrideWith(() => MockCardsNotifier(_emptyState)),
          ],
          child: GoldenTestWrapper(
            isDarkMode: true,
            child: RequestCardView(),
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cards/request/default_dark.png'),
      );
    });
  });
}
