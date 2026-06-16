import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';

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
        return {...data, 'data': data['cards']};
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
    final effectiveCardholderName = cardholderName?.trim();
    if (effectiveCardholderName == null || effectiveCardholderName.isEmpty) {
      throw ArgumentError('cardholderName is required to create a card');
    }
    if (spendingLimit == null || spendingLimit <= 0) {
      throw ArgumentError('spendingLimit is required to create a card');
    }

    final response = await _dio.post(
      '/cards',
      data: {
        'cardholderName': effectiveCardholderName,
        'spendingLimit': spendingLimit,
        'cardType': cardType,
        if (currency != null) 'currency': currency,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Freeze a card
  Future<Map<String, dynamic>> freezeCard(
    String cardId, {
    required String pinToken,
  }) async {
    final response = await _dio.put(
      '/cards/$cardId/freeze',
      options: _pinProtectedOptions(pinToken),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Unfreeze a card
  Future<Map<String, dynamic>> unfreezeCard(
    String cardId, {
    required String pinToken,
  }) async {
    final response = await _dio.put(
      '/cards/$cardId/unfreeze',
      options: _pinProtectedOptions(pinToken),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Update spending limit
  Future<Map<String, dynamic>> updateSpendingLimit(
    String cardId, {
    required double dailyLimit,
    required double transactionLimit,
    required String pinToken,
  }) async {
    final response = await _dio.put(
      '/cards/$cardId/limit',
      data: {'spendingLimit': dailyLimit},
      options: _pinProtectedOptions(pinToken),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Cancel a card
  Future<void> cancelCard(String cardId, {required String pinToken}) async {
    await _dio.delete(
      '/cards/$cardId',
      options: _pinProtectedOptions(pinToken),
    );
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
  Future<void> freeze(String cardId, {required String pinToken}) =>
      freezeCard(cardId, pinToken: pinToken);
  Future<void> toggleCardFreeze(
    String cardId, {
    required String pinToken,
  }) async {
    // Determine current state and toggle
    final card = await getCard(cardId);
    final isFrozen = card['isFrozen'] as bool? ?? false;
    if (isFrozen) {
      await unfreezeCard(cardId, pinToken: pinToken);
    } else {
      await freezeCard(cardId, pinToken: pinToken);
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
  Future<void> setSpendLimit(
    String cardId,
    double limit, {
    required String pinToken,
  }) => updateSpendingLimit(
    cardId,
    dailyLimit: limit,
    transactionLimit: limit,
    pinToken: pinToken,
  );
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

Options _pinProtectedOptions(String pinToken) =>
    Options(headers: transactionHeaders(pinToken: pinToken));
