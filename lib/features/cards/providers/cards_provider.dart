import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/virtual_card.dart';

/// Cards State
class CardsState {
  final bool isLoading;
  final String? error;
  final List<VirtualCard> cards;
  final VirtualCard? selectedCard;
  final List<CardTransaction> transactions;
  final bool canRequestCard;
  final String? requestError;

  const CardsState({
    this.isLoading = false,
    this.error,
    this.cards = const [],
    this.selectedCard,
    this.transactions = const [],
    this.canRequestCard = false,
    this.requestError,
  });

  CardsState copyWith({
    bool? isLoading,
    String? error,
    List<VirtualCard>? cards,
    VirtualCard? selectedCard,
    List<CardTransaction>? transactions,
    bool? canRequestCard,
    String? requestError,
  }) {
    return CardsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      cards: cards ?? this.cards,
      selectedCard: selectedCard ?? this.selectedCard,
      transactions: transactions ?? this.transactions,
      canRequestCard: canRequestCard ?? this.canRequestCard,
      requestError: requestError,
    );
  }

  CardsState clearError() => copyWith(error: null, requestError: null);
}

/// Cards Notifier
class CardsNotifier extends Notifier<CardsState> {
  @override
  CardsState build() => const CardsState();

  /// Load user's cards
  Future<void> loadCards() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Call API
      // final sdk = ref.read(sdkProvider);
      // final cards = await sdk.cards.getCards();

      // Mock response for now
      await Future.delayed(const Duration(milliseconds: 500));
      final cards = <VirtualCard>[];

      state = state.copyWith(
        isLoading: false,
        cards: cards,
        canRequestCard: cards.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Select card for details view
  void selectCard(VirtualCard card) {
    state = state.copyWith(selectedCard: card);
  }

  /// Load card transactions
  Future<void> loadCardTransactions(String cardId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Call API
      // final sdk = ref.read(sdkProvider);
      // final transactions = await sdk.cards.getCardTransactions(cardId);

      // Mock response
      await Future.delayed(const Duration(milliseconds: 500));
      final transactions = <CardTransaction>[];

      state = state.copyWith(
        isLoading: false,
        transactions: transactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Request new virtual card
  Future<bool> requestCard({
    required String cardholderName,
    required double spendingLimit,
  }) async {
    state = state.copyWith(isLoading: true, requestError: null);
    try {
      // TODO: Call API
      // final sdk = ref.read(sdkProvider);
      // final card = await sdk.cards.requestCard(
      //   cardholderName: cardholderName,
      //   spendingLimit: spendingLimit,
      // );

      // Mock response
      await Future.delayed(const Duration(seconds: 1));

      // Reload cards
      await loadCards();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        requestError: e.toString(),
      );
      return false;
    }
  }

  /// Freeze card
  Future<bool> freezeCard(String cardId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Call API
      // final sdk = ref.read(sdkProvider);
      // await sdk.cards.freezeCard(cardId);

      // Mock response
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local state
      final updatedCards = state.cards.map((card) {
        if (card.id == cardId) {
          return card.copyWith(
            status: CardStatus.frozen,
            frozenAt: DateTime.now(),
          );
        }
        return card;
      }).toList();

      final updatedSelectedCard = state.selectedCard?.id == cardId
          ? state.selectedCard!.copyWith(
              status: CardStatus.frozen,
              frozenAt: DateTime.now(),
            )
          : state.selectedCard;

      state = state.copyWith(
        isLoading: false,
        cards: updatedCards,
        selectedCard: updatedSelectedCard,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Unfreeze card
  Future<bool> unfreezeCard(String cardId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Call API
      // final sdk = ref.read(sdkProvider);
      // await sdk.cards.unfreezeCard(cardId);

      // Mock response
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local state
      final updatedCards = state.cards.map((card) {
        if (card.id == cardId) {
          return card.copyWith(
            status: CardStatus.active,
            frozenAt: null,
          );
        }
        return card;
      }).toList();

      final updatedSelectedCard = state.selectedCard?.id == cardId
          ? state.selectedCard!.copyWith(
              status: CardStatus.active,
              frozenAt: null,
            )
          : state.selectedCard;

      state = state.copyWith(
        isLoading: false,
        cards: updatedCards,
        selectedCard: updatedSelectedCard,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update spending limit
  Future<bool> updateSpendingLimit(String cardId, double newLimit) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Call API
      // final sdk = ref.read(sdkProvider);
      // await sdk.cards.updateSpendingLimit(cardId, newLimit);

      // Mock response
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local state
      final updatedCards = state.cards.map((card) {
        if (card.id == cardId) {
          return card.copyWith(spendingLimit: newLimit);
        }
        return card;
      }).toList();

      final updatedSelectedCard = state.selectedCard?.id == cardId
          ? state.selectedCard!.copyWith(spendingLimit: newLimit)
          : state.selectedCard;

      state = state.copyWith(
        isLoading: false,
        cards: updatedCards,
        selectedCard: updatedSelectedCard,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }
}

/// Cards Provider
final cardsProvider = NotifierProvider<CardsNotifier, CardsState>(
  CardsNotifier.new,
);
