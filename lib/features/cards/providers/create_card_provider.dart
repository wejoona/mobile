import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';

/// Create card flow state.
class CreateCardState {
  final bool isLoading;
  final String? error;
  final String cardType; // 'virtual' or 'physical'
  final String? nickname;
  final bool isComplete;

  const CreateCardState({this.isLoading = false, this.error, this.cardType = 'virtual', this.nickname, this.isComplete = false});

  CreateCardState copyWith({bool? isLoading, String? error, String? cardType, String? nickname, bool? isComplete}) => CreateCardState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    cardType: cardType ?? this.cardType,
    nickname: nickname ?? this.nickname,
    isComplete: isComplete ?? this.isComplete,
  );
}

/// Create card notifier.
class CreateCardNotifier extends Notifier<CreateCardState> {
  @override
  CreateCardState build() => const CreateCardState();

  void setCardType(String type) => state = state.copyWith(cardType: type);
  void setNickname(String name) => state = state.copyWith(nickname: name);

  Future<void> create() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(cardsServiceProvider);
      await service.createCard(
        cardType: state.cardType,
        currency: 'USDC',
        nickname: state.nickname,
      );
      state = state.copyWith(isLoading: false, isComplete: true);
      ref.invalidate(cardsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const CreateCardState();
}

final createCardProvider = NotifierProvider<CreateCardNotifier, CreateCardState>(CreateCardNotifier.new);
