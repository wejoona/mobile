import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';

/// State for bulk payment submission with PIN and balance validation.
class BulkSubmitState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? pinToken;
  final String? idempotencyKey;
  final bool isComplete;

  const BulkSubmitState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.pinToken,
    this.idempotencyKey,
    this.isComplete = false,
  });

  BulkSubmitState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? pinToken,
    String? idempotencyKey,
    bool? isComplete,
  }) =>
      BulkSubmitState(
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
        pinToken: pinToken ?? this.pinToken,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        isComplete: isComplete ?? this.isComplete,
      );
}

class BulkSubmitNotifier extends Notifier<BulkSubmitState> {
  @override
  BulkSubmitState build() => const BulkSubmitState();

  /// Validate that the user has sufficient balance for the batch.
  String? validateBalance(BulkBatch batch) {
    final balance = ref.read(availableBalanceProvider);
    if (batch.totalAmount > balance) {
      return 'Insufficient balance. Batch total: ${batch.totalAmount.toStringAsFixed(2)}, '
          'Available: ${balance.toStringAsFixed(2)}';
    }
    return null;
  }

  /// Verify PIN before batch submission.
  Future<bool> verifyPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pinService = ref.read(pinServiceProvider);
      final result = await pinService.verifyPinWithBackend(pin);
      if (result.success && result.pinToken != null) {
        state = state.copyWith(
          isLoading: false,
          pinToken: result.pinToken,
          idempotencyKey: generateIdempotencyKey(),
        );
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        error: result.message ?? 'PIN verification failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Submit the batch. Requires verifyPin() and validateBalance() first.
  Future<bool> submit(BulkBatch batch) async {
    // Balance check
    final balanceError = validateBalance(batch);
    if (balanceError != null) {
      state = state.copyWith(error: balanceError);
      return false;
    }

    if (state.pinToken == null) {
      state = state.copyWith(error: 'PIN verification required');
      return false;
    }

    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final service = ref.read(bulkPaymentsServiceProvider);
      await service.submitBatch(batch);
      state = state.copyWith(isSubmitting: false, isComplete: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  void reset() => state = const BulkSubmitState();
}

final bulkSubmitProvider =
    NotifierProvider<BulkSubmitNotifier, BulkSubmitState>(
  BulkSubmitNotifier.new,
);
