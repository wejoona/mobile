import 'package:dio/dio.dart';

/// Cards Service
///
/// Handles virtual and physical card operations.
class CardsService {
  final Dio _dio;

  CardsService(this._dio);

  /// Get all cards for the user
  /// Backend returns { cards: [...] } (CardListResponseDto)
  Future<Map<String, dynamic>> getCards() async {
    final response = await _dio.get('/cards');
    final data = response.data;
    // Normalize: backend returns { cards: [...] }, but callers expect { data: [...] }
    if (data is Map<String, dynamic>) {
      if (data.containsKey('cards') && !data.containsKey('data')) {
        return {'data': data['cards']};
      }
      return data;
    }
    // Direct list response
    if (data is List) {
      return {'data': data};
    }
    return {'data': []};
  }

  /// Get a single card by ID
  Future<Map<String, dynamic>> getCard(String cardId) async {
    final response = await _dio.get('/cards/$cardId');
    return response.data as Map<String, dynamic>;
  }

  /// Create a new virtual or physical card
  Future<Map<String, dynamic>> createCard({
    String cardType = 'virtual',
    String? currency,
    String? nickname,
    String? cardholderName,
    double? spendingLimit,
  }) async {
    final response = await _dio.post(
      '/cards',
      data: {
        'cardholderName': cardholderName ?? nickname ?? 'Korido User',
        'spendingLimit': spendingLimit ?? 500,
        'cardType': cardType,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Freeze a card
  Future<Map<String, dynamic>> freezeCard(String cardId) async {
    final response = await _dio.put('/cards/$cardId/freeze');
    return response.data as Map<String, dynamic>;
  }

  /// Unfreeze a card
  Future<Map<String, dynamic>> unfreezeCard(String cardId) async {
    final response = await _dio.put('/cards/$cardId/unfreeze');
    return response.data as Map<String, dynamic>;
  }

  /// Update spending limit
  Future<Map<String, dynamic>> updateSpendingLimit(
    String cardId, {
    required double dailyLimit,
    required double transactionLimit,
  }) async {
    final response = await _dio.put(
      '/cards/$cardId/limit',
      data: {'spendingLimit': dailyLimit},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Cancel a card
  Future<void> cancelCard(String cardId) async {
    await _dio.delete('/cards/$cardId');
  }

  /// Get card transactions
  Future<Map<String, dynamic>> getCardTransactions(
    String cardId, {
    int? limit,
    int? offset,
  }) async {
    final response = await _dio.get(
      '/cards/$cardId/transactions',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // === Convenience aliases ===
  Future<void> freeze(String cardId) => freezeCard(cardId);
  Future<void> block(String cardId) => cancelCard(cardId);
  Future<void> toggleCardFreeze(String cardId) async {
    // Determine current state and toggle
    final card = await getCard(cardId);
    final isFrozen = card['isFrozen'] as bool? ?? false;
    if (isFrozen) {
      await unfreezeCard(cardId);
    } else {
      await freezeCard(cardId);
    }
  }

  Future<Map<String, dynamic>> requestCard(Map<String, dynamic> data) =>
      createCard(
        cardType: data['cardType'] as String? ?? 'virtual',
        currency: data['currency'] as String? ?? 'USDC',
        nickname: data['nickname'] as String?,
        cardholderName: data['cardholderName'] as String?,
        spendingLimit: _parseDouble(data['spendingLimit']),
      );
  Future<Map<String, dynamic>> requestVirtual(Map<String, dynamic> data) =>
      createCard(
        cardType: 'virtual',
        currency: data['currency'] as String? ?? 'USDC',
        nickname: data['nickname'] as String?,
        cardholderName: data['cardholderName'] as String?,
        spendingLimit: _parseDouble(data['spendingLimit']),
      );
  Future<void> setSpendLimit(String cardId, double limit) =>
      updateSpendingLimit(cardId, dailyLimit: limit, transactionLimit: limit);
  Future<List<dynamic>> loadCardTransactions(String cardId) async {
    final result = await getCardTransactions(cardId);
    return (result['data'] as List?) ?? (result['transactions'] as List?) ?? [];
  }
}

double? _parseDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
