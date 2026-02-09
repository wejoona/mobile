import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';
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

  Dio get _dio => ref.read(dioProvider);

  /// Load user's cards
  /// GET /cards
  Future<void> loadCards() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/cards');

      final data = response.data as Map<String, dynamic>;
      final cardsJson = data['cards'] as List;
      final cards = cardsJson
          .map((json) => VirtualCard.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        cards: cards,
        canRequestCard: cards.isEmpty,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
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
  /// GET /cards/:id (card detail includes transactions context)
  Future<void> loadCardTransactions(String cardId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/cards/$cardId');

      final data = response.data;
      // Update selected card with full details
      final card = VirtualCard.fromJson(data as Map<String, dynamic>);

      // Transactions may come from a separate endpoint or be part of card detail
      final transactionsJson = (data['transactions'] as List?) ?? [];
      final transactions = transactionsJson
          .map((json) => CardTransaction.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        selectedCard: card,
        transactions: transactions,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Request new virtual card
  /// POST /cards { cardholderName, spendingLimit }
  Future<bool> requestCard({
    required String cardholderName,
    required double spendingLimit,
  }) async {
    state = state.copyWith(isLoading: true, requestError: null);
    try {
      await _dio.post('/cards', data: {
        'cardholderName': cardholderName,
        'spendingLimit': spendingLimit,
      });

      // Reload cards to get the new card
      await loadCards();

      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        requestError: ApiException.fromDioError(e).message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        requestError: e.toString(),
      );
      return false;
    }
  }

  /// Freeze card
  /// PUT /cards/:id/freeze
  Future<bool> freezeCard(String cardId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.put('/cards/$cardId/freeze');

      final updatedCard = VirtualCard.fromJson(response.data as Map<String, dynamic>);

      // Update local state
      final updatedCards = state.cards.map((card) {
        return card.id == cardId ? updatedCard : card;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cards: updatedCards,
        selectedCard: state.selectedCard?.id == cardId ? updatedCard : state.selectedCard,
      );

      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Unfreeze card
  /// PUT /cards/:id/unfreeze
  Future<bool> unfreezeCard(String cardId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.put('/cards/$cardId/unfreeze');

      final updatedCard = VirtualCard.fromJson(response.data as Map<String, dynamic>);

      final updatedCards = state.cards.map((card) {
        return card.id == cardId ? updatedCard : card;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cards: updatedCards,
        selectedCard: state.selectedCard?.id == cardId ? updatedCard : state.selectedCard,
      );

      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update spending limit
  /// PUT /cards/:id/limit { spendingLimit }
  Future<bool> updateSpendingLimit(String cardId, double newLimit) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.put('/cards/$cardId/limit', data: {
        'spendingLimit': newLimit,
      });

      final updatedCard = VirtualCard.fromJson(response.data as Map<String, dynamic>);

      final updatedCards = state.cards.map((card) {
        return card.id == cardId ? updatedCard : card;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        cards: updatedCards,
        selectedCard: state.selectedCard?.id == cardId ? updatedCard : state.selectedCard,
      );

      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
      );
      return false;
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
