import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/domain/entities/card.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';

/// Run 385: Card details provider with sensitive data reveal
class CardDetailsState {
  final KoridoCard? card;
  final bool isRevealed;
  final bool isLoading;
  final String? error;
  final DateTime? revealedAt;

  const CardDetailsState({
    this.card,
    this.isRevealed = false,
    this.isLoading = false,
    this.error,
    this.revealedAt,
  });

  // Auto-hide after 30 seconds
  bool get shouldAutoHide {
    if (!isRevealed || revealedAt == null) return false;
    return DateTime.now().difference(revealedAt!).inSeconds > 30;
  }

  CardDetailsState copyWith({
    KoridoCard? card,
    bool? isRevealed,
    bool? isLoading,
    String? error,
    DateTime? revealedAt,
  }) => CardDetailsState(
    card: card ?? this.card,
    isRevealed: isRevealed ?? this.isRevealed,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    revealedAt: revealedAt ?? this.revealedAt,
  );
}

class CardDetailsNotifier extends StateNotifier<CardDetailsState> {
  final Ref _ref;
  final String _cardId;

  CardDetailsNotifier(this._ref, this._cardId) : super(const CardDetailsState()) {
    loadCard(_cardId);
  }

  Future<void> loadCard(String cardId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = _ref.read(cardsServiceProvider);
      final data = await service.getCard(cardId);
      final card = KoridoCard.fromJson(data);
      state = state.copyWith(isLoading: false, card: card);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> revealDetails() async {
    // Requires PIN/biometric verification before revealing
    state = state.copyWith(
      isRevealed: true,
      revealedAt: DateTime.now(),
    );
    // Auto-hide after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) hideDetails();
    });
  }

  void hideDetails() {
    state = state.copyWith(isRevealed: false);
  }

  Future<void> freezeCard() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = _ref.read(cardsServiceProvider);
      await service.freezeCard(_cardId);
      state = state.copyWith(isLoading: false);
      _ref.invalidate(cardsProvider);
      await loadCard(_cardId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> unfreezeCard() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = _ref.read(cardsServiceProvider);
      await service.unfreezeCard(_cardId);
      state = state.copyWith(isLoading: false);
      _ref.invalidate(cardsProvider);
      await loadCard(_cardId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final cardDetailsProvider =
    StateNotifierProvider.family<CardDetailsNotifier, CardDetailsState, String>(
        (ref, cardId) {
  return CardDetailsNotifier(ref, cardId);
});
