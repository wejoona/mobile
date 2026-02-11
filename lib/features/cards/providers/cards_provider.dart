import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/card.dart';
import '../../../services/api/api_client.dart';

/// Cards list provider.
final cardsProvider = FutureProvider<List<KoridoCard>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 2), () => link.close());

  final response = await dio.get('/cards');
  final data = response.data as Map<String, dynamic>;
  final items = data['data'] as List? ?? [];
  return items
      .map((e) => KoridoCard.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Active cards only.
final activeCardsProvider = Provider<List<KoridoCard>>((ref) {
  final cards = ref.watch(cardsProvider).valueOrNull ?? [];
  return cards.where((c) => c.isActive && !c.isExpired).toList();
});

/// Card actions.
class CardActions {
  final Dio _dio;

  CardActions(this._dio);

  Future<KoridoCard> requestVirtual({String? nickname}) async {
    final response = await _dio.post('/cards', data: {
      'type': 'virtual',
      if (nickname != null) 'nickname': nickname,
    });
    return KoridoCard.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> block(String cardId) async {
    await _dio.patch('/cards/$cardId/block');
  }

  Future<void> unblock(String cardId) async {
    await _dio.patch('/cards/$cardId/unblock');
  }

  Future<void> freeze(String cardId) async {
    await _dio.patch('/cards/$cardId/freeze');
  }

  Future<void> setSpendingLimit(String cardId, double limit) async {
    await _dio.patch('/cards/$cardId/limit', data: {
      'spendingLimit': limit,
    });
  }

  Future<void> rename(String cardId, String nickname) async {
    await _dio.patch('/cards/$cardId', data: {
      'nickname': nickname,
    });
  }
}

final cardActionsProvider = Provider<CardActions>((ref) {
  return CardActions(ref.watch(dioProvider));
});
