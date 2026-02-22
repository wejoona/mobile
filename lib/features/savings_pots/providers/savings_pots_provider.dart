import 'package:usdc_wallet/features/savings_pots/models/savings_pots_state.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/savings_pot.dart';
import 'package:usdc_wallet/services/savings_pots/savings_pots_service.dart';

/// Savings pots list provider — wired to SavingsPotsService (real API with mock fallback via interceptor).
final savingsPotsProvider = FutureProvider<List<SavingsPot>>((ref) async {
  final service = ref.watch(savingsPotsServiceProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 2), () => link.close());
  ref.onDispose(() => timer.cancel());
  return service.getAll();
});

/// Single savings pot by ID.
final savingsPotByIdProvider = FutureProvider.family<SavingsPot, String>((ref, id) async {
  final service = ref.watch(savingsPotsServiceProvider);
  return service.getById(id);
});

/// Total savings across all pots.
final totalSavingsProvider = Provider<double>((ref) {
  final pots = ref.watch(savingsPotsProvider).value ?? [];
  return pots.fold(0.0, (sum, pot) => sum + pot.currentAmount);
});

/// Savings pot actions — delegates to SavingsPotsService.
final savingsPotsActionsProvider = Provider<SavingsPotsService>((ref) {
  return ref.watch(savingsPotsServiceProvider);
});

/// Adapter: wraps raw list into SavingsPotsState for views.
final savingsPotsStateProvider = Provider<SavingsPotsState>((ref) {
  final async = ref.watch(savingsPotsProvider);
  return SavingsPotsState(
    isLoading: async.isLoading,
    error: async.error?.toString(),
    pots: async.value ?? <SavingsPot>[],
    totalSaved: (async.value ?? []).fold(0.0, (sum, p) => sum + p.currentAmount),
  );
});
