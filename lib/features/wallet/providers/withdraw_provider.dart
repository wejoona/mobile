import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/core/utils/amount_conversion.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart';

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

  /// Fix #9: Fetch real fees from /fees/calculate instead of hardcoding.
  Future<void> setAmount(double amount) async {
    state = state.copyWith(amount: amount, fee: 0);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/fees/calculate', data: {
        'amount': toCents(amount),
        'type': 'withdrawal',
        'provider': state.method?.name ?? 'orangeMoney',
        'currency': 'USDC',
      });
      final data = response.data as Map<String, dynamic>;
      final fee = (data['fee'] as num?)?.toDouble() ?? 0.0;
      state = state.copyWith(fee: fromCents(fee.round()));
    } catch (_) {
      // Fallback to local calculation if API unavailable
      final fee = state.method == WithdrawMethod.bankTransfer ? 2.0 : amount * 0.005;
      state = state.copyWith(fee: fee);
    }
  }

  /// Fix #8: Wire to real /withdrawals endpoint.
  /// Fix #1: PIN token in headers. Fix #2: Idempotency key in headers.
  /// Fix #3: Amount converted to cents for backend.
  Future<void> submit({required String pinToken, String? idempotencyKey}) async {
    if (state.method == null || state.amount == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final headers = transactionHeaders(
        pinToken: pinToken,
        idempotencyKey: idempotencyKey,
      );

      final response = await dio.post(
        '/withdrawals',
        data: {
          'amount': toCents(state.amount!),
          'provider': state.method!.name,
          'phoneNumber': state.phoneNumber,
          'currency': 'USDC',
        },
        options: Options(headers: headers),
      );
      final result = WithdrawResult.fromJson(response.data as Map<String, dynamic>);
      state = state.copyWith(isLoading: false, result: result);
      ref.invalidate(walletBalanceProvider);
      ref.invalidate(transactionsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const WithdrawState();
}

final withdrawProvider = NotifierProvider<WithdrawNotifier, WithdrawState>(WithdrawNotifier.new);
