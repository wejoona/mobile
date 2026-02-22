import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/core/utils/amount_conversion.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';

/// Merchant payment state.
class MerchantPaymentState {
  final bool isScanning;
  final bool isProcessing;
  final String? error;
  final MerchantInfo? merchant;
  final double? amount;
  final String? reference;
  final bool isComplete;
  final String? pinToken;
  final String? idempotencyKey;

  const MerchantPaymentState({
    this.isScanning = true,
    this.isProcessing = false,
    this.error,
    this.merchant,
    this.amount,
    this.reference,
    this.isComplete = false,
    this.pinToken,
    this.idempotencyKey,
  });

  MerchantPaymentState copyWith({
    bool? isScanning, bool? isProcessing, String? error,
    MerchantInfo? merchant, double? amount, String? reference, bool? isComplete,
    String? pinToken, String? idempotencyKey,
  }) => MerchantPaymentState(
    isScanning: isScanning ?? this.isScanning,
    isProcessing: isProcessing ?? this.isProcessing,
    error: error,
    merchant: merchant ?? this.merchant,
    amount: amount ?? this.amount,
    reference: reference ?? this.reference,
    isComplete: isComplete ?? this.isComplete,
    pinToken: pinToken ?? this.pinToken,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
  );
}

/// Merchant info from QR code.
class MerchantInfo {
  final String id;
  final String name;
  final String? logo;

  const MerchantInfo({required this.id, required this.name, this.logo});

  factory MerchantInfo.fromJson(Map<String, dynamic> json) => MerchantInfo(
    id: json['merchantId'] as String? ?? json['id'] as String,
    name: json['merchantName'] as String? ?? json['name'] as String? ?? 'Unknown',
    logo: json['logo'] as String?,
  );
}

/// Merchant payment notifier.
class MerchantPaymentNotifier extends Notifier<MerchantPaymentState> {
  @override
  MerchantPaymentState build() => const MerchantPaymentState();

  void onMerchantScanned(Map<String, dynamic> qrData) {
    final merchant = MerchantInfo.fromJson(qrData);
    final amount = (qrData['amount'] as num?)?.toDouble();
    final reference = qrData['reference'] as String?;
    state = state.copyWith(
      isScanning: false,
      merchant: merchant,
      amount: amount,
      reference: reference,
    );
  }

  void setAmount(double amount) => state = state.copyWith(amount: amount);

  /// Verify PIN before payment.
  Future<bool> verifyPin(String pin) async {
    state = state.copyWith(error: null);
    try {
      final pinService = ref.read(pinServiceProvider);
      final result = await pinService.verifyPinWithBackend(pin);
      if (result.success && result.pinToken != null) {
        state = state.copyWith(
          pinToken: result.pinToken,
          idempotencyKey: generateIdempotencyKey(),
        );
        return true;
      }
      state = state.copyWith(error: result.message ?? 'PIN verification failed');
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Pay merchant. Requires verifyPin() first.
  Future<void> pay() async {
    if (state.merchant == null || state.amount == null) return;
    if (state.pinToken == null || state.idempotencyKey == null) {
      state = state.copyWith(error: 'PIN verification required');
      return;
    }
    if (state.isProcessing) return; // double-submit guard
    state = state.copyWith(isProcessing: true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(
        '/merchants/pay',
        data: {
          'merchantId': state.merchant!.id,
          'amount': toCents(state.amount!),
          'currency': 'USDC',
          if (state.reference != null) 'reference': state.reference,
        },
        options: Options(
          headers: transactionHeaders(
            pinToken: state.pinToken!,
            idempotencyKey: state.idempotencyKey!,
          ),
        ),
      );
      state = state.copyWith(isProcessing: false, isComplete: true);
      ref.invalidate(walletBalanceProvider);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  void reset() => state = const MerchantPaymentState();
}

final merchantPaymentProvider = NotifierProvider<MerchantPaymentNotifier, MerchantPaymentState>(MerchantPaymentNotifier.new);
