import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/qr_payment/models/qr_data.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';

/// QR payment types.
enum QrPaymentType { p2p, merchant, paymentLink }

/// QR payment state.
class QrPaymentState {
  final bool isLoading;
  final String? error;
  final QrPaymentData? scannedData;
  final bool isProcessing;
  final bool isComplete;

  const QrPaymentState({this.isLoading = false, this.error, this.scannedData, this.isProcessing = false, this.isComplete = false});

  QrPaymentState copyWith({bool? isLoading, String? error, QrPaymentData? scannedData, bool? isProcessing, bool? isComplete}) => QrPaymentState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    scannedData: scannedData ?? this.scannedData,
    isProcessing: isProcessing ?? this.isProcessing,
    isComplete: isComplete ?? this.isComplete,
  );
}

/// QR payment notifier — handles scanning, parsing, and paying.
class QrPaymentNotifier extends Notifier<QrPaymentState> {
  @override
  QrPaymentState build() => const QrPaymentState();

  /// Parse scanned QR data.
  void onScanned(String rawData) {
    try {
      final json = jsonDecode(rawData) as Map<String, dynamic>;
      final data = QrPaymentData.fromJson(json);
      state = state.copyWith(scannedData: data);
    } catch (e) {
      // Try as plain phone number
      if (rawData.startsWith('+') || rawData.startsWith('00')) {
        state = state.copyWith(scannedData: QrPaymentData(
          type: "p2p",
          recipient: rawData,
        ));
      } else {
        state = state.copyWith(error: 'QR code invalide');
      }
    }
  }

  /// Execute payment from QR data.
  Future<void> pay(double amount, {String? pin}) async {
    if (state.scannedData == null) return;
    state = state.copyWith(isProcessing: true);
    try {
      final dio = ref.read(dioProvider);
      final data = state.scannedData!;

      switch (data.type) {
        // ignore: constant_pattern_never_matches_value_type
        case QrPaymentType.p2p:
          await dio.post('/transfers/internal', data: {
            'recipientIdentifier': data.recipient,
            'amount': amount,
            'currency': 'USDC',
            if (pin != null) 'pin': pin,
          });
          break;
        // ignore: constant_pattern_never_matches_value_type
        case QrPaymentType.merchant:
          await dio.post('/payments/merchant', data: {
            'merchantId': data.merchantId,
            'amount': amount,
            'currency': 'USDC',
            if (data.reference != null) 'reference': data.reference,
            if (pin != null) 'pin': pin,
          });
          break;
        // ignore: constant_pattern_never_matches_value_type
        case QrPaymentType.paymentLink:
          await dio.post('/payment-links/${data.paymentLinkId}/pay', data: {
            'amount': amount,
            if (pin != null) 'pin': pin,
          });
          break;
      }

      state = state.copyWith(isProcessing: false, isComplete: true);
      ref.invalidate(walletBalanceProvider);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  void reset() => state = const QrPaymentState();
}

final qrPaymentProvider = NotifierProvider<QrPaymentNotifier, QrPaymentState>(QrPaymentNotifier.new);
