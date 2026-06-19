import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';
import 'package:usdc_wallet/features/limits/utils/money_flow_limit_errors.dart';
import 'package:usdc_wallet/services/realtime/realtime_service.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';
import 'package:usdc_wallet/services/limits/limits_service.dart';
import 'package:usdc_wallet/services/sdk/usdc_wallet_sdk.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart' as auth;
import 'package:usdc_wallet/features/deposit/models/deposit_request.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_channel_id.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';
import 'package:usdc_wallet/features/deposit/models/provider_data.dart';

/// Steps in the deposit flow.
enum DepositFlowStep {
  selectProvider,
  enterAmount,
  instructions,
  processing,
  completed,
  failed,
}

/// Deposit flow state.
class DepositState {
  final bool isLoading;
  final String? error;
  final DepositMethod? selectedMethod;
  final double? amount;
  final double? amountXOF;
  final double? amountUSD;
  final DepositResult? result;
  final DepositResponse? response;
  final String? selectedProviderCode;
  final String? selectedProviderMethodType;
  final String? sourceCurrency;
  final String? sourceCountryCode;
  final String? otpInput;
  final DepositFlowStep step;

  const DepositState({
    this.isLoading = false,
    this.error,
    this.selectedMethod,
    this.amount,
    this.amountXOF,
    this.amountUSD,
    this.result,
    this.response,
    this.selectedProviderCode,
    this.selectedProviderMethodType,
    this.sourceCurrency,
    this.sourceCountryCode,
    this.otpInput,
    this.step = DepositFlowStep.selectProvider,
  });

  DepositState copyWith({
    bool? isLoading,
    String? error,
    DepositMethod? selectedMethod,
    double? amount,
    double? amountXOF,
    double? amountUSD,
    DepositResult? result,
    DepositResponse? response,
    String? selectedProviderCode,
    String? selectedProviderMethodType,
    String? sourceCurrency,
    String? sourceCountryCode,
    String? otpInput,
    DepositFlowStep? step,
  }) => DepositState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    selectedMethod: selectedMethod ?? this.selectedMethod,
    amount: amount ?? this.amount,
    amountXOF: amountXOF ?? this.amountXOF,
    amountUSD: amountUSD ?? this.amountUSD,
    result: result ?? this.result,
    response: response ?? this.response,
    selectedProviderCode: selectedProviderCode ?? this.selectedProviderCode,
    selectedProviderMethodType:
        selectedProviderMethodType ?? this.selectedProviderMethodType,
    sourceCurrency: sourceCurrency ?? this.sourceCurrency,
    sourceCountryCode: sourceCountryCode ?? this.sourceCountryCode,
    otpInput: otpInput ?? this.otpInput,
    step: step ?? this.step,
  );
}

/// Deposit method types.
enum DepositMethod {
  orangeMoney('Orange Money'),
  mtnMomo('MTN MoMo'),
  moovMoney('Moov Money'),
  wave('Wave'),
  bankTransfer('Bank Transfer');

  final String label;
  const DepositMethod(this.label);
}

/// Deposit result.
class DepositResult {
  final String id;
  final String status;
  final String? paymentUrl;
  final String? instructions;
  final String? reference;
  final String? token;
  final String? paymentMethodType;

  const DepositResult({
    required this.id,
    required this.status,
    this.paymentUrl,
    this.instructions,
    this.reference,
    this.token,
    this.paymentMethodType,
  });

  factory DepositResult.fromJson(Map<String, dynamic> json) => DepositResult(
    // Backend returns wallet deposit instructions and status metadata.
    id: json['depositId'] as String? ?? json['id'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    paymentUrl: json['deepLinkUrl'] as String? ?? json['paymentUrl'] as String?,
    instructions: json['instructions'] as String?,
    reference: json['reference'] as String?,
    token: json['token'] as String?,
    paymentMethodType: json['paymentMethodType'] as String?,
  );

  factory DepositResult.fromResponse(DepositResponse response) => DepositResult(
    id: response.transactionId.isNotEmpty
        ? response.transactionId
        : response.depositId,
    status: response.status.value,
    paymentUrl: response.deepLinkUrl,
    instructions: response.instructions,
    reference: response.token,
    token: response.token,
    paymentMethodType: response.paymentMethodType.value,
  );
}

/// Deposit notifier — wired to Dio (mock interceptor handles fallback).
class DepositNotifier extends Notifier<DepositState> {
  Timer? _pollingTimer;
  int _pollAttempts = 0;
  static const int _maxPollAttempts = 60; // ~5 minutes at 5s intervals
  static const Duration _pollInterval = Duration(seconds: 5);

  @override
  DepositState build() {
    ref.onDispose(() => _pollingTimer?.cancel());
    return const DepositState();
  }

  void selectMethod(DepositMethod method) {
    state = state.copyWith(
      selectedMethod: method,
      step: DepositFlowStep.enterAmount,
    );
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount, step: DepositFlowStep.instructions);
  }

  void goBack() {
    switch (state.step) {
      case DepositFlowStep.enterAmount:
        state = state.copyWith(step: DepositFlowStep.selectProvider);
      case DepositFlowStep.instructions:
        state = state.copyWith(step: DepositFlowStep.enterAmount);
      case DepositFlowStep.processing:
        // Cancel polling when user navigates back from processing
        _pollingTimer?.cancel();
        state = state.copyWith(step: DepositFlowStep.enterAmount);
      default:
        break;
    }
  }

  Future<void> initiate() async {
    final sourceCurrency = state.sourceCurrency ?? 'XOF';
    final sourceAmount = sourceCurrency == 'USD'
        ? state.amountUSD
        : state.amountXOF ?? state.amount;
    final providerCode =
        state.selectedProviderCode ??
        (state.selectedMethod == null
            ? null
            : _methodToChannelId(state.selectedMethod!));
    final userState = ref.read(userStateMachineProvider);
    final authState = ref.read(auth.authProvider);
    final phoneNumber =
        userState.phone ?? authState.phone ?? authState.user?.phone;

    if (sourceAmount == null || providerCode == null) return;
    final requiresPhone = _providerRequiresPhone(
      providerCode,
      state.selectedProviderMethodType,
    );
    if (requiresPhone && (phoneNumber == null || phoneNumber.isEmpty)) {
      state = state.copyWith(
        error: 'Phone number is required for mobile money deposit.',
        step: DepositFlowStep.failed,
      );
      return;
    }
    final limitError = await _verifyDepositLimitsBeforeSubmission(
      sourceAmount: sourceAmount,
      sourceCurrency: sourceCurrency,
    );
    if (limitError != null) {
      state = state.copyWith(error: limitError, step: DepositFlowStep.failed);
      return;
    }

    state = state.copyWith(isLoading: true, step: DepositFlowStep.processing);
    try {
      final service = ref.read(depositServiceProvider);
      final response = await service.initiateDeposit(
        InitiateDepositRequest(
          amount: sourceAmount.round(),
          provider: providerCode,
          phoneNumber: phoneNumber ?? '',
          currency: sourceCurrency,
          countryCode: state.sourceCountryCode,
        ),
      );
      final result = DepositResult.fromResponse(response);
      state = state.copyWith(
        isLoading: false,
        result: result,
        response: response,
        step: DepositFlowStep.processing,
      );
      ref
          .read(analyticsServiceProvider)
          .trackDeposit(method: providerCode, success: true);
      // Start polling for status updates
      _startPolling(result.id);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        step: DepositFlowStep.failed,
      );
      ref
          .read(analyticsServiceProvider)
          .trackDeposit(
            method: state.selectedMethod?.name ?? 'unknown',
            success: false,
          );
    }
  }

  void setAmountXOF(double amount, [dynamic rate, String? countryCode]) {
    final converted = rate is ExchangeRate ? rate.convert(amount) : null;
    state = state.copyWith(
      amount: amount,
      amountXOF: amount,
      amountUSD: converted,
      sourceCurrency: 'XOF',
      sourceCountryCode: countryCode,
    );
  }

  void setAmountUSD(double amount, [dynamic rate, String? countryCode]) {
    final converted = rate is ExchangeRate ? rate.convertBack(amount) : null;
    state = state.copyWith(
      amount: converted ?? amount,
      amountXOF: converted,
      amountUSD: amount,
      sourceCurrency: 'USD',
      sourceCountryCode: countryCode,
    );
  }

  /// Start polling for deposit status after initiation
  void _startPolling(String depositId) {
    _pollAttempts = 0;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      _pollInterval,
      (_) => _pollStatus(depositId),
    );
  }

  /// Poll the backend for deposit status
  Future<void> _pollStatus(String depositId) async {
    _pollAttempts++;
    if (_pollAttempts > _maxPollAttempts) {
      _pollingTimer?.cancel();
      state = state.copyWith(
        error:
            'Deposit status check timed out. Please check your transaction history.',
        step: DepositFlowStep.failed,
      );
      return;
    }

    try {
      final service = ref.read(depositServiceProvider);
      final response = await service.getDepositStatus(depositId);
      final status = response.status;

      state = state.copyWith(response: response);

      if (status == DepositStatus.completed) {
        _pollingTimer?.cancel();
        state = state.copyWith(
          result: DepositResult.fromResponse(response),
          step: DepositFlowStep.completed,
        );
        // Immediately refresh balance + transactions
        ref.read(realtimeServiceProvider).refreshAfterTransaction();
      } else if (status == DepositStatus.failed ||
          status == DepositStatus.expired) {
        _pollingTimer?.cancel();
        state = state.copyWith(
          error: response.failureReason ?? 'Deposit failed',
          step: DepositFlowStep.failed,
        );
      }
      // else: still pending, continue polling
    } catch (e) {
      debugPrint('Deposit status poll error: $e');
      // Don't stop polling on transient errors
    }
  }

  Future<void> checkStatus() async {
    final depositId = state.result?.id;
    if (depositId == null) return;
    await _pollStatus(depositId);
  }

  void reset() {
    _pollingTimer?.cancel();
    state = const DepositState();
  }

  void clearError() {
    state = state.copyWith();
  }

  Future<void> initiateDeposit() async => initiate();

  Future<String?> _verifyDepositLimitsBeforeSubmission({
    required double sourceAmount,
    required String sourceCurrency,
  }) async {
    try {
      final limits = await ref.read(limitsServiceProvider).getLimits();
      final limitAmount = _depositAmountForLimitCurrency(
        limits,
        sourceAmount,
        sourceCurrency,
      );
      if (limitAmount == null || limitAmount <= 0) {
        return 'Unable to verify deposit limits. Please refresh the quote.';
      }
      final limitHit = limits.limitHitByFor(
        TransactionLimitOperation.deposit,
        limitAmount,
      );
      if (limitHit == null) {
        return null;
      }
      return moneyFlowLimitErrorFor(
        limitHit,
        limits,
        TransactionLimitOperation.deposit,
      );
    } on DioException {
      return 'Unable to verify deposit limits. Please try again.';
    } on Object {
      return 'Unable to verify deposit limits. Please try again.';
    }
  }

  double? _depositAmountForLimitCurrency(
    TransactionLimits limits,
    double sourceAmount,
    String sourceCurrency,
  ) {
    final limitCurrency = limits.currency.toUpperCase();
    final normalizedSource = sourceCurrency.toUpperCase();
    if (limitCurrency == normalizedSource) {
      return sourceAmount;
    }
    if (limitCurrency == 'USD' || limitCurrency == 'USDC') {
      if (normalizedSource == 'USD' || normalizedSource == 'USDC') {
        return state.amountUSD ?? sourceAmount;
      }
      return state.amountUSD;
    }
    if (limitCurrency == 'XOF') {
      if (normalizedSource == 'XOF') {
        return state.amountXOF ?? sourceAmount;
      }
      return state.amountXOF;
    }
    return null;
  }

  void selectProviderData(dynamic data) {
    final code = normalizeDepositChannelId(
      data is ProviderData ? data.id : data.toString(),
    );
    state = state.copyWith(
      selectedProviderCode: code,
      selectedProviderMethodType: data is ProviderData
          ? data.paymentMethodType ?? data.enumProvider
          : null,
      selectedMethod: _providerCodeToMethod(code),
    );
  }

  void setOtp(String otp) => state = state.copyWith(otpInput: otp);

  /// Map mobile DepositMethod enum to backend channel ids.
  static String _methodToChannelId(DepositMethod method) {
    switch (method) {
      case DepositMethod.orangeMoney:
        return 'orange_money_ci';
      case DepositMethod.mtnMomo:
        return 'mtn_momo_ci';
      case DepositMethod.moovMoney:
        return 'moov_money_ci';
      case DepositMethod.wave:
        return 'wave_ci';
      case DepositMethod.bankTransfer:
        return 'bank_transfer';
    }
  }

  static DepositMethod? _providerCodeToMethod(String code) {
    switch (normalizeDepositChannelId(code)) {
      case 'orange_money_ci':
        return DepositMethod.orangeMoney;
      case 'mtn_momo_ci':
        return DepositMethod.mtnMomo;
      case 'moov_money_ci':
        return DepositMethod.moovMoney;
      case 'wave_ci':
        return DepositMethod.wave;
      default:
        return null;
    }
  }

  static bool _providerRequiresPhone(String providerCode, String? methodType) {
    return depositChannelRequiresPhone(providerCode, methodType);
  }
}

final depositProvider = NotifierProvider<DepositNotifier, DepositState>(
  DepositNotifier.new,
);
