import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

/// Create card flow state.
class CreateCardState {
  final bool isLoading;
  final String? error;
  final String cardType; // 'virtual' or 'physical'
  final String? nickname;
  final String? cardholderName;
  final double? spendingLimit;
  final bool isComplete;

  const CreateCardState({
    this.isLoading = false,
    this.error,
    this.cardType = 'virtual',
    this.nickname,
    this.cardholderName,
    this.spendingLimit,
    this.isComplete = false,
  });

  CreateCardState copyWith({
    bool? isLoading,
    String? error,
    String? cardType,
    String? nickname,
    String? cardholderName,
    double? spendingLimit,
    bool? isComplete,
  }) => CreateCardState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    cardType: cardType ?? this.cardType,
    nickname: nickname ?? this.nickname,
    cardholderName: cardholderName ?? this.cardholderName,
    spendingLimit: spendingLimit ?? this.spendingLimit,
    isComplete: isComplete ?? this.isComplete,
  );
}

/// Create card notifier.
class CreateCardNotifier extends Notifier<CreateCardState> {
  @override
  CreateCardState build() => const CreateCardState();

  void setCardType(String type) => state = state.copyWith(cardType: type);
  void setNickname(String name) => state = state.copyWith(nickname: name);
  void setCardholderName(String name) =>
      state = state.copyWith(cardholderName: name.trim());
  void setSpendingLimit(double limit) =>
      state = state.copyWith(spendingLimit: limit);

  Future<void> create() async {
    final cardholderName = state.cardholderName?.trim();
    final spendingLimit = state.spendingLimit;
    if (cardholderName == null || cardholderName.isEmpty) {
      state = state.copyWith(error: 'Cardholder name is required');
      return;
    }
    if (spendingLimit == null || spendingLimit <= 0) {
      state = state.copyWith(error: 'Spending limit is required');
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(cardsServiceProvider);
      await service.createCard(
        cardType: state.cardType,
        currency: 'USDC',
        nickname: state.nickname,
        cardholderName: cardholderName,
        spendingLimit: spendingLimit,
      );
      state = state.copyWith(isLoading: false, isComplete: true);
      ref.invalidate(cardsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: UserFacingErrors.message(e));
    }
  }

  void reset() => state = const CreateCardState();
}

final createCardProvider =
    NotifierProvider<CreateCardNotifier, CreateCardState>(
      CreateCardNotifier.new,
    );
