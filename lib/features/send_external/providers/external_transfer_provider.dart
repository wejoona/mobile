import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';
import 'package:usdc_wallet/services/app_review/app_review_service.dart';
import 'package:usdc_wallet/services/realtime/realtime_service.dart';
import 'package:usdc_wallet/domain/entities/wallet.dart';
import 'package:usdc_wallet/features/send_external/services/external_transfer_service.dart';
import 'package:usdc_wallet/features/send_external/models/external_transfer_request.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';

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
  final ExternalTransferResult? result;
  final bool isEstimatingFee;
  final String? pinToken;
  final String? idempotencyKey;
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
    this.result,
    this.isEstimatingFee = false,
    this.pinToken,
    this.idempotencyKey,
    this.isSubmitting = false,
  });

  bool get hasValidAddress =>
      address != null && addressValidation?.isValid == true;

  bool get canProceedToAmount => hasValidAddress;

  bool get canProceedToConfirm =>
      hasValidAddress && amount != null && amount! > 0;

  double get total => (amount ?? 0) + estimatedFee;

  bool get hasSufficientBalance => availableBalance >= total;

  ExternalTransferState copyWith({
    bool? isLoading,
    String? error,
    String? address,
    AddressValidationResult? addressValidation,
    double? amount,
    NetworkOption? selectedNetwork,
    double? estimatedFee,
    double? availableBalance,
    ExternalTransferResult? result,
    bool? isEstimatingFee,
    String? pinToken,
    String? idempotencyKey,
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
      result: result ?? this.result,
      isEstimatingFee: isEstimatingFee ?? this.isEstimatingFee,
      pinToken: pinToken ?? this.pinToken,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
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
      state = state.copyWith(availableBalance: usdcBalance.available);
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
    );
  }

  /// Parse address from QR code
  void setAddressFromQr(String qrData) {
    final service = ref.read(externalTransferServiceProvider);
    final address = service.parseAddressFromQr(qrData);

    if (address != null) {
      setAddress(address);
    } else {
      state = state.copyWith(error: 'Invalid QR code. Not a valid wallet address.');
    }
  }

  /// Set transfer amount and estimate fee
  Future<void> setAmount(double amount) async {
    state = state.copyWith(amount: amount, isEstimatingFee: true);
    await _estimateFee();
  }

  /// Set network and estimate fee
  Future<void> setNetwork(NetworkOption network) async {
    state = state.copyWith(selectedNetwork: network, isEstimatingFee: true);
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
      final fee = await service.estimateFee(state.amount!, state.selectedNetwork);
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

  /// Execute external transfer. Requires verifyPin() to have been called first.
  Future<bool> executeTransfer() async {
    if (!state.canProceedToConfirm) {
      state = state.copyWith(error: 'Invalid transfer details');
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

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
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

/// External Transfer Provider
final externalTransferProvider =
    NotifierProvider<ExternalTransferNotifier, ExternalTransferState>(
  ExternalTransferNotifier.new,
);
