import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';
import 'package:usdc_wallet/features/deposit/models/provider_data.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/realtime/realtime_service.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';

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
  final String? selectedProviderCode;
  final String? selectedProviderName;
  final double? amount;
  final double? amountXOF;
  final double? amountUSD;
  final DepositResult? result;
  final Map<String, dynamic>? response;
  final String? otpInput;
  final DepositFlowStep step;

  const DepositState({
    this.isLoading = false,
    this.error,
    this.selectedMethod,
    this.selectedProviderCode,
    this.selectedProviderName,
    this.amount,
    this.amountXOF,
    this.amountUSD,
    this.result,
    this.response,
    this.otpInput,
    this.step = DepositFlowStep.selectProvider,
  });

  DepositState copyWith({
    bool? isLoading,
    String? error,
    DepositMethod? selectedMethod,
    String? selectedProviderCode,
    String? selectedProviderName,
    double? amount,
    double? amountXOF,
    double? amountUSD,
    DepositResult? result,
    Map<String, dynamic>? response,
    String? otpInput,
    DepositFlowStep? step,
  }) => DepositState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    selectedMethod: selectedMethod ?? this.selectedMethod,
    selectedProviderCode: selectedProviderCode ?? this.selectedProviderCode,
    selectedProviderName: selectedProviderName ?? this.selectedProviderName,
    amount: amount ?? this.amount,
    amountXOF: amountXOF ?? this.amountXOF,
    amountUSD: amountUSD ?? this.amountUSD,
    result: result ?? this.result,
    response: response ?? this.response,
    otpInput: otpInput ?? this.otpInput,
    step: step ?? this.step,
  );
}

/// Deposit method types.
enum DepositMethod {
  orangeMoney('Orange Money', '+225 07'),
  mtnMomo('MTN MoMo', '+225 05'),
  moovMoney('Moov Money', '+225 01'),
  wave('Wave', '+225'),
  bankTransfer('Bank Transfer', '');

  final String label;
  final String prefix;
  const DepositMethod(this.label, this.prefix);
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
    // Backend returns { depositId, token, paymentMethodType, instructions, expiresAt }
    id: json['depositId'] as String? ?? json['id'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    paymentUrl: json['deepLinkUrl'] as String? ?? json['paymentUrl'] as String?,
    instructions: json['instructions'] as String?,
    reference: json['reference'] as String?,
    token: json['token'] as String?,
    paymentMethodType: json['paymentMethodType'] as String?,
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
    final amount = state.amountXOF ?? state.amount;
    if ((state.selectedMethod == null && state.selectedProviderCode == null) ||
        amount == null) {
      return;
    }
    state = state.copyWith(isLoading: true, step: DepositFlowStep.processing);
    try {
      final dio = ref.read(dioProvider);
      // Map mobile deposit method to backend provider codes
      final providerCode =
          state.selectedProviderCode ??
          _methodToProviderCode(state.selectedMethod!);
      if (providerCode == 'BANK') {
        state = state.copyWith(
          isLoading: false,
          error: 'Bank transfer deposits are not available yet.',
          step: DepositFlowStep.failed,
        );
        return;
      }

      final response = await dio.post(
        '/deposits/initiate',
        data: {
          'amount': amount.round(),
          'currency': 'XOF',
          'providerCode': providerCode,
        },
        options: Options(
          headers: {'X-Idempotency-Key': _idempotencyKey('deposit-initiate')},
        ),
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final deposit = DepositResponse.fromJson({
        ...data,
        'amount': data['amount'] ?? amount,
        'currency': data['currency'] ?? 'XOF',
        'providerCode': data['providerCode'] ?? providerCode,
      });
      final result = DepositResult.fromJson(data);
      state = state.copyWith(
        isLoading: false,
        result: result,
        response: _toInstructionMap(deposit),
        step: DepositFlowStep.instructions,
      );
      ref
          .read(analyticsServiceProvider)
          .trackDeposit(
            method:
                state.selectedProviderCode ??
                state.selectedMethod?.name ??
                'unknown',
            success: true,
          );

      if (deposit.paymentMethodType.isAsyncConfirmation ||
          deposit.paymentMethodType.hasQrOrLink) {
        _startPolling(result.id);
      }
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

  void setAmountXOF(double amount, [dynamic rate]) {
    final amountUSD = rate is ExchangeRate
        ? rate.convert(amount)
        : state.amountUSD;
    state = state.copyWith(
      amount: amount,
      amountXOF: amount,
      amountUSD: amountUSD,
      step: DepositFlowStep.selectProvider,
    );
  }

  void setAmountUSD(double amount, [dynamic rate]) {
    final amountXOF = rate is ExchangeRate
        ? rate.convertBack(amount)
        : state.amountXOF;
    state = state.copyWith(
      amount: amountXOF ?? amount,
      amountXOF: amountXOF,
      amountUSD: amount,
      step: DepositFlowStep.selectProvider,
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
      final dio = ref.read(dioProvider);
      final response = await dio.get('/deposits/$depositId');
      final data = Map<String, dynamic>.from(response.data as Map);
      final status = data['status'] as String?;

      if (status == 'completed' || status == 'settled') {
        _pollingTimer?.cancel();
        final deposit = DepositResponse.fromJson({
          ...data,
          'depositId': data['depositId'] ?? data['id'] ?? depositId,
          'expiresAt': data['expiresAt'],
        });
        state = state.copyWith(
          result: DepositResult.fromJson(data),
          response: _toInstructionMap(deposit),
          step: DepositFlowStep.completed,
        );
        // Immediately refresh balance + transactions
        ref.read(realtimeServiceProvider).refreshAfterTransaction();
      } else if (status == 'failed' || status == 'cancelled') {
        _pollingTimer?.cancel();
        state = state.copyWith(
          error: data['message'] as String? ?? 'Deposit failed',
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

  // === Stub methods for views ===
  Future<void> confirmDeposit() async {
    final token = state.result?.token ?? state.response?['token'] as String?;
    if (token == null || token.isEmpty) return;

    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/deposits/confirm',
        data: {
          'token': token,
          if ((state.otpInput ?? '').isNotEmpty) 'otp': state.otpInput,
        },
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final depositId =
          data['depositId'] as String? ??
          data['id'] as String? ??
          state.result?.id ??
          '';
      final status = data['status'] as String? ?? 'processing';
      final currentPaymentMethodType = state.response?['paymentMethodType'];
      final paymentMethodType = currentPaymentMethodType is PaymentMethodType
          ? currentPaymentMethodType.value
          : currentPaymentMethodType as String?;
      final currentExpiresAt = state.response?['expiresAt'];
      final expiresAt = currentExpiresAt is DateTime
          ? currentExpiresAt.toIso8601String()
          : currentExpiresAt as String?;
      final deposit = DepositResponse.fromJson({
        ...data,
        'depositId': depositId,
        'token': token,
        'paymentMethodType': data['paymentMethodType'] ?? paymentMethodType,
        'instructions': data['instructions'] ?? state.response?['instructions'],
        'expiresAt': data['expiresAt'] ?? expiresAt,
      });
      final nextStep = (status == 'completed' || status == 'settled')
          ? DepositFlowStep.completed
          : status == 'failed' || status == 'cancelled'
          ? DepositFlowStep.failed
          : DepositFlowStep.processing;

      state = state.copyWith(
        isLoading: false,
        result: DepositResult.fromJson({
          ...data,
          'depositId': depositId,
          'token': token,
        }),
        response: _toInstructionMap(deposit),
        error: nextStep == DepositFlowStep.failed
            ? data['failureReason'] as String? ?? 'Deposit failed'
            : null,
        step: nextStep,
      );

      if (nextStep == DepositFlowStep.completed) {
        ref.read(realtimeServiceProvider).refreshAfterTransaction();
      } else if (nextStep == DepositFlowStep.processing &&
          depositId.isNotEmpty) {
        _startPolling(depositId);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        step: DepositFlowStep.failed,
      );
    }
  }

  Future<void> initiateDeposit() async => initiate();
  void selectProviderData(dynamic data) {
    final provider = data is ProviderData
        ? data
        : data is Map<String, dynamic>
        ? ProviderData(
            id: data['code'] as String? ?? data['id'] as String? ?? '',
            name: data['name'] as String? ?? 'Mobile Money',
            logo: data['logo'] as String?,
            minAmount: (data['minAmount'] as num?)?.toDouble(),
            maxAmount: (data['maxAmount'] as num?)?.toDouble(),
            paymentMethodType: data['paymentMethodType'] as String?,
            enumProvider: data['code'] as String? ?? data['id'] as String?,
          )
        : null;
    if (provider == null) return;

    state = state.copyWith(
      selectedMethod: _methodFromProviderCode(provider.id),
      selectedProviderCode: provider.id,
      selectedProviderName: provider.name,
    );
  }

  void setOtp(String otp) => state = state.copyWith(otpInput: otp);

  /// Map mobile DepositMethod enum to backend provider codes.
  static String _methodToProviderCode(DepositMethod method) {
    switch (method) {
      case DepositMethod.orangeMoney:
        return 'OMCI';
      case DepositMethod.mtnMomo:
        return 'MTNCI';
      case DepositMethod.moovMoney:
        return 'MOOVCI';
      case DepositMethod.wave:
        return 'WAVECI';
      case DepositMethod.bankTransfer:
        return 'BANK';
    }
  }

  static DepositMethod? _methodFromProviderCode(String code) {
    switch (code.toUpperCase()) {
      case 'OMCI':
        return DepositMethod.orangeMoney;
      case 'MTNCI':
        return DepositMethod.mtnMomo;
      case 'MOOVCI':
        return DepositMethod.moovMoney;
      case 'WAVECI':
        return DepositMethod.wave;
      default:
        return null;
    }
  }

  static Map<String, dynamic> _toInstructionMap(DepositResponse response) {
    return {
      'depositId': response.depositId,
      'token': response.token,
      'paymentMethodType': response.paymentMethodType,
      'instructions': response.instructions,
      'qrCodeData': response.qrCodeData,
      'deepLinkUrl': response.deepLinkUrl,
      'expiresAt': response.expiresAt,
      'status': response.status.value,
      'amount': response.amount,
      'currency': response.currency,
      'convertedAmount': response.convertedAmount,
      'convertedCurrency': response.convertedCurrency,
      'providerCode': response.providerCode,
      'failureReason': response.failureReason,
    };
  }

  static String _idempotencyKey(String prefix) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return '$prefix-$timestamp';
  }
}

final depositProvider = NotifierProvider<DepositNotifier, DepositState>(
  DepositNotifier.new,
);
