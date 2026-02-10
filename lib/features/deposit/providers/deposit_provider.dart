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

/// Provider Data (from API response)
class ProviderData {
  final String code;
  final String name;
  final PaymentMethodType paymentMethodType;
  final String? logoUrl;
  final bool isActive;

  const ProviderData({
    required this.code,
    required this.name,
    required this.paymentMethodType,
    this.logoUrl,
    this.isActive = true,
  });

  factory ProviderData.fromJson(Map<String, dynamic> json) {
    return ProviderData(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      paymentMethodType: PaymentMethodTypeExt.fromString(
        json['paymentMethodType'] as String? ?? 'PUSH',
      ),
      logoUrl: json['logoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert to enum if available
  MobileMoneyProvider? get enumProvider => MobileMoneyProviderExt.fromCode(code);
}

/// Deposit State
class DepositState {
  final bool isLoading;
  final String? error;
  final DepositResponse? response;
  final double amountXOF;
  final double amountUSD;
  final MobileMoneyProvider? selectedProvider;
  final ProviderData? selectedProviderData;
  final List<ProviderData> availableProviders;
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
    this.selectedProviderData,
    this.availableProviders = const [],
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
    ProviderData? selectedProviderData,
    List<ProviderData>? availableProviders,
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
      selectedProviderData: selectedProviderData ?? this.selectedProviderData,
      availableProviders: availableProviders ?? this.availableProviders,
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

  /// Load available providers from API
  Future<void> loadProviders() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(depositServiceProvider);
      final providerMaps = await service.getProviders();
      
      final providers = providerMaps
          .map((map) => ProviderData.fromJson(map))
          .where((p) => p.isActive)
          .toList();

      state = state.copyWith(
        isLoading: false,
        availableProviders: providers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
    }
  }

  /// Select provider (using ProviderData from API)
  void selectProviderData(ProviderData providerData) {
    state = state.copyWith(
      selectedProviderData: providerData,
      selectedProvider: providerData.enumProvider, // For backward compatibility
      step: DepositFlowStep.enterAmount,
      clearError: true,
    );
  }

  /// Legacy method - select provider by enum
  void selectProvider(MobileMoneyProvider provider) {
    // Find the matching provider data if available
    final matchingProviders = state.availableProviders
        .where((p) => p.enumProvider == provider);
    final providerData = matchingProviders.isNotEmpty ? matchingProviders.first : null;
    
    state = state.copyWith(
      selectedProvider: provider,
      selectedProviderData: providerData,
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
    final providerCode = state.selectedProviderData?.code ?? state.selectedProvider?.code;
    if (providerCode == null || state.amountXOF <= 0) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(depositServiceProvider);
      final request = InitiateDepositRequest(
        amount: state.amountXOF,
        currency: 'XOF',
        providerCode: providerCode,
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

/// Providers List Provider
final providersListProvider = FutureProvider.autoDispose<List<ProviderData>>((ref) async {
  final service = ref.read(depositServiceProvider);
  final providerMaps = await service.getProviders();
  
  return providerMaps
      .map((map) => ProviderData.fromJson(map))
      .where((p) => p.isActive)
      .toList();
});
