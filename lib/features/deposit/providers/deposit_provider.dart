import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/deposit/deposit_service.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_request.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';

/// Deposit Service Provider
final depositServiceProvider = Provider<DepositService>((ref) {
  final dio = ref.watch(dioProvider);
  return DepositService(dio);
});

/// Deposit Flow Steps
enum DepositFlowStep {
  selectProvider,
  enterAmount,
  instructions,  // OTP entry / Push waiting / QR display
  processing,
  completed,
  failed,
}

/// Deposit State
class DepositState {
  final bool isLoading;
  final String? error;
  final DepositResponse? response;
  final double amountXOF;
  final double amountUSD;
  final MobileMoneyProvider? selectedProvider;
  final DepositFlowStep step;
  final String? otpInput;
  final Timer? statusPollTimer;

  const DepositState({
    this.isLoading = false,
    this.error,
    this.response,
    this.amountXOF = 0,
    this.amountUSD = 0,
    this.selectedProvider,
    this.step = DepositFlowStep.selectProvider,
    this.otpInput,
    this.statusPollTimer,
  });

  DepositState copyWith({
    bool? isLoading,
    String? error,
    DepositResponse? response,
    double? amountXOF,
    double? amountUSD,
    MobileMoneyProvider? selectedProvider,
    DepositFlowStep? step,
    String? otpInput,
    Timer? statusPollTimer,
    bool clearError = false,
    bool clearTimer = false,
  }) {
    return DepositState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      response: response ?? this.response,
      amountXOF: amountXOF ?? this.amountXOF,
      amountUSD: amountUSD ?? this.amountUSD,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      step: step ?? this.step,
      otpInput: otpInput ?? this.otpInput,
      statusPollTimer: clearTimer ? null : (statusPollTimer ?? this.statusPollTimer),
    );
  }

  /// Whether the current flow step needs an OTP input
  bool get needsOtpInput =>
      response?.paymentMethodType == PaymentMethodType.otp &&
      step == DepositFlowStep.instructions;

  /// Whether the current flow step shows a push waiting screen
  bool get isPushWaiting =>
      response?.paymentMethodType == PaymentMethodType.push &&
      step == DepositFlowStep.instructions;

  /// Whether the current flow step shows QR/link
  bool get isQrLink =>
      response?.paymentMethodType == PaymentMethodType.qrLink &&
      step == DepositFlowStep.instructions;
}

/// Deposit Notifier
class DepositNotifier extends Notifier<DepositState> {
  @override
  DepositState build() => const DepositState();

  /// Select provider
  void selectProvider(MobileMoneyProvider provider) {
    state = state.copyWith(
      selectedProvider: provider,
      step: DepositFlowStep.enterAmount,
      clearError: true,
    );
  }

  /// Set amount in XOF and calculate USD equivalent
  void setAmountXOF(double amount, ExchangeRate rate) {
    state = state.copyWith(
      amountXOF: amount,
      amountUSD: rate.convert(amount),
    );
  }

  /// Set amount in USD and calculate XOF equivalent
  void setAmountUSD(double amount, ExchangeRate rate) {
    state = state.copyWith(
      amountXOF: rate.convertBack(amount),
      amountUSD: amount,
    );
  }

  /// Set OTP input value
  void setOtp(String otp) {
    state = state.copyWith(otpInput: otp);
  }

  /// Initiate deposit — calls POST /deposits/initiate
  Future<void> initiateDeposit() async {
    if (state.selectedProvider == null || state.amountXOF <= 0) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(depositServiceProvider);
      final request = InitiateDepositRequest(
        amount: state.amountXOF,
        currency: 'XOF',
        providerCode: state.selectedProvider!.code,
      );
      final response = await service.initiateDeposit(request);

      state = state.copyWith(
        isLoading: false,
        response: response,
        step: DepositFlowStep.instructions,
      );

      // For PUSH type, start polling immediately
      if (response.paymentMethodType == PaymentMethodType.push) {
        _startStatusPolling();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
    }
  }

  /// Confirm deposit — calls POST /deposits/confirm
  /// For OTP: sends the OTP code
  /// For PUSH: triggers the push notification to user's phone
  /// For QR_LINK: not needed (webhook handles it)
  Future<void> confirmDeposit() async {
    if (state.response == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(depositServiceProvider);
      final request = ConfirmDepositRequest(
        token: state.response!.token,
        otp: state.otpInput,
      );
      final response = await service.confirmDeposit(request);

      if (response.status == DepositStatus.completed) {
        _stopPolling();
        state = state.copyWith(
          isLoading: false,
          response: response,
          step: DepositFlowStep.completed,
        );
      } else if (response.isFailed) {
        _stopPolling();
        state = state.copyWith(
          isLoading: false,
          response: response,
          step: DepositFlowStep.failed,
          error: response.failureReason ?? 'Payment failed',
        );
      } else {
        // Still processing — show processing screen and poll
        state = state.copyWith(
          isLoading: false,
          response: response,
          step: DepositFlowStep.processing,
        );
        _startStatusPolling();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
    }
  }

  /// Poll deposit status (for PUSH and processing states)
  Future<void> checkStatus() async {
    if (state.response == null) return;

    try {
      final service = ref.read(depositServiceProvider);
      final response = await service.getDepositStatus(state.response!.depositId);

      if (response.isCompleted) {
        _stopPolling();
        state = state.copyWith(
          response: response,
          step: DepositFlowStep.completed,
        );
      } else if (response.isFailed) {
        _stopPolling();
        state = state.copyWith(
          response: response,
          step: DepositFlowStep.failed,
          error: response.failureReason ?? 'Payment failed',
        );
      } else {
        state = state.copyWith(response: response);
      }
    } catch (_) {
      // Silently fail polling — don't interrupt the flow
    }
  }

  /// Start polling for status updates (every 3 seconds)
  void _startStatusPolling() {
    _stopPolling();
    final timer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkStatus();
    });
    state = state.copyWith(statusPollTimer: timer);
  }

  /// Stop polling
  void _stopPolling() {
    state.statusPollTimer?.cancel();
    state = state.copyWith(clearTimer: true);
  }

  /// Go back one step
  void goBack() {
    _stopPolling();
    switch (state.step) {
      case DepositFlowStep.enterAmount:
        state = state.copyWith(step: DepositFlowStep.selectProvider);
        break;
      case DepositFlowStep.instructions:
        state = state.copyWith(step: DepositFlowStep.enterAmount);
        break;
      default:
        break;
    }
  }

  /// Reset the entire flow
  void reset() {
    _stopPolling();
    state = const DepositState();
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('DioException')) {
        return 'Network error. Please try again.';
      }
      return msg.replaceAll('Exception: ', '');
    }
    return e.toString();
  }
}

/// Deposit Provider
final depositProvider = NotifierProvider<DepositNotifier, DepositState>(
  DepositNotifier.new,
);

/// Exchange Rate Provider (with caching)
final exchangeRateProvider =
    FutureProvider.autoDispose<ExchangeRate>((ref) async {
  final service = ref.watch(depositServiceProvider);
  return service.getExchangeRate();
});
