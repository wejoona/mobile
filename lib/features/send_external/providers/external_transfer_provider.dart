import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/domain/entities/wallet.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';
import 'package:usdc_wallet/features/limits/utils/money_flow_limit_errors.dart';
import 'package:usdc_wallet/features/send_external/models/external_transfer_request.dart';
import 'package:usdc_wallet/features/send_external/services/external_transfer_service.dart';
import 'package:usdc_wallet/services/app_review/app_review_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/limits/limits_service.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/services/realtime/realtime_service.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';

/// External Transfer State
class ExternalTransferState {
  final bool isLoading;
  final String? error;
  final String? address;
  final AddressValidationResult? addressValidation;
  final double? amount;
  final NetworkOption selectedNetwork;
  final double estimatedFee;
  final double availableBalance;
  final bool isBalanceLoading;
  final bool hasVerifiedBalance;
  final String? balanceError;
  final ExternalTransferResult? result;
  final bool isEstimatingFee;
  final String? pinToken;
  final String? idempotencyKey;
  final String? stepUpChallengeToken;
  final bool isSubmitting;

  const ExternalTransferState({
    this.isLoading = false,
    this.error,
    this.address,
    this.addressValidation,
    this.amount,
    this.selectedNetwork = NetworkOption.polygon,
    this.estimatedFee = 0.0,
    this.availableBalance = 0.0,
    this.isBalanceLoading = false,
    this.hasVerifiedBalance = false,
    this.balanceError,
    this.result,
    this.isEstimatingFee = false,
    this.pinToken,
    this.idempotencyKey,
    this.stepUpChallengeToken,
    this.isSubmitting = false,
  });

  bool get hasValidAddress =>
      address != null && addressValidation?.isValid == true;

  bool get canProceedToAmount => hasValidAddress;

  bool get canProceedToConfirm =>
      hasValidAddress && amount != null && amount! > 0 && hasVerifiedBalance;

  double get total => (amount ?? 0) + estimatedFee;

  bool get hasSufficientBalance =>
      hasVerifiedBalance && availableBalance >= total;

  ExternalTransferState copyWith({
    bool? isLoading,
    String? error,
    String? address,
    AddressValidationResult? addressValidation,
    double? amount,
    NetworkOption? selectedNetwork,
    double? estimatedFee,
    double? availableBalance,
    bool? isBalanceLoading,
    bool? hasVerifiedBalance,
    String? balanceError,
    bool clearBalanceError = false,
    ExternalTransferResult? result,
    bool? isEstimatingFee,
    String? pinToken,
    bool clearPinToken = false,
    String? idempotencyKey,
    bool clearIdempotencyKey = false,
    String? stepUpChallengeToken,
    bool clearStepUpChallengeToken = false,
    bool? isSubmitting,
  }) {
    return ExternalTransferState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      address: address ?? this.address,
      addressValidation: addressValidation ?? this.addressValidation,
      amount: amount ?? this.amount,
      selectedNetwork: selectedNetwork ?? this.selectedNetwork,
      estimatedFee: estimatedFee ?? this.estimatedFee,
      availableBalance: availableBalance ?? this.availableBalance,
      isBalanceLoading: isBalanceLoading ?? this.isBalanceLoading,
      hasVerifiedBalance: hasVerifiedBalance ?? this.hasVerifiedBalance,
      balanceError: clearBalanceError
          ? null
          : balanceError ?? this.balanceError,
      result: result ?? this.result,
      isEstimatingFee: isEstimatingFee ?? this.isEstimatingFee,
      pinToken: clearPinToken ? null : pinToken ?? this.pinToken,
      idempotencyKey: clearIdempotencyKey
          ? null
          : idempotencyKey ?? this.idempotencyKey,
      stepUpChallengeToken: clearStepUpChallengeToken
          ? null
          : stepUpChallengeToken ?? this.stepUpChallengeToken,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  ExternalTransferState clearError() => copyWith(error: null);

  ExternalTransferState reset() => const ExternalTransferState();
}

/// External Transfer Notifier
class ExternalTransferNotifier extends Notifier<ExternalTransferState> {
  @override
  ExternalTransferState build() => const ExternalTransferState();

  /// Load available balance
  Future<void> loadBalance() async {
    state = state.copyWith(
      isBalanceLoading: true,
      hasVerifiedBalance: false,
      clearBalanceError: true,
    );
    try {
      final walletService = ref.read(walletServiceProvider);
      final wallet = await walletService.getBalance();
      // Get total USDC balance from balances list
      final usdcBalance = wallet.balances.firstWhere(
        (b) => b.currency == 'USDC',
        orElse: () => const WalletBalance(
          currency: 'USDC',
          available: 0.0,
          pending: 0.0,
          total: 0.0,
        ),
      );
      state = state.copyWith(
        availableBalance: usdcBalance.available,
        isBalanceLoading: false,
        hasVerifiedBalance: true,
        clearBalanceError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isBalanceLoading: false,
        hasVerifiedBalance: false,
        balanceError: _friendlyExternalBalanceError(e),
      );
    }
  }

  /// Validate and set address
  void setAddress(String address) {
    final service = ref.read(externalTransferServiceProvider);
    final validation = service.validateAddress(address);

    state = state.copyWith(
      address: address,
      addressValidation: validation,
      error: validation.isValid ? null : validation.error,
      clearPinToken: true,
      clearIdempotencyKey: true,
    );
  }

  /// Parse address from QR code
  void setAddressFromQr(String qrData) {
    final service = ref.read(externalTransferServiceProvider);
    final address = service.parseAddressFromQr(qrData);

    if (address != null) {
      setAddress(address);
    } else {
      state = state.copyWith(
        error: 'Invalid QR code. Not a valid wallet address.',
      );
    }
  }

  /// Set transfer amount and estimate fee
  Future<void> setAmount(double amount) async {
    state = state.copyWith(
      amount: amount,
      isEstimatingFee: true,
      clearPinToken: true,
      clearIdempotencyKey: true,
    );
    await _estimateFee();
  }

  /// Set network and estimate fee
  Future<void> setNetwork(NetworkOption network) async {
    state = state.copyWith(
      selectedNetwork: network,
      isEstimatingFee: true,
      clearPinToken: true,
      clearIdempotencyKey: true,
    );
    await _estimateFee();
  }

  /// Estimate transfer fee
  Future<void> _estimateFee() async {
    if (state.amount == null || state.amount! <= 0) {
      state = state.copyWith(estimatedFee: 0.0, isEstimatingFee: false);
      return;
    }

    try {
      final service = ref.read(externalTransferServiceProvider);
      final fee = await service.estimateFee(
        state.amount!,
        state.selectedNetwork,
      );
      state = state.copyWith(estimatedFee: fee, isEstimatingFee: false);
    } catch (e) {
      state = state.copyWith(
        estimatedFee: state.selectedNetwork.estimatedFee,
        isEstimatingFee: false,
      );
    }
  }

  /// Verify PIN and store token for subsequent transfer execution.
  Future<bool> verifyPin(String pin) async {
    if (state.isLoading || state.isSubmitting) {
      return false;
    }

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
      state = state.copyWith(
        isLoading: false,
        error: _friendlyExternalSendError(e),
      );
      return false;
    }
  }

  /// Execute external transfer. Requires verifyPin() to have been called first.
  Future<bool> executeTransfer() async {
    if (!state.canProceedToConfirm) {
      state = state.copyWith(
        error: state.hasVerifiedBalance
            ? 'Invalid transfer details'
            : 'Available balance could not be verified. Please try again.',
      );
      return false;
    }

    if (!state.hasSufficientBalance) {
      state = state.copyWith(error: 'Insufficient balance');
      return false;
    }

    if (state.pinToken == null || state.idempotencyKey == null) {
      state = state.copyWith(error: 'PIN verification required');
      return false;
    }

    if (state.isSubmitting) return false;

    final limitError = await _verifyExternalSendLimitsBeforeSubmission();
    if (limitError != null) {
      state = state.copyWith(error: limitError);
      return false;
    }

    state = state.copyWith(isLoading: true, isSubmitting: true, error: null);
    try {
      final service = ref.read(externalTransferServiceProvider);
      final request = ExternalTransferRequest(
        address: state.address!,
        amount: state.amount!,
        network: state.selectedNetwork,
      );

      final result = await service.sendExternal(
        request,
        pinToken: state.pinToken!,
        idempotencyKey: state.idempotencyKey!,
        stepUpToken: state.stepUpChallengeToken,
      );

      state = state.copyWith(
        isLoading: false,
        isSubmitting: false,
        result: result,
      );

      // Immediately refresh balance + transactions
      ref.read(realtimeServiceProvider).refreshAfterTransaction();

      // Track successful transaction for app review prompt
      final appReviewService = ref.read(appReviewServiceProvider);
      await appReviewService.trackSuccessfulTransaction();

      state = state.copyWith(clearPinToken: true, clearIdempotencyKey: true);
      return true;
    } catch (e) {
      final moneyFlowError = moneyFlowLimitExceptionFromError(
        e,
        operation: TransactionLimitOperation.send,
      );
      state = state.copyWith(
        isLoading: false,
        isSubmitting: false,
        error: moneyFlowError?.message ?? _friendlyExternalSendError(e),
      );
      return false;
    } finally {
      await ref.read(pinServiceProvider).clearPinToken();
      state = state.copyWith(clearPinToken: true, isSubmitting: false);
    }
  }

  Future<String?> _verifyExternalSendLimitsBeforeSubmission() async {
    final amount = state.amount;
    if (amount == null || amount <= 0) {
      return 'Invalid transfer details';
    }

    try {
      final limits = await ref.read(limitsServiceProvider).getLimits();
      final limitHit = limits.limitHitByFor(
        TransactionLimitOperation.send,
        amount,
      );
      if (limitHit == null) {
        return null;
      }
      return moneyFlowLimitErrorFor(
        limitHit,
        limits,
        TransactionLimitOperation.send,
      );
    } catch (_) {
      return 'Unable to verify transfer limits. Please try again.';
    }
  }

  void clearStepUpAuthorization() {
    state = state.copyWith(clearStepUpChallengeToken: true);
  }

  void markStepUpAuthorized(String? challengeToken) {
    final token = challengeToken?.trim();
    if (token == null || token.isEmpty) {
      state = state.copyWith(clearStepUpChallengeToken: true);
      return;
    }

    state = state.copyWith(stepUpChallengeToken: token, error: null);
  }

  /// Reset state (e.g., when starting new transfer)
  void reset() {
    state = state.reset();
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }
}

String _friendlyExternalSendError(Object error) {
  if (error is DioException) {
    return ApiException.fromDioError(error).message;
  }
  if (error is ApiException) {
    return error.message;
  }
  return 'External transfer could not be completed. Please try again.';
}

String _friendlyExternalBalanceError(Object error) {
  if (error is DioException) {
    return ApiException.fromDioError(error).message;
  }
  if (error is ApiException) {
    return error.message;
  }
  return 'Available balance could not be verified. Please try again.';
}

/// External Transfer Provider
final externalTransferProvider =
    NotifierProvider<ExternalTransferNotifier, ExternalTransferState>(
      ExternalTransferNotifier.new,
    );
