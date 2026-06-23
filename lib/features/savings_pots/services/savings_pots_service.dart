import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/domain/entities/savings_pot.dart';
import 'package:usdc_wallet/features/savings_pots/models/pot_transaction.dart';

/// Service for managing savings pots
class SavingsPotsService {
  final Dio _dio;

  SavingsPotsService(this._dio);

  /// Get all pots for the current user
  Future<List<SavingsPot>> getPots() async {
    final response = await _dio.get('/savings-pots');
    final data = response.data;
    final pots = data is List
        ? data
        : data is Map
        ? (data['pots'] ?? data['data'] ?? data['items']) as List? ?? []
        : const [];
    return pots
        .map((json) => SavingsPot.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  /// Create a new pot
  Future<SavingsPot> createPot({
    required String name,
    required String emoji,
    required int colorValue,
    double? targetAmount,
  }) async {
    final response = await _dio.post(
      '/savings-pots',
      data: {
        'name': name,
        if (targetAmount != null) 'targetAmount': targetAmount,
        'currency': 'USDC',
      },
    );
    return SavingsPot.fromJson(response.data);
  }

  /// Update an existing pot
  Future<SavingsPot> updatePot({
    required String id,
    String? name,
    String? emoji,
    int? colorValue,
    double? targetAmount,
  }) async {
    final response = await _dio.put(
      '/savings-pots/$id',
      data: {
        if (name != null) 'name': name,
        if (targetAmount != null) 'targetAmount': targetAmount,
      },
    );
    return SavingsPot.fromJson(response.data);
  }

  /// Delete a pot (returns money to main balance)
  Future<void> deletePot(String id) async {
    await _dio.delete('/savings-pots/$id');
  }

  /// Add money to a pot
  Future<SavingsPot> addToPot({
    required String potId,
    required double amount,
    required String pinToken,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/savings-pots/$potId/deposit',
      data: {'amount': amount},
      options: Options(
        headers: transactionHeaders(
          pinToken: pinToken,
          idempotencyKey: idempotencyKey,
        ),
      ),
    );
    return SavingsPot.fromJson(response.data);
  }

  /// Withdraw money from a pot
  Future<SavingsPot> withdrawFromPot({
    required String potId,
    required double amount,
    required String pinToken,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/savings-pots/$potId/withdraw',
      data: {'amount': amount},
      options: Options(
        headers: transactionHeaders(
          pinToken: pinToken,
          idempotencyKey: idempotencyKey,
        ),
      ),
    );
    return SavingsPot.fromJson(response.data);
  }

  /// Get transaction history for a pot
  Future<List<PotTransaction>> getPotTransactions(String potId) async {
    try {
      final response = await _dio.get('/savings-pots/$potId/transactions');
      final data = response.data;
      final transactions = data is List
          ? data
          : data is Map
          ? (data['transactions'] ?? data['data'] ?? data['items']) as List? ??
                []
          : const [];
      return transactions
          .map(
            (json) => PotTransaction.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      rethrow;
    }
  }
}
