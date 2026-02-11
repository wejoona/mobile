import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/savings_pot.dart';
import '../../../services/api/api_client.dart';

/// Savings pots list provider.
final savingsPotsProvider = FutureProvider<List<SavingsPot>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 2), () => link.close());

  final response = await dio.get('/savings-pots');
  final data = response.data as Map<String, dynamic>;
  final items = data['data'] as List? ?? [];
  return items
      .map((e) => SavingsPot.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Total savings across all pots.
final totalSavingsProvider = Provider<double>((ref) {
  final pots = ref.watch(savingsPotsProvider).valueOrNull ?? [];
  return pots.fold(0.0, (sum, pot) => sum + pot.currentAmount);
});

/// Create savings pot action.
class SavingsPotsActions {
  final Dio _dio;

  SavingsPotsActions(this._dio);

  Future<SavingsPot> create({
    required String name,
    required double targetAmount,
    DateTime? targetDate,
  }) async {
    final response = await _dio.post('/savings-pots', data: {
      'name': name,
      'targetAmount': targetAmount,
      if (targetDate != null) 'targetDate': targetDate.toIso8601String(),
    });
    return SavingsPot.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deposit(String potId, double amount) async {
    await _dio.post('/savings-pots/$potId/deposit', data: {
      'amount': amount,
    });
  }

  Future<void> withdraw(String potId, double amount) async {
    await _dio.post('/savings-pots/$potId/withdraw', data: {
      'amount': amount,
    });
  }

  Future<void> delete(String potId) async {
    await _dio.delete('/savings-pots/$potId');
  }
}

final savingsPotsActionsProvider = Provider<SavingsPotsActions>((ref) {
  return SavingsPotsActions(ref.watch(dioProvider));
});
