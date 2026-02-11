import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/limit.dart';
import 'package:usdc_wallet/services/limits/limits_service.dart';

/// User transaction limits provider — wired to LimitsService.
final transactionLimitsProvider = FutureProvider<TransactionLimits>((ref) async {
  final service = ref.watch(limitsServiceProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () => link.close());
  return service.getLimits();
});

/// Effective max for next transaction.
final effectiveMaxProvider = Provider<double>((ref) {
  final limits = ref.watch(transactionLimitsProvider).valueOrNull;
  return limits?.effectiveMax ?? 0;
});

/// Check if a specific amount would exceed limits.
final limitCheckProvider = Provider.family<String?, double>((ref, amount) {
  final limits = ref.watch(transactionLimitsProvider).valueOrNull;
  return limits?.limitHitBy(amount);
});
