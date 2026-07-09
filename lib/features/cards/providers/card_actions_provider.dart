import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

/// Card action state (freeze/unfreeze/cancel).
class CardActionState {
  final bool isLoading;
  final String? error;
  final bool isComplete;

  const CardActionState({
    this.isLoading = false,
    this.error,
    this.isComplete = false,
  });
}

/// Card actions notifier.
class CardActionsNotifier extends Notifier<CardActionState> {
  @override
  CardActionState build() => const CardActionState();

  Future<void> freeze(String cardId, {required String pinToken}) async {
    state = const CardActionState(isLoading: true);
    try {
      final service = ref.read(cardsServiceProvider);
      await service.freezeCard(cardId, pinToken: pinToken);
      state = const CardActionState(isComplete: true);
      ref.invalidate(cardsProvider);
    } catch (e) {
      state = CardActionState(error: UserFacingErrors.message(e));
    }
  }

  Future<void> unfreeze(String cardId, {required String pinToken}) async {
    state = const CardActionState(isLoading: true);
    try {
      final service = ref.read(cardsServiceProvider);
      await service.unfreezeCard(cardId, pinToken: pinToken);
      state = const CardActionState(isComplete: true);
      ref.invalidate(cardsProvider);
    } catch (e) {
      state = CardActionState(error: UserFacingErrors.message(e));
    }
  }

  Future<void> cancel(String cardId, {required String pinToken}) async {
    state = const CardActionState(isLoading: true);
    try {
      final service = ref.read(cardsServiceProvider);
      await service.cancelCard(cardId, pinToken: pinToken);
      state = const CardActionState(isComplete: true);
      ref.invalidate(cardsProvider);
    } catch (e) {
      state = CardActionState(error: UserFacingErrors.message(e));
    }
  }

  Future<void> setSpendLimit(
    String cardId,
    double limit, {
    required String pinToken,
  }) async {
    state = const CardActionState(isLoading: true);
    try {
      final service = ref.read(cardsServiceProvider);
      await service.setSpendLimit(cardId, limit, pinToken: pinToken);
      state = const CardActionState(isComplete: true);
      ref.invalidate(cardsProvider);
    } catch (e) {
      state = CardActionState(error: UserFacingErrors.message(e));
    }
  }
}

final cardActionsNotifierProvider =
    NotifierProvider<CardActionsNotifier, CardActionState>(
      CardActionsNotifier.new,
    );
