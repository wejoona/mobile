import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/sdk/usdc_wallet_sdk.dart';
import '../models/transaction_limits.dart';

// State
class LimitsState {
  final bool isLoading;
  final String? error;
  final TransactionLimits? limits;

  const LimitsState({
    this.isLoading = false,
    this.error,
    this.limits,
  });

  LimitsState copyWith({
    bool? isLoading,
    String? error,
    TransactionLimits? limits,
  }) {
    return LimitsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      limits: limits ?? this.limits,
    );
  }
}

// Notifier
class LimitsNotifier extends Notifier<LimitsState> {
  @override
  LimitsState build() => const LimitsState();

  Future<void> fetchLimits() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sdk = ref.read(sdkProvider);
      final limits = await sdk.wallet.getTransactionLimits();
      state = state.copyWith(isLoading: false, limits: limits);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refresh() {
    fetchLimits();
  }
}

// Provider
final limitsProvider = NotifierProvider<LimitsNotifier, LimitsState>(
  LimitsNotifier.new,
);
