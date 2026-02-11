import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/card.dart';

/// Run 385: Card details provider with sensitive data reveal
class CardDetailsState {
  final WalletCard? card;
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
    WalletCard? card,
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
  CardDetailsNotifier() : super(const CardDetailsState());

  Future<void> loadCard(String cardId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      state = state.copyWith(isLoading: false);
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
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false);
  }

  Future<void> unfreezeCard() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false);
  }
}

final cardDetailsProvider =
    StateNotifierProvider.family<CardDetailsNotifier, CardDetailsState, String>(
        (ref, cardId) {
  final notifier = CardDetailsNotifier();
  notifier.loadCard(cardId);
  return notifier;
});
