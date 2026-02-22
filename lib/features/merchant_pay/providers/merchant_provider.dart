import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/merchant_pay/services/merchant_service.dart';

/// Merchant Profile Provider with TTL-based caching
/// Cache duration: 5 minutes
final merchantProfileProvider = FutureProvider<MerchantResponse?>((ref) async {
  final service = ref.watch(merchantServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 5 minutes
  final timer = Timer(const Duration(minutes: 5), () {    link.close();  });
  ref.onDispose(() => timer.cancel());

  try {
    return await service.getMyMerchant();
  } on ApiException catch (e) {
    if (e.statusCode == 404) {
      // User is not a merchant
      return null;
    }
    rethrow;
  }
});

/// Check if user is a merchant
final isMerchantProvider = Provider<AsyncValue<bool>>((ref) {
  return ref.watch(merchantProfileProvider).whenData((merchant) => merchant != null);
});

/// Merchant QR Code Provider
final merchantQrProvider =
    FutureProvider.family<MerchantQrResponse, String>((ref, merchantId) async {
  final service = ref.watch(merchantServiceProvider);
  return service.getMerchantQr(merchantId);
});

/// Merchant Analytics Provider
final merchantAnalyticsProvider = FutureProvider.family<MerchantAnalyticsResponse,
    MerchantAnalyticsParams>((ref, params) async {
  final service = ref.watch(merchantServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 5 minutes
  final timer = Timer(const Duration(minutes: 5), () {    link.close();  });
  ref.onDispose(() => timer.cancel());

  return service.getAnalytics(
    merchantId: params.merchantId,
    period: params.period,
  );
});

class MerchantAnalyticsParams {
  final String merchantId;
  final String period;

  const MerchantAnalyticsParams({
    required this.merchantId,
    this.period = 'month',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MerchantAnalyticsParams &&
        other.merchantId == merchantId &&
        other.period == period;
  }

  @override
  int get hashCode => merchantId.hashCode ^ period.hashCode;
}

/// Merchant Transactions Provider
final merchantTransactionsProvider = FutureProvider.family<
    MerchantTransactionsResponse, MerchantTransactionsParams>((ref, params) async {
  final service = ref.watch(merchantServiceProvider);
  return service.getTransactions(
    merchantId: params.merchantId,
    limit: params.limit,
    offset: params.offset,
  );
});

class MerchantTransactionsParams {
  final String merchantId;
  final int limit;
  final int offset;

  const MerchantTransactionsParams({
    required this.merchantId,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MerchantTransactionsParams &&
        other.merchantId == merchantId &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode => merchantId.hashCode ^ limit.hashCode ^ offset.hashCode;
}

// ============================================
// STATE NOTIFIERS
// ============================================

/// Merchant Registration State
class MerchantRegistrationState {
  final bool isLoading;
  final MerchantResponse? merchant;
  final String? error;

  const MerchantRegistrationState({
    this.isLoading = false,
    this.merchant,
    this.error,
  });

  MerchantRegistrationState copyWith({
    bool? isLoading,
    MerchantResponse? merchant,
    String? error,
  }) {
    return MerchantRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      merchant: merchant ?? this.merchant,
      error: error,
    );
  }
}

/// Merchant Registration Notifier
class MerchantRegistrationNotifier extends Notifier<MerchantRegistrationState> {
  @override
  MerchantRegistrationState build() {
    return const MerchantRegistrationState();
  }

  MerchantService get _service => ref.read(merchantServiceProvider);

  Future<bool> register({
    required String businessName,
    String? displayName,
    required String category,
    required String country,
    String? businessAddress,
    String? businessPhone,
    String? businessEmail,
    String? taxId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final merchant = await _service.register(
        businessName: businessName,
        displayName: displayName,
        category: category,
        country: country,
        businessAddress: businessAddress,
        businessPhone: businessPhone,
        businessEmail: businessEmail,
        taxId: taxId,
      );

      state = state.copyWith(isLoading: false, merchant: merchant);
      // Invalidate the merchant profile cache
      ref.invalidate(merchantProfileProvider);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void reset() {
    state = const MerchantRegistrationState();
  }
}

final merchantRegistrationProvider =
    NotifierProvider<MerchantRegistrationNotifier, MerchantRegistrationState>(
  MerchantRegistrationNotifier.new,
);

/// Payment Request State
class PaymentRequestState {
  final bool isLoading;
  final PaymentRequestResponse? paymentRequest;
  final String? error;

  const PaymentRequestState({
    this.isLoading = false,
    this.paymentRequest,
    this.error,
  });

  PaymentRequestState copyWith({
    bool? isLoading,
    PaymentRequestResponse? paymentRequest,
    String? error,
  }) {
    return PaymentRequestState(
      isLoading: isLoading ?? this.isLoading,
      paymentRequest: paymentRequest ?? this.paymentRequest,
      error: error,
    );
  }
}

/// Payment Request Notifier (for creating dynamic QR)
class PaymentRequestNotifier extends Notifier<PaymentRequestState> {
  @override
  PaymentRequestState build() {
    return const PaymentRequestState();
  }

  MerchantService get _service => ref.read(merchantServiceProvider);

  Future<bool> createPaymentRequest({
    required String merchantId,
    required double amount,
    String? currency,
    String? description,
    String? reference,
    int? expiresInMinutes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final paymentRequest = await _service.createPaymentRequest(
        merchantId: merchantId,
        amount: amount,
        currency: currency,
        description: description,
        reference: reference,
        expiresInMinutes: expiresInMinutes,
      );

      state = state.copyWith(isLoading: false, paymentRequest: paymentRequest);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void reset() {
    state = const PaymentRequestState();
  }
}

final paymentRequestProvider =
    NotifierProvider<PaymentRequestNotifier, PaymentRequestState>(
  PaymentRequestNotifier.new,
);

/// Scan to Pay State
class ScanToPayState {
  final bool isLoading;
  final bool isScanning;
  final QrDecodeResponse? scannedMerchant;
  final PaymentResponse? payment;
  final String? error;

  const ScanToPayState({
    this.isLoading = false,
    this.isScanning = true,
    this.scannedMerchant,
    this.payment,
    this.error,
  });

  ScanToPayState copyWith({
    bool? isLoading,
    bool? isScanning,
    QrDecodeResponse? scannedMerchant,
    PaymentResponse? payment,
    String? error,
  }) {
    return ScanToPayState(
      isLoading: isLoading ?? this.isLoading,
      isScanning: isScanning ?? this.isScanning,
      scannedMerchant: scannedMerchant ?? this.scannedMerchant,
      payment: payment ?? this.payment,
      error: error,
    );
  }
}

/// Scan to Pay Notifier
class ScanToPayNotifier extends Notifier<ScanToPayState> {
  @override
  ScanToPayState build() {
    return const ScanToPayState();
  }

  MerchantService get _service => ref.read(merchantServiceProvider);

  Future<bool> decodeQr(String qrData) async {
    state = state.copyWith(isLoading: true, error: null, isScanning: false);

    try {
      final merchantInfo = await _service.decodeQr(qrData);
      state = state.copyWith(isLoading: false, scannedMerchant: merchantInfo);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message, isScanning: true);
      return false;
    }
  }

  Future<bool> processPayment({
    required String qrData,
    double? amount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final payment = await _service.processPayment(
        qrData: qrData,
        amount: amount,
      );
      state = state.copyWith(isLoading: false, payment: payment);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void resetScan() {
    state = const ScanToPayState();
  }

  void goBackToScanning() {
    state = state.copyWith(
      isScanning: true,
      scannedMerchant: null,
      error: null,
    );
  }
}

final scanToPayProvider =
    NotifierProvider<ScanToPayNotifier, ScanToPayState>(
  ScanToPayNotifier.new,
);
