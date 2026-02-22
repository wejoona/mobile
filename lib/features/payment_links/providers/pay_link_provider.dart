import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/core/utils/amount_conversion.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';

/// State for paying a payment link (from deep link or QR).
class PayLinkState {
  final bool isLoading;
  final bool isProcessing;
  final String? error;
  final PaymentLinkDetail? linkDetail;
  final bool isComplete;

  final String? pinToken;
  final String? idempotencyKey;

  const PayLinkState({this.isLoading = false, this.isProcessing = false, this.error, this.linkDetail, this.isComplete = false, this.pinToken, this.idempotencyKey});

  PayLinkState copyWith({bool? isLoading, bool? isProcessing, String? error, PaymentLinkDetail? linkDetail, bool? isComplete, String? pinToken, String? idempotencyKey}) => PayLinkState(
    isLoading: isLoading ?? this.isLoading,
    isProcessing: isProcessing ?? this.isProcessing,
    error: error,
    linkDetail: linkDetail ?? this.linkDetail,
    isComplete: isComplete ?? this.isComplete,
    pinToken: pinToken ?? this.pinToken,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
  );
}

/// Payment link detail from API.
class PaymentLinkDetail {
  final String id;
  final String code;
  final String creatorName;
  final double amount;
  final String currency;
  final String? description;
  final bool isExpired;

  const PaymentLinkDetail({required this.id, required this.code, required this.creatorName, required this.amount, this.currency = 'USDC', this.description, this.isExpired = false});

  factory PaymentLinkDetail.fromJson(Map<String, dynamic> json) => PaymentLinkDetail(
    id: json['id'] as String,
    code: json['code'] as String? ?? json['shortCode'] as String? ?? json['id'] as String,
    creatorName: json['creatorName'] as String? ?? 'Unknown',
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'USDC',
    description: json['description'] as String?,
    isExpired: json['isExpired'] as bool? ?? false,
  );
}

/// Pay link notifier.
class PayLinkNotifier extends Notifier<PayLinkState> {
  @override
  PayLinkState build() => const PayLinkState();

  /// Load payment link details.
  Future<void> loadLink(String linkId) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/payment-links/$linkId');
      final detail = PaymentLinkDetail.fromJson(response.data as Map<String, dynamic>);
      state = state.copyWith(isLoading: false, linkDetail: detail);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Verify PIN before paying.
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
      state = state.copyWith(isLoading: false, error: result.message ?? 'PIN verification failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Pay the link. Requires verifyPin() first.
  /// Uses the link code (not ID) in the URL path per backend API.
  Future<void> pay() async {
    if (state.linkDetail == null) return;
    if (state.pinToken == null || state.idempotencyKey == null) {
      state = state.copyWith(error: 'PIN verification required');
      return;
    }
    if (state.isProcessing) return; // double-submit guard
    state = state.copyWith(isProcessing: true);
    try {
      final dio = ref.read(dioProvider);
      final code = state.linkDetail!.code;
      await dio.post(
        '/payment-links/code/$code/pay',
        data: {
          'amount': toCents(state.linkDetail!.amount),
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

  void reset() => state = const PayLinkState();
}

final payLinkProvider = NotifierProvider<PayLinkNotifier, PayLinkState>(PayLinkNotifier.new);
