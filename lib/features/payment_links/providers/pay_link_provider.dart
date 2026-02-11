import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';

/// State for paying a payment link (from deep link or QR).
class PayLinkState {
  final bool isLoading;
  final bool isProcessing;
  final String? error;
  final PaymentLinkDetail? linkDetail;
  final bool isComplete;

  const PayLinkState({this.isLoading = false, this.isProcessing = false, this.error, this.linkDetail, this.isComplete = false});

  PayLinkState copyWith({bool? isLoading, bool? isProcessing, String? error, PaymentLinkDetail? linkDetail, bool? isComplete}) => PayLinkState(
    isLoading: isLoading ?? this.isLoading,
    isProcessing: isProcessing ?? this.isProcessing,
    error: error,
    linkDetail: linkDetail ?? this.linkDetail,
    isComplete: isComplete ?? this.isComplete,
  );
}

/// Payment link detail from API.
class PaymentLinkDetail {
  final String id;
  final String creatorName;
  final double amount;
  final String currency;
  final String? description;
  final bool isExpired;

  const PaymentLinkDetail({required this.id, required this.creatorName, required this.amount, this.currency = 'USDC', this.description, this.isExpired = false});

  factory PaymentLinkDetail.fromJson(Map<String, dynamic> json) => PaymentLinkDetail(
    id: json['id'] as String,
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

  /// Pay the link.
  Future<void> pay({String? pin}) async {
    if (state.linkDetail == null) return;
    state = state.copyWith(isProcessing: true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/payment-links/${state.linkDetail!.id}/pay', data: {
        'amount': state.linkDetail!.amount,
        if (pin != null) 'pin': pin,
      });
      state = state.copyWith(isProcessing: false, isComplete: true);
      ref.invalidate(walletBalanceProvider);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  void reset() => state = const PayLinkState();
}

final payLinkProvider = NotifierProvider<PayLinkNotifier, PayLinkState>(PayLinkNotifier.new);
