import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';

/// Card action state (freeze/unfreeze/cancel).
class CardActionState {
  final bool isLoading;
  final String? error;
  final bool isComplete;

  const CardActionState({this.isLoading = false, this.error, this.isComplete = false});
}

/// Card actions notifier.
class CardActionsNotifier extends Notifier<CardActionState> {
  @override
  CardActionState build() => const CardActionState();

  Future<void> freeze(String cardId) async {
    state = const CardActionState(isLoading: true);
    try {
      final service = ref.read(cardsServiceProvider);
      await service.freezeCard(cardId);
      state = const CardActionState(isComplete: true);
      ref.invalidate(cardsProvider);
    } catch (e) {
      state = CardActionState(error: e.toString());
    }
  }

  Future<void> unfreeze(String cardId) async {
    state = const CardActionState(isLoading: true);
    try {
      final service = ref.read(cardsServiceProvider);
      await service.unfreezeCard(cardId);
      state = const CardActionState(isComplete: true);
      ref.invalidate(cardsProvider);
    } catch (e) {
      state = CardActionState(error: e.toString());
    }
  }

  Future<void> cancel(String cardId) async {
    state = const CardActionState(isLoading: true);
    try {
      final service = ref.read(cardsServiceProvider);
      await service.cancelCard(cardId);
      state = const CardActionState(isComplete: true);
      ref.invalidate(cardsProvider);
    } catch (e) {
      state = CardActionState(error: e.toString());
    }
  }

  Future<void> setSpendLimit(String cardId, double limit) async {
    state = const CardActionState(isLoading: true);
    try {
      final service = ref.read(cardsServiceProvider);
      await service.setSpendLimit(cardId, limit);
      state = const CardActionState(isComplete: true);
      ref.invalidate(cardsProvider);
    } catch (e) {
      state = CardActionState(error: e.toString());
    }
  }
}

final cardActionsNotifierProvider = NotifierProvider<CardActionsNotifier, CardActionState>(CardActionsNotifier.new);
