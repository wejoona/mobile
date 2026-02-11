import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/bill_payments/bill_payments_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';

/// Bill payment flow state.
class BillPaymentState {
  final bool isLoading;
  final String? error;
  final BillCategory? selectedCategory;
  final dynamic selectedBiller;
  final double? amount;
  final String? subscriberNumber;
  final BillPaymentResult? result;

  const BillPaymentState({
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.selectedBiller,
    this.amount,
    this.subscriberNumber,
    this.result,
  });

  BillPaymentState copyWith({
    bool? isLoading,
    String? error,
    BillCategory? selectedCategory,
    dynamic selectedBiller,
    double? amount,
    String? subscriberNumber,
    BillPaymentResult? result,
  }) => BillPaymentState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    selectedBiller: selectedBiller ?? this.selectedBiller,
    amount: amount ?? this.amount,
    subscriberNumber: subscriberNumber ?? this.subscriberNumber,
    result: result ?? this.result,
  );
}

/// Bill categories.
enum BillCategory {
  electricity('Electricite'),
  water('Eau'),
  internet('Internet'),
  television('Television'),
  telecom('Telecom'),
  insurance('Assurance');

  final String label;
  const BillCategory(this.label);
}

/// Bill payment result.
class BillPaymentResult {
  final String id;
  final String status;
  final String? reference;

  const BillPaymentResult({required this.id, required this.status, this.reference});

  factory BillPaymentResult.fromJson(Map<String, dynamic> json) => BillPaymentResult(
    id: json['id'] as String,
    status: json['status'] as String,
    reference: json['reference'] as String?,
  );
}

/// Bill payment notifier — wired to BillPaymentsService.
class BillPaymentNotifier extends Notifier<BillPaymentState> {
  @override
  BillPaymentState build() => const BillPaymentState();

  void selectCategory(BillCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void selectBiller(dynamic biller) {
    state = state.copyWith(selectedBiller: biller);
  }

  void setAmount(double amount) => state = state.copyWith(amount: amount);
  void setSubscriberNumber(String number) => state = state.copyWith(subscriberNumber: number);

  Future<void> pay({String? pin}) async {
    if (state.selectedBiller == null || state.amount == null || state.subscriberNumber == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(billPaymentsServiceProvider);
      final result = await service.payBill(
        providerId: state.selectedBiller.id ?? 'unknown',
        accountNumber: state.subscriberNumber!,
        amount: state.amount!,
      );
      state = state.copyWith(isLoading: false, result: result);
      ref.invalidate(walletBalanceProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const BillPaymentState();
}

final billPaymentProvider = NotifierProvider<BillPaymentNotifier, BillPaymentState>(BillPaymentNotifier.new);
