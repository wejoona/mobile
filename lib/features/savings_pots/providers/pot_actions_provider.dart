import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/savings_pots/savings_pots_service.dart';
import 'savings_pots_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';

/// Savings pot deposit/withdraw state.
class PotActionState {
  final bool isLoading;
  final String? error;
  final bool isComplete;

  const PotActionState({this.isLoading = false, this.error, this.isComplete = false});

  PotActionState copyWith({bool? isLoading, String? error, bool? isComplete}) => PotActionState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isComplete: isComplete ?? this.isComplete,
  );
}

/// Pot actions notifier (deposit/withdraw/delete for a specific pot).
class PotActionsNotifier extends Notifier<PotActionState> {
  @override
  PotActionState build() => const PotActionState();

  Future<void> deposit(String potId, double amount) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(savingsPotsServiceProvider);
      await service.deposit(potId, amount);
      state = state.copyWith(isLoading: false, isComplete: true);
      ref.invalidate(savingsPotsProvider);
      ref.invalidate(walletBalanceProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> withdraw(String potId, double amount) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(savingsPotsServiceProvider);
      await service.withdraw(potId, amount);
      state = state.copyWith(isLoading: false, isComplete: true);
      ref.invalidate(savingsPotsProvider);
      ref.invalidate(walletBalanceProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> withdrawAll(String potId) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(savingsPotsServiceProvider);
      await service.withdrawAll(potId);
      state = state.copyWith(isLoading: false, isComplete: true);
      ref.invalidate(savingsPotsProvider);
      ref.invalidate(walletBalanceProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deletePot(String potId) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(savingsPotsServiceProvider);
      await service.delete(potId);
      state = state.copyWith(isLoading: false, isComplete: true);
      ref.invalidate(savingsPotsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const PotActionState();
}

final potActionsProvider = NotifierProvider<PotActionsNotifier, PotActionState>(PotActionsNotifier.new);
