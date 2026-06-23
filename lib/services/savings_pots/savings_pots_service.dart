import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
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
    final items = _extractSavingsPotList(data);
    return items.map((e) => SavingsPot.fromJson(_asStringMap(e))).toList();
  }

  /// GET /savings-pots/:id
  Future<SavingsPot> getById(String id) async {
    final response = await _dio.get('/savings-pots/$id');
    return SavingsPot.fromJson(_extractSavingsPot(response.data));
  }

  /// POST /savings-pots
  Future<SavingsPot> create({
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String currency = 'USDC',
  }) async {
    final response = await _dio.post(
      '/savings-pots',
      data: {
        'name': name,
        'targetAmount': targetAmount,
        'currency': currency,
        if (targetDate != null) 'targetDate': targetDate.toIso8601String(),
      },
    );
    return SavingsPot.fromJson(_extractSavingsPot(response.data));
  }

  /// POST /savings-pots/:id/deposit
  Future<SavingsPot> deposit(
    String potId,
    double amount, {
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
    return SavingsPot.fromJson(_extractSavingsPot(response.data));
  }

  /// POST /savings-pots/:id/withdraw
  Future<SavingsPot> withdraw(
    String potId,
    double amount, {
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
    return SavingsPot.fromJson(_extractSavingsPot(response.data));
  }

  /// POST /savings-pots/:id/withdraw-all
  Future<SavingsPot> withdrawAll(
    String potId, {
    required String pinToken,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/savings-pots/$potId/withdraw-all',
      options: Options(
        headers: transactionHeaders(
          pinToken: pinToken,
          idempotencyKey: idempotencyKey,
        ),
      ),
    );
    return SavingsPot.fromJson(_extractSavingsPot(response.data));
  }

  /// DELETE /savings-pots/:id
  Future<void> delete(String potId) async {
    await _dio.delete('/savings-pots/$potId');
  }

  // Aliases used by views
  Future<bool> createPot({
    String? name,
    String? emoji,
    String? color,
    double? targetAmount,
    Map<String, dynamic>? data,
  }) async {
    await create(
      name: data?['name'] as String? ?? name ?? '',
      targetAmount:
          (data?['targetAmount'] as num?)?.toDouble() ?? targetAmount ?? 0,
    );
    return true;
  }

  Future<void> deletePot(String potId) => delete(potId);
  Future<SavingsPot> update({
    required String id,
    String? name,
    String? emoji,
    String? color,
    double? targetAmount,
    Map<String, dynamic>? data,
  }) async {
    final payload = data ?? {'name': name, 'targetAmount': targetAmount};
    final response = await _dio.put('/savings-pots/$id', data: payload);
    return SavingsPot.fromJson(_extractSavingsPot(response.data));
  }

  Future<bool> updatePot({
    String? id,
    String? name,
    String? emoji,
    String? color,
    double? targetAmount,
    Map<String, dynamic>? data,
  }) async {
    await update(
      id: id ?? '',
      name: name,
      emoji: emoji,
      color: color,
      targetAmount: targetAmount,
      data: data,
    );
    return true;
  }

  Future<SavingsPot> addToPot(
    String potId,
    double amount, {
    required String pinToken,
    required String idempotencyKey,
  }) => deposit(
    potId,
    amount,
    pinToken: pinToken,
    idempotencyKey: idempotencyKey,
  );
  Future<SavingsPot> withdrawFromPot(
    String potId,
    double amount, {
    required String pinToken,
    required String idempotencyKey,
  }) => withdraw(
    potId,
    amount,
    pinToken: pinToken,
    idempotencyKey: idempotencyKey,
  );
  Future<List<SavingsPot>> loadPots() => getAll();
  void selectPot(String? potId) {}
}

List<dynamic> _extractSavingsPotList(Object? data) {
  if (data is List<dynamic>) return data;
  if (data is Map) {
    for (final key in const ['data', 'pots', 'items']) {
      final value = data[key];
      if (value is List<dynamic>) return value;
    }
  }
  return const [];
}

Map<String, dynamic> _extractSavingsPot(Object? data) {
  final value = data is Map ? (data['pot'] ?? data['data'] ?? data) : data;
  return _asStringMap(value);
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected savings pot JSON object');
}

final savingsPotsServiceProvider = Provider<SavingsPotsService>((ref) {
  return SavingsPotsService(ref.watch(dioProvider));
});
