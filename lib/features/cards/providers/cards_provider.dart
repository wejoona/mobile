import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/card.dart';
import 'package:usdc_wallet/services/service_providers.dart';

class CardsEnvelope {
  final List<KoridoCard> cards;
  final bool available;
  final String status;
  final String? reason;
  final String? featureReason;
  final String? provider;

  const CardsEnvelope({
    required this.cards,
    required this.available,
    required this.status,
    this.reason,
    this.featureReason,
    this.provider,
  });

  bool get canRequestCard => available && status != 'unavailable';
}

/// Cards API envelope — preserves capability metadata for unavailable states.
final cardsEnvelopeProvider = FutureProvider<CardsEnvelope>((ref) async {
  final service = ref.watch(cardsServiceProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 2), () => link.close());
  ref.onDispose(() => timer.cancel());

  final data = await service.getCards();
  final items = (data['data'] as List?) ?? [];
  final cards = items
      .map((e) => KoridoCard.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  return CardsEnvelope(
    cards: cards,
    available: data['available'] as bool? ?? true,
    status: data['status'] as String? ?? 'available',
    reason: data['reason'] as String?,
    featureReason: data['featureReason'] as String?,
    provider: data['provider'] as String?,
  );
});

/// Cards list provider — wired to CardsService (real API with mock fallback).
final cardsProvider = FutureProvider<List<KoridoCard>>((ref) async {
  final envelope = await ref.watch(cardsEnvelopeProvider.future);
  return envelope.cards;
});

/// Active cards only.
final activeCardsProvider = Provider<List<KoridoCard>>((ref) {
  final cards = ref.watch(cardsProvider).value ?? [];
  return cards.where((c) => c.isActive && !c.isExpired).toList();
});

/// Card actions delegate.
final cardActionsProvider = Provider((ref) => ref.watch(cardsServiceProvider));

/// Selected card by ID.
final selectedCardProvider = Provider.family<KoridoCard?, String>((
  ref,
  cardId,
) {
  final cards = ref.watch(cardsProvider).value ?? [];
  try {
    return cards.firstWhere((c) => c.id == cardId);
  } catch (_) {
    return null;
  }
});

// CardsState is defined in cards/models/cards_state.dart
