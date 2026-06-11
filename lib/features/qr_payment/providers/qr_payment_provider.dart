import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/qr_payment/models/qr_data.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/core/utils/amount_conversion.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';

/// QR payment types.
enum QrPaymentType { p2p, merchant, paymentLink }

/// QR payment state.
class QrPaymentState {
  final bool isLoading;
  final String? error;
  final QrPaymentData? scannedData;
  final bool isProcessing;
  final bool isComplete;

  final String? pinToken;
  final String? idempotencyKey;

  const QrPaymentState({
    this.isLoading = false,
    this.error,
    this.scannedData,
    this.isProcessing = false,
    this.isComplete = false,
    this.pinToken,
    this.idempotencyKey,
  });

  QrPaymentState copyWith({
    bool? isLoading,
    String? error,
    QrPaymentData? scannedData,
    bool? isProcessing,
    bool? isComplete,
    String? pinToken,
    String? idempotencyKey,
  }) => QrPaymentState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    scannedData: scannedData ?? this.scannedData,
    isProcessing: isProcessing ?? this.isProcessing,
    isComplete: isComplete ?? this.isComplete,
    pinToken: pinToken ?? this.pinToken,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
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
        state = state.copyWith(
          scannedData: QrPaymentData(type: "p2p", recipient: rawData),
        );
      } else {
        state = state.copyWith(error: 'QR code invalide');
      }
    }
  }

  /// Verify PIN and store token for payment.
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

  /// Execute payment from QR data. Requires verifyPin() first.
  Future<void> pay(double amount) async {
    if (state.scannedData == null) return;
    if (state.pinToken == null || state.idempotencyKey == null) {
      state = state.copyWith(error: 'PIN verification required');
      return;
    }
    if (state.isProcessing) return; // double-submit guard
    state = state.copyWith(isProcessing: true);
    try {
      final dio = ref.read(dioProvider);
      final data = state.scannedData!;
      final headers = transactionHeaders(
        pinToken: state.pinToken!,
        idempotencyKey: state.idempotencyKey!,
      );
      final options = Options(headers: headers);
      final amountCents = toCents(amount);
      final transferAmount = amount;

      // data.type is a String? — match against string values, not enum
      switch (data.type) {
        case 'p2p':
          final recipientPhone = _recipientPhone(data);
          if (recipientPhone == null) {
            state = state.copyWith(
              isProcessing: false,
              error: 'QR payment requires a recipient phone number',
            );
            return;
          }
          await dio.post(
            '/transfers/internal',
            data: {
              'recipientPhone': recipientPhone,
              'amount': transferAmount,
              'currency': 'USDC',
              if (data.note != null) 'note': data.note,
            },
            options: options,
          );
          break;
        case 'merchant':
          await dio.post(
            '/merchants/pay',
            data: {
              'merchantId': data.merchantId,
              'amount': amountCents,
              'currency': 'USDC',
              if (data.reference != null) 'reference': data.reference,
            },
            options: options,
          );
          break;
        case 'paymentLink':
          final paymentCode = data.paymentLinkId;
          if (paymentCode == null || paymentCode.isEmpty) {
            state = state.copyWith(
              isProcessing: false,
              error: 'QR payment link requires a payment code',
            );
            return;
          }
          // Backend expects the short code and a major-unit amount.
          await dio.post(
            '/payment-links/code/$paymentCode/pay',
            data: {'amount': transferAmount},
            options: options,
          );
          break;
        default:
          // Fallback: treat as p2p when the QR includes a phone number.
          final recipientPhone = _recipientPhone(data);
          if (recipientPhone != null) {
            await dio.post(
              '/transfers/internal',
              data: {
                'recipientPhone': recipientPhone,
                'amount': transferAmount,
                'currency': 'USDC',
                if (data.note != null) 'note': data.note,
              },
              options: options,
            );
          } else {
            state = state.copyWith(
              isProcessing: false,
              error: 'Unknown QR payment type: ${data.type}',
            );
            return;
          }
      }

      state = state.copyWith(isProcessing: false, isComplete: true);
      ref.invalidate(walletBalanceProvider);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  String? _recipientPhone(QrPaymentData data) {
    for (final value in [data.recipient, data.phone, data.userId]) {
      if (value == null || value.isEmpty) continue;
      final normalized = value.startsWith('00')
          ? '+${value.substring(2)}'
          : value;
      if (RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(normalized)) {
        return normalized;
      }
    }
    return null;
  }

  void reset() => state = const QrPaymentState();
}

final qrPaymentProvider = NotifierProvider<QrPaymentNotifier, QrPaymentState>(
  QrPaymentNotifier.new,
);
