import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/bill_payments/bill_payments_service.dart';
import '../../../services/api/api_client.dart';
import '../../../services/app_review/app_review_service.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// Bill Categories Provider with TTL caching (30 minutes)
final billCategoriesProvider = FutureProvider.family<BillCategoriesResponse, String?>(
  (ref, country) async {
    final service = ref.watch(billPaymentsServiceProvider);
    final link = ref.keepAlive();

    // Auto-invalidate after 30 minutes
    Timer(const Duration(minutes: 30), () {
      link.close();
    });

    return service.getCategories(country: country);
  },
);

/// Bill Providers Provider with TTL caching (10 minutes)
final billProvidersProvider = FutureProvider.family<BillProvidersResponse, BillProvidersParams>(
  (ref, params) async {
    final service = ref.watch(billPaymentsServiceProvider);
    final link = ref.keepAlive();

    // Auto-invalidate after 10 minutes
    Timer(const Duration(minutes: 10), () {
      link.close();
    });

    return service.getProviders(
      country: params.country,
      category: params.category,
    );
  },
);

class BillProvidersParams {
  final String? country;
  final String? category;

  const BillProvidersParams({this.country, this.category});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillProvidersParams &&
        other.country == country &&
        other.category == category;
  }

  @override
  int get hashCode => country.hashCode ^ category.hashCode;
}

/// Bill Payment History Provider
final billPaymentHistoryProvider = FutureProvider.family<BillPaymentHistoryResponse, BillPaymentHistoryParams>(
  (ref, params) async {
    final service = ref.watch(billPaymentsServiceProvider);
    return service.getHistory(
      page: params.page,
      limit: params.limit,
      category: params.category,
      status: params.status,
    );
  },
);

class BillPaymentHistoryParams {
  final int page;
  final int limit;
  final String? category;
  final String? status;

  const BillPaymentHistoryParams({
    this.page = 1,
    this.limit = 20,
    this.category,
    this.status,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillPaymentHistoryParams &&
        other.page == page &&
        other.limit == limit &&
        other.category == category &&
        other.status == status;
  }

  @override
  int get hashCode =>
      page.hashCode ^ limit.hashCode ^ category.hashCode ^ status.hashCode;
}

// ============================================================================
// SELECTED PROVIDER STATE
// ============================================================================

/// Selected bill category notifier
class SelectedBillCategoryNotifier extends Notifier<BillCategory?> {
  @override
  BillCategory? build() => null;

  void select(BillCategory? category) {
    state = category;
  }

  void clear() {
    state = null;
  }
}

/// Currently selected bill category
final selectedBillCategoryProvider =
    NotifierProvider<SelectedBillCategoryNotifier, BillCategory?>(
  SelectedBillCategoryNotifier.new,
);

/// Selected bill provider notifier
class SelectedBillProviderNotifier extends Notifier<BillProvider?> {
  @override
  BillProvider? build() => null;

  void select(BillProvider? provider) {
    state = provider;
  }

  void clear() {
    state = null;
  }
}

/// Currently selected bill provider
final selectedBillProviderProvider =
    NotifierProvider<SelectedBillProviderNotifier, BillProvider?>(
  SelectedBillProviderNotifier.new,
);

// ============================================================================
// ACCOUNT VALIDATION STATE
// ============================================================================

class AccountValidationState {
  final bool isLoading;
  final AccountValidationResult? result;
  final String? error;

  const AccountValidationState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  AccountValidationState copyWith({
    bool? isLoading,
    AccountValidationResult? result,
    String? error,
  }) {
    return AccountValidationState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

class AccountValidationNotifier extends Notifier<AccountValidationState> {
  @override
  AccountValidationState build() {
    return const AccountValidationState();
  }

  BillPaymentsService get _service => ref.read(billPaymentsServiceProvider);

  Future<bool> validate({
    required String providerId,
    required String accountNumber,
    String? meterNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.validateAccount(
        providerId: providerId,
        accountNumber: accountNumber,
        meterNumber: meterNumber,
      );

      state = state.copyWith(isLoading: false, result: result);
      return result.isValid;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void reset() {
    state = const AccountValidationState();
  }
}

final accountValidationProvider =
    NotifierProvider.autoDispose<AccountValidationNotifier, AccountValidationState>(
  AccountValidationNotifier.new,
);

// ============================================================================
// BILL PAYMENT STATE
// ============================================================================

class BillPaymentState {
  final bool isLoading;
  final BillPaymentResult? result;
  final String? error;

  const BillPaymentState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  BillPaymentState copyWith({
    bool? isLoading,
    BillPaymentResult? result,
    String? error,
  }) {
    return BillPaymentState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

class BillPaymentNotifier extends Notifier<BillPaymentState> {
  @override
  BillPaymentState build() {
    return const BillPaymentState();
  }

  BillPaymentsService get _service => ref.read(billPaymentsServiceProvider);

  Future<bool> payBill({
    required String providerId,
    required String accountNumber,
    required double amount,
    String? meterNumber,
    String? customerName,
    String? currency,
    String? phone,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.payBill(
        providerId: providerId,
        accountNumber: accountNumber,
        amount: amount,
        meterNumber: meterNumber,
        customerName: customerName,
        currency: currency,
        phone: phone,
        email: email,
      );

      state = state.copyWith(isLoading: false, result: result);

      // Invalidate history cache
      ref.invalidate(billPaymentHistoryProvider);

      // Track successful transaction for app review prompt
      final appReviewService = ref.read(appReviewServiceProvider);
      await appReviewService.trackSuccessfulTransaction();

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void reset() {
    state = const BillPaymentState();
  }
}

final billPaymentProvider =
    NotifierProvider.autoDispose<BillPaymentNotifier, BillPaymentState>(
  BillPaymentNotifier.new,
);

// ============================================================================
// RECEIPT PROVIDER
// ============================================================================

final billPaymentReceiptProvider = FutureProvider.family<BillPaymentReceipt, String>(
  (ref, paymentId) async {
    final service = ref.watch(billPaymentsServiceProvider);
    return service.getReceipt(paymentId);
  },
);

// ============================================================================
// BILL PAYMENT FORM STATE
// ============================================================================

class BillPaymentFormState {
  final String? accountNumber;
  final String? meterNumber;
  final double? amount;
  final String? customerName;
  final bool isValidated;
  final AccountValidationResult? validationResult;

  const BillPaymentFormState({
    this.accountNumber,
    this.meterNumber,
    this.amount,
    this.customerName,
    this.isValidated = false,
    this.validationResult,
  });

  BillPaymentFormState copyWith({
    String? accountNumber,
    String? meterNumber,
    double? amount,
    String? customerName,
    bool? isValidated,
    AccountValidationResult? validationResult,
  }) {
    return BillPaymentFormState(
      accountNumber: accountNumber ?? this.accountNumber,
      meterNumber: meterNumber ?? this.meterNumber,
      amount: amount ?? this.amount,
      customerName: customerName ?? this.customerName,
      isValidated: isValidated ?? this.isValidated,
      validationResult: validationResult ?? this.validationResult,
    );
  }

  bool get isComplete =>
      accountNumber != null &&
      accountNumber!.isNotEmpty &&
      amount != null &&
      amount! > 0;
}

class BillPaymentFormNotifier extends Notifier<BillPaymentFormState> {
  @override
  BillPaymentFormState build() {
    return const BillPaymentFormState();
  }

  void setAccountNumber(String value) {
    state = state.copyWith(
      accountNumber: value,
      isValidated: false,
      validationResult: null,
    );
  }

  void setMeterNumber(String value) {
    state = state.copyWith(
      meterNumber: value,
      isValidated: false,
      validationResult: null,
    );
  }

  void setAmount(double value) {
    state = state.copyWith(amount: value);
  }

  void setCustomerName(String value) {
    state = state.copyWith(customerName: value);
  }

  void setValidationResult(AccountValidationResult result) {
    state = state.copyWith(
      isValidated: result.isValid,
      validationResult: result,
      customerName: result.customerName,
    );
  }

  void reset() {
    state = const BillPaymentFormState();
  }
}

final billPaymentFormProvider =
    NotifierProvider.autoDispose<BillPaymentFormNotifier, BillPaymentFormState>(
  BillPaymentFormNotifier.new,
);
