import 'package:dio/dio.dart';

/// Cards Service
///
/// Handles virtual and physical card operations.
class CardsService {
  final Dio _dio;

  CardsService(this._dio);

  /// Get all cards for the user
  Future<Map<String, dynamic>> getCards() async {
    final response = await _dio.get('/cards');
    return response.data as Map<String, dynamic>;
  }

  /// Get a single card by ID
  Future<Map<String, dynamic>> getCard(String cardId) async {
    final response = await _dio.get('/cards/$cardId');
    return response.data as Map<String, dynamic>;
  }

  /// Create a new virtual or physical card
  Future<Map<String, dynamic>> createCard({
    required String cardType, // 'virtual' or 'physical'
    required String currency,
    String? nickname,
  }) async {
    final response = await _dio.post(
      '/cards',
      data: {
        'cardType': cardType,
        'currency': currency,
        if (nickname != null) 'nickname': nickname,
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
      data: {
        'dailyLimit': dailyLimit,
        'transactionLimit': transactionLimit,
      },
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
}
