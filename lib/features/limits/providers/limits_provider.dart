import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/limit.dart';
import '../../../services/api/api_client.dart';

/// User transaction limits provider.
final transactionLimitsProvider =
    FutureProvider<TransactionLimits>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 5), () => link.close());

  final response = await dio.get('/user/limits');
  return TransactionLimits.fromJson(response.data as Map<String, dynamic>);
});

/// Effective max for next transaction.
final effectiveMaxProvider = Provider<double>((ref) {
  final limits = ref.watch(transactionLimitsProvider).valueOrNull;
  return limits?.effectiveMax ?? 0;
});

/// Check if a specific amount would exceed limits.
final limitCheckProvider =
    Provider.family<String?, double>((ref, amount) {
  final limits = ref.watch(transactionLimitsProvider).valueOrNull;
  return limits?.limitHitBy(amount);
});
