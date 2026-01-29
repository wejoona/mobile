import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';
import '../../../services/deposit/deposit_service.dart';
import '../models/deposit_request.dart';
import '../models/deposit_response.dart';
import '../models/exchange_rate.dart';

/// Deposit Service Provider
final depositServiceProvider = Provider<DepositService>((ref) {
  final dio = ref.watch(dioProvider);
  return DepositService(dio);
});

/// Deposit State
class DepositState {
  final bool isLoading;
  final String? error;
  final DepositResponse? response;
  final double amountXOF;
  final double amountUSD;
  final String selectedProvider;
  final DepositFlowStep step;

  const DepositState({
    this.isLoading = false,
    this.error,
    this.response,
    this.amountXOF = 0,
    this.amountUSD = 0,
    this.selectedProvider = '',
    this.step = DepositFlowStep.amount,
  });

  DepositState copyWith({
    bool? isLoading,
    String? error,
    DepositResponse? response,
    double? amountXOF,
    double? amountUSD,
    String? selectedProvider,
    DepositFlowStep? step,
  }) {
    return DepositState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      response: response ?? this.response,
      amountXOF: amountXOF ?? this.amountXOF,
      amountUSD: amountUSD ?? this.amountUSD,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      step: step ?? this.step,
    );
  }
}

enum DepositFlowStep {
  amount,
  provider,
  instructions,
  processing,
  completed,
}

/// Deposit Notifier
class DepositNotifier extends Notifier<DepositState> {
  @override
  DepositState build() => const DepositState();

  /// Set amount in XOF
  void setAmountXOF(double amount, ExchangeRate rate) {
    state = state.copyWith(
      amountXOF: amount,
      amountUSD: rate.convert(amount),
    );
  }

  /// Set amount in USD
  void setAmountUSD(double amount, ExchangeRate rate) {
    state = state.copyWith(
      amountXOF: rate.convertBack(amount),
      amountUSD: amount,
    );
  }

  /// Set selected provider
  void setProvider(String provider) {
    state = state.copyWith(selectedProvider: provider);
  }

  /// Move to next step
  void nextStep() {
    final currentIndex = DepositFlowStep.values.indexOf(state.step);
    if (currentIndex < DepositFlowStep.values.length - 1) {
      state = state.copyWith(
        step: DepositFlowStep.values[currentIndex + 1],
      );
    }
  }

  /// Move to previous step
  void previousStep() {
    final currentIndex = DepositFlowStep.values.indexOf(state.step);
    if (currentIndex > 0) {
      state = state.copyWith(
        step: DepositFlowStep.values[currentIndex - 1],
      );
    }
  }

  /// Initiate deposit
  Future<void> initiateDeposit() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(depositServiceProvider);
      final request = DepositRequest(
        amount: state.amountXOF,
        currency: 'XOF',
        provider: state.selectedProvider,
      );
      final response = await service.initiateDeposit(request);
      state = state.copyWith(
        isLoading: false,
        response: response,
        step: DepositFlowStep.instructions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Check deposit status
  Future<void> checkStatus() async {
    if (state.response == null) return;

    try {
      final service = ref.read(depositServiceProvider);
      final response = await service.getDepositStatus(state.response!.depositId);
      state = state.copyWith(response: response);

      if (response.status == DepositStatus.completed) {
        state = state.copyWith(step: DepositFlowStep.completed);
      } else if (response.status == DepositStatus.failed ||
          response.status == DepositStatus.expired) {
        state = state.copyWith(
          error: 'Deposit ${response.status.value}',
        );
      }
    } catch (e) {
      // Silently fail status checks (don't interrupt the flow)
    }
  }

  /// Reset state
  void reset() {
    state = const DepositState();
  }
}

/// Deposit Provider
final depositProvider = NotifierProvider<DepositNotifier, DepositState>(
  DepositNotifier.new,
);

/// Exchange Rate Provider (with caching)
final exchangeRateProvider = FutureProvider.autoDispose<ExchangeRate>((ref) async {
  final service = ref.watch(depositServiceProvider);
  return service.getExchangeRate();
});
