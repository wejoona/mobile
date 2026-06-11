import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/core/utils/amount_conversion.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart';

/// Withdrawal methods matching Korido's mobile money providers.
enum WithdrawMethod {
  orangeMoney('Orange Money', '+225 07', 'OMCI'),
  mtnMomo('MTN MoMo', '+225 05', 'MTNCI'),
  wave('Wave', '+225', 'WAVECI'),
  moovMoney('Moov Money', '+225 01', 'MOOVCI'),
  bankTransfer('Virement bancaire', '', null);

  final String label;
  final String prefix;
  final String? providerCode;
  const WithdrawMethod(this.label, this.prefix, this.providerCode);
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

  const WithdrawState({
    this.isLoading = false,
    this.error,
    this.method,
    this.phoneNumber,
    this.amount,
    this.fee = 0,
    this.result,
  });

  double get total => (amount ?? 0) + fee;

  WithdrawState copyWith({
    bool? isLoading,
    String? error,
    WithdrawMethod? method,
    String? phoneNumber,
    double? amount,
    double? fee,
    WithdrawResult? result,
  }) => WithdrawState(
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

  const WithdrawResult({
    required this.id,
    required this.status,
    this.reference,
    this.instructions,
  });

  factory WithdrawResult.fromJson(Map<String, dynamic> json) {
    final raw = _unwrapPayload(json);
    return WithdrawResult(
      id:
          _readString(raw, const [
            'id',
            'withdrawalId',
            'withdrawal_id',
            'transactionId',
            'transaction_id',
          ]) ??
          '',
      status:
          _readString(raw, const ['status', 'state', 'transactionStatus']) ??
          'pending',
      reference: _readString(raw, const [
        'reference',
        'providerReference',
        'provider_reference',
      ]),
      instructions: _readString(raw, const ['instructions', 'message']),
    );
  }
}

/// Withdraw notifier.
class WithdrawNotifier extends Notifier<WithdrawState> {
  @override
  WithdrawState build() => const WithdrawState();

  void selectMethod(WithdrawMethod method) =>
      state = state.copyWith(method: method);
  void setPhoneNumber(String phone) =>
      state = state.copyWith(phoneNumber: phone);

  /// Estimate fees locally until the API exposes a withdrawal quote endpoint.
  Future<void> setAmount(double amount) async {
    final fee = state.method == WithdrawMethod.bankTransfer
        ? 2.0
        : amount * 0.005;
    state = state.copyWith(amount: amount, fee: fee);
  }

  /// Fix #8: Wire to real /withdrawals/initiate endpoint.
  /// Fix #1: PIN token in headers. Fix #2: Idempotency key in headers.
  /// Fix #3: Amount converted to cents for backend.
  Future<void> submit({
    required String pinToken,
    String? idempotencyKey,
  }) async {
    if (state.method == null || state.amount == null) return;
    final providerCode = state.method!.providerCode;
    if (providerCode == null) {
      state = state.copyWith(
        error: 'Bank transfer withdrawals are not available yet.',
      );
      return;
    }
    final phoneNumber = state.phoneNumber;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      state = state.copyWith(error: 'Phone number is required.');
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final headers = transactionHeaders(
        pinToken: pinToken,
        idempotencyKey: idempotencyKey,
      );

      final response = await dio.post(
        '/withdrawals/initiate',
        data: {
          'amount': toCents(state.amount!),
          'providerCode': providerCode,
          'phoneNumber': phoneNumber,
          'currency': 'XOF',
        },
        options: Options(headers: headers),
      );
      final result = WithdrawResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      if (result.id.isEmpty) {
        throw StateError('Withdrawal response did not include an id.');
      }
      state = state.copyWith(isLoading: false, result: result);
      ref.invalidate(walletBalanceProvider);
      ref.invalidate(transactionsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const WithdrawState();
}

final withdrawProvider = NotifierProvider<WithdrawNotifier, WithdrawState>(
  WithdrawNotifier.new,
);

Map<String, dynamic> _unwrapPayload(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return json;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final stringValue = value.toString().trim();
    if (stringValue.isNotEmpty) return stringValue;
  }
  return null;
}
