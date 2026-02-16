import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/domain/entities/savings_pot.dart';

/// Savings Pots Service - mirrors backend SavingsPotController
class SavingsPotsService {
  final Dio _dio;

  SavingsPotsService(this._dio);

  /// GET /savings-pots
  Future<List<SavingsPot>> getAll() async {
    final response = await _dio.get('/savings-pots');
    final data = response.data;
    final items = (data is Map ? data['data'] : data) as List? ?? [];
    return items.map((e) => SavingsPot.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /savings-pots/:id
  Future<SavingsPot> getById(String id) async {
    final response = await _dio.get('/savings-pots/$id');
    return SavingsPot.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /savings-pots
  Future<SavingsPot> create({
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String currency = 'USDC',
  }) async {
    final response = await _dio.post('/savings-pots', data: {
      'name': name,
      'targetAmount': targetAmount,
      'currency': currency,
      if (targetDate != null) 'targetDate': targetDate.toIso8601String(),
    });
    return SavingsPot.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /savings-pots/:id/deposit
  Future<SavingsPot> deposit(String potId, double amount) async {
    final response = await _dio.post('/savings-pots/$potId/deposit', data: {
      'amount': amount,
    });
    return SavingsPot.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /savings-pots/:id/withdraw
  Future<SavingsPot> withdraw(String potId, double amount) async {
    final response = await _dio.post('/savings-pots/$potId/withdraw', data: {
      'amount': amount,
    });
    return SavingsPot.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /savings-pots/:id/withdraw-all
  Future<SavingsPot> withdrawAll(String potId) async {
    final response = await _dio.post('/savings-pots/$potId/withdraw-all');
    return SavingsPot.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /savings-pots/:id
  Future<void> delete(String potId) async {
    await _dio.delete('/savings-pots/$potId');
  }

  // Aliases used by views
  Future<dynamic> createPot({String? name, String? emoji, String? color, double? targetAmount, Map<String, dynamic>? data}) => create(
    name: data?['name'] as String? ?? name ?? '',
    targetAmount: (data?['targetAmount'] as num?)?.toDouble() ?? targetAmount ?? 0,
  );
  Future<void> deletePot(String potId) => delete(potId);
  Future<dynamic> updatePot({String? id, String? name, String? emoji, String? color, double? targetAmount, Map<String, dynamic>? data}) async {
    final potId = id ?? '';
    final payload = data ?? {'name': name, 'targetAmount': targetAmount};
    final response = await _dio.put('/savings-pots/$potId', data: payload);
    return SavingsPot.fromJson(response.data as Map<String, dynamic>);
  }
  Future<SavingsPot> addToPot(String potId, double amount) => deposit(potId, amount);
  Future<SavingsPot> withdrawFromPot(String potId, double amount) => withdraw(potId, amount);
  Future<List<SavingsPot>> loadPots() => getAll();
  void selectPot(String? potId) {}
}

final savingsPotsServiceProvider = Provider<SavingsPotsService>((ref) {
  return SavingsPotsService(ref.watch(dioProvider));
});
