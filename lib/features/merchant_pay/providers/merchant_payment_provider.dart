import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';

/// Merchant payment state.
class MerchantPaymentState {
  final bool isScanning;
  final bool isProcessing;
  final String? error;
  final MerchantInfo? merchant;
  final double? amount;
  final String? reference;
  final bool isComplete;

  const MerchantPaymentState({
    this.isScanning = true,
    this.isProcessing = false,
    this.error,
    this.merchant,
    this.amount,
    this.reference,
    this.isComplete = false,
  });

  MerchantPaymentState copyWith({
    bool? isScanning, bool? isProcessing, String? error,
    MerchantInfo? merchant, double? amount, String? reference, bool? isComplete,
  }) => MerchantPaymentState(
    isScanning: isScanning ?? this.isScanning,
    isProcessing: isProcessing ?? this.isProcessing,
    error: error,
    merchant: merchant ?? this.merchant,
    amount: amount ?? this.amount,
    reference: reference ?? this.reference,
    isComplete: isComplete ?? this.isComplete,
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

  Future<void> pay({String? pin}) async {
    if (state.merchant == null || state.amount == null) return;
    state = state.copyWith(isProcessing: true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/payments/merchant', data: {
        'merchantId': state.merchant!.id,
        'amount': state.amount,
        'currency': 'USDC',
        if (state.reference != null) 'reference': state.reference,
        if (pin != null) 'pin': pin,
      });
      state = state.copyWith(isProcessing: false, isComplete: true);
      ref.invalidate(walletBalanceProvider);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  void reset() => state = const MerchantPaymentState();
}

final merchantPaymentProvider = NotifierProvider<MerchantPaymentNotifier, MerchantPaymentState>(MerchantPaymentNotifier.new);
