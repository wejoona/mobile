import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/savings_pot.dart';
import 'package:usdc_wallet/services/savings_pots/savings_pots_service.dart';

/// Savings pots list provider — wired to SavingsPotsService (real API with mock fallback via interceptor).
final savingsPotsProvider = FutureProvider<List<SavingsPot>>((ref) async {
  final service = ref.watch(savingsPotsServiceProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 2), () => link.close());
  return service.getAll();
});

/// Single savings pot by ID.
final savingsPotByIdProvider = FutureProvider.family<SavingsPot, String>((ref, id) async {
  final service = ref.watch(savingsPotsServiceProvider);
  return service.getById(id);
});

/// Total savings across all pots.
final totalSavingsProvider = Provider<double>((ref) {
  final pots = ref.watch(savingsPotsProvider).valueOrNull ?? [];
  return pots.fold(0.0, (sum, pot) => sum + pot.currentAmount);
});

/// Savings pot actions — delegates to SavingsPotsService.
final savingsPotsActionsProvider = Provider<SavingsPotsService>((ref) {
  return ref.watch(savingsPotsServiceProvider);
});
