import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/card.dart';
import 'package:usdc_wallet/services/service_providers.dart';

/// Cards list provider — wired to CardsService (real API with mock fallback).
final cardsProvider = FutureProvider<List<KoridoCard>>((ref) async {
  final service = ref.watch(cardsServiceProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 2), () => link.close());

  final data = await service.getCards();
  final items = (data['data'] as List?) ?? [];
  return items.map((e) => KoridoCard.fromJson(e as Map<String, dynamic>)).toList();
});

/// Active cards only.
final activeCardsProvider = Provider<List<KoridoCard>>((ref) {
  final cards = ref.watch(cardsProvider).value ?? [];
  return cards.where((c) => c.isActive && !c.isExpired).toList();
});

/// Card actions delegate.
final cardActionsProvider = Provider((ref) => ref.watch(cardsServiceProvider));

/// Selected card by ID.
final selectedCardProvider = Provider.family<KoridoCard?, String>((ref, cardId) {
  final cards = ref.watch(cardsProvider).valueOrNull ?? [];
  try {
    return cards.firstWhere((c) => c.id == cardId);
  } catch (_) {
    return null;
  }
});

/// CardsState compatibility wrapper.
class CardsState {
  final List<KoridoCard> cards;
  final KoridoCard? selectedCard;
  final List<dynamic> transactions;
  final String? requestError;
  final bool isLoading;

  const CardsState({
    this.cards = const [],
    this.selectedCard,
    this.transactions = const [],
    this.requestError,
    this.isLoading = false,
  });
}
