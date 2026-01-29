import 'package:dio/dio.dart';
import '../models/savings_pot.dart';
import '../models/pot_transaction.dart';

/// Service for managing savings pots
class SavingsPotsService {
  final Dio _dio;

  SavingsPotsService(this._dio);

  /// Get all pots for the current user
  Future<List<SavingsPot>> getPots() async {
    final response = await _dio.get('/savings-pots');
    return (response.data['pots'] as List)
        .map((json) => SavingsPot.fromJson(json))
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
        'emoji': emoji,
        'color': colorValue,
        'targetAmount': targetAmount,
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
    final response = await _dio.patch(
      '/savings-pots/$id',
      data: {
        if (name != null) 'name': name,
        if (emoji != null) 'emoji': emoji,
        if (colorValue != null) 'color': colorValue,
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
  }) async {
    final response = await _dio.post(
      '/savings-pots/$potId/deposit',
      data: {'amount': amount},
    );
    return SavingsPot.fromJson(response.data);
  }

  /// Withdraw money from a pot
  Future<SavingsPot> withdrawFromPot({
    required String potId,
    required double amount,
  }) async {
    final response = await _dio.post(
      '/savings-pots/$potId/withdraw',
      data: {'amount': amount},
    );
    return SavingsPot.fromJson(response.data);
  }

  /// Get transaction history for a pot
  Future<List<PotTransaction>> getPotTransactions(String potId) async {
    final response = await _dio.get('/savings-pots/$potId/transactions');
    return (response.data['transactions'] as List)
        .map((json) => PotTransaction.fromJson(json))
        .toList();
  }
}
