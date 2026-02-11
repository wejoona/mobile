import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';

/// Withdrawal methods matching Korido's mobile money providers.
enum WithdrawMethod {
  orangeMoney('Orange Money', '+225 07'),
  mtnMomo('MTN MoMo', '+225 05'),
  wave('Wave', '+225'),
  moovMoney('Moov Money', '+225 01'),
  bankTransfer('Virement bancaire', '');

  final String label;
  final String prefix;
  const WithdrawMethod(this.label, this.prefix);
}

/// Withdrawal state.
class WithdrawState {
  final bool isLoading;
  final String? error;
  final WithdrawMethod? method;
  final String? phoneNumber;
  final double? amount;
  final double fee;
  final WithdrawResult? result;

  const WithdrawState({this.isLoading = false, this.error, this.method, this.phoneNumber, this.amount, this.fee = 0, this.result});

  double get total => (amount ?? 0) + fee;

  WithdrawState copyWith({bool? isLoading, String? error, WithdrawMethod? method, String? phoneNumber, double? amount, double? fee, WithdrawResult? result}) => WithdrawState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    method: method ?? this.method,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    amount: amount ?? this.amount,
    fee: fee ?? this.fee,
    result: result ?? this.result,
  );
}

/// Withdrawal result.
class WithdrawResult {
  final String id;
  final String status;
  final String? reference;
  final String? instructions;

  const WithdrawResult({required this.id, required this.status, this.reference, this.instructions});

  factory WithdrawResult.fromJson(Map<String, dynamic> json) => WithdrawResult(
    id: json['id'] as String,
    status: json['status'] as String,
    reference: json['reference'] as String?,
    instructions: json['instructions'] as String?,
  );
}

/// Withdraw notifier.
class WithdrawNotifier extends Notifier<WithdrawState> {
  @override
  WithdrawState build() => const WithdrawState();

  void selectMethod(WithdrawMethod method) => state = state.copyWith(method: method);
  void setPhoneNumber(String phone) => state = state.copyWith(phoneNumber: phone);

  void setAmount(double amount) {
    // Simple fee calculation (0.5% for mobile money, flat 2 USDC for bank)
    final fee = state.method == WithdrawMethod.bankTransfer ? 2.0 : amount * 0.005;
    state = state.copyWith(amount: amount, fee: fee);
  }

  Future<void> submit({String? pin}) async {
    if (state.method == null || state.amount == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/withdraw/request', data: {
        'amount': state.amount,
        'provider': state.method!.name,
        'phoneNumber': state.phoneNumber,
        'currency': 'USDC',
        if (pin != null) 'pin': pin,
      });
      final result = WithdrawResult.fromJson(response.data as Map<String, dynamic>);
      state = state.copyWith(isLoading: false, result: result);
      ref.invalidate(walletBalanceProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const WithdrawState();
}

final withdrawProvider = NotifierProvider<WithdrawNotifier, WithdrawState>(WithdrawNotifier.new);
