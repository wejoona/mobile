import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
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

/// Backend-owned withdrawal rail returned by `/wallet/withdraw/options`.
class WithdrawalOption {
  const WithdrawalOption({
    required this.id,
    required this.name,
    required this.type,
    required this.enabled,
    this.providerCode,
    this.country,
    this.currency,
    this.payoutCurrency,
    this.minAmount,
    this.maxAmount,
    this.fee,
    this.feeType,
    this.minFee,
    this.maxFee,
    this.estimatedArrival,
  });

  final String id;
  final String name;
  final String type;
  final bool enabled;
  final String? providerCode;
  final String? country;
  final String? currency;
  final String? payoutCurrency;
  final double? minAmount;
  final double? maxAmount;
  final double? fee;
  final String? feeType;
  final double? minFee;
  final double? maxFee;
  final String? estimatedArrival;

  bool get isMobileMoney =>
      type.toLowerCase() == 'mobile_money' && providerCode != null;

  factory WithdrawalOption.fromJson(Map<String, dynamic> json) {
    return WithdrawalOption(
      id: _readString(json, const ['id']) ?? '',
      name: _readString(json, const ['name']) ?? 'Withdrawal rail',
      type: _readString(json, const ['type']) ?? '',
      providerCode: _readString(json, const ['providerCode', 'provider_code']),
      country: _readString(json, const ['country']),
      currency: _readString(json, const ['currency']),
      payoutCurrency: _readString(json, const [
        'payoutCurrency',
        'payout_currency',
      ]),
      minAmount: _readDouble(json, const ['minAmount', 'min_amount']),
      maxAmount: _readDouble(json, const ['maxAmount', 'max_amount']),
      fee: _readDouble(json, const ['fee']),
      feeType: _readString(json, const ['feeType', 'fee_type']),
      minFee: _readDouble(json, const ['minFee', 'min_fee']),
      maxFee: _readDouble(json, const ['maxFee', 'max_fee']),
      estimatedArrival: _readString(json, const [
        'estimatedArrival',
        'estimated_arrival',
      ]),
      enabled: _readBool(json, const ['enabled', 'available']) ?? true,
    );
  }
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

  /// Quote fees from the same backend commercial terms path used for submission.
  Future<void> setAmount(double amount) async {
    state = state.copyWith(amount: amount, fee: 0, error: null);
    final method = state.method;
    if (amount <= 0 || method == null) return;
    final providerCode = method.providerCode;
    if (providerCode == null) {
      state = state.copyWith(
        error: 'Bank transfer withdrawals are not available yet.',
      );
      return;
    }

    try {
      final fee = await _estimateMobileMoneyFee(
        amount: amount,
        providerCode: providerCode,
      );
      state = state.copyWith(amount: amount, fee: fee, error: null);
    } catch (e) {
      state = state.copyWith(
        amount: amount,
        fee: 0,
        error: 'Unable to estimate withdrawal fee. Please try again.',
      );
    }
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
        ApiEndpoints.withdrawInitiate,
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

  Future<double> _estimateMobileMoneyFee({
    required double amount,
    required String providerCode,
  }) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      ApiEndpoints.withdrawQuote,
      data: {
        'amount': toCents(amount),
        'providerCode': providerCode,
        'currency': 'XOF',
      },
    );
    final payload = _unwrapPayload(
      Map<String, dynamic>.from(response.data as Map),
    );
    final feeCents = _readDouble(payload, const ['fee', 'feeCents']);
    if (feeCents == null) {
      throw StateError('Withdrawal quote response did not include a fee.');
    }
    return feeCents / 100;
  }
}

final withdrawProvider = NotifierProvider<WithdrawNotifier, WithdrawState>(
  WithdrawNotifier.new,
);

final withdrawalOptionsProvider =
    FutureProvider.family<List<WithdrawalOption>, String>((ref, country) async {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        ApiEndpoints.walletWithdrawOptions,
        queryParameters: {'country': country},
      );
      final payload = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      final options = _readList(_unwrapPayload(payload), const [
        'options',
        'withdrawalOptions',
        'rails',
      ]);
      return options
          .whereType<Map>()
          .map(
            (item) =>
                WithdrawalOption.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((option) => option.id.isNotEmpty)
          .toList(growable: false);
    });

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

bool? _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
  }
  return null;
}

double? _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

List<dynamic> _readList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value;
  }
  return const [];
}
