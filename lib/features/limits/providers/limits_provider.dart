import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/limit.dart';
import 'package:usdc_wallet/services/limits/limits_service.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

/// User transaction limits provider — wired to LimitsService.
final transactionLimitsProvider = FutureProvider<TransactionLimits>((
  ref,
) async {
  final service = ref.watch(limitsServiceProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());
  return service.getLimits();
});

/// Effective max for next transaction.
final effectiveMaxProvider = Provider<double>((ref) {
  final limits = ref.watch(transactionLimitsProvider).value;
  return limits?.effectiveMax ?? 0;
});

/// Check if a specific amount would exceed limits.
final limitCheckProvider = Provider.family<String?, double>((ref, amount) {
  final limits = ref.watch(transactionLimitsProvider).value;
  return limits?.limitHitBy(amount);
});

/// Operation-aware check for a specific amount.
final operationLimitCheckProvider =
    Provider.family<
      String?,
      ({TransactionLimitOperation operation, double amount})
    >((ref, input) {
      final limits = ref.watch(transactionLimitsProvider).value;
      return limits?.limitHitByFor(input.operation, input.amount);
    });

/// Limits state for UI consumption.
class LimitsState {
  final TransactionLimits? limits;
  final bool isLoading;
  final String? error;

  const LimitsState({this.limits, this.isLoading = false, this.error});

  LimitsState copyWith({
    TransactionLimits? limits,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => LimitsState(
    limits: limits ?? this.limits,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : error,
  );
}

/// Limits notifier.
class LimitsNotifier extends Notifier<LimitsState> {
  @override
  LimitsState build() => const LimitsState();

  Future<void> fetchLimits() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(limitsServiceProvider);
      final limits = await service.getLimits();
      state = state.copyWith(
        limits: limits,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: UserFacingErrors.message(e));
    }
  }
}

/// Main limits provider with notifier for imperative control.
final limitsProvider = NotifierProvider<LimitsNotifier, LimitsState>(
  LimitsNotifier.new,
);
