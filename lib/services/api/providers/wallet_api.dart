/// Wallet API — balance, deposit, transfer, withdraw, exchange rate
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';

class WalletApi {
  WalletApi(this._dio);
  final Dio _dio;

  // ── Balance ──

  /// GET /wallet — balance + wallet info
  Future<Response> getWallet() => _dio.get('/wallet');

  /// POST /wallet/create
  Future<Response> createWallet() => _dio.post('/wallet/create');

  // ── Deposit ──

  /// GET /deposits/providers
  Future<Response> getDepositChannels() => _dio.get('/deposits/providers');

  /// GET /deposits/providers
  Future<Response> getDepositProviders() => _dio.get('/deposits/providers');

  /// POST /deposits/initiate
  Future<Response> initiateDeposit(Map<String, dynamic> data) => _dio.post(
    '/deposits/initiate',
    data: _depositPayload(data),
    options: Options(headers: {'X-Idempotency-Key': generateIdempotencyKey()}),
  );

  /// GET /deposits/:id
  Future<Response> getDepositStatus(String id) => _dio.get('/deposits/$id');

  // ── Transfer ──

  /// POST /transfers/internal
  Future<Response> transferInternal(
    Map<String, dynamic> data, {
    String? pinToken,
    String? idempotencyKey,
  }) => _dio.post(
    '/transfers/internal',
    data: data,
    options: _moneyMovementOptions(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// POST /transfers/external
  Future<Response> transferExternal(
    Map<String, dynamic> data, {
    String? pinToken,
    String? idempotencyKey,
  }) => _dio.post(
    '/transfers/external',
    data: data,
    options: _moneyMovementOptions(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// GET /wallet/transfer/external/estimate-fee
  Future<Response> estimateExternalFee({
    required double amount,
    required String network,
  }) => _dio.get(
    '/wallet/transfer/external/estimate-fee',
    queryParameters: {'amount': amount, 'network': network},
  );

  // ── Withdraw ──

  /// POST /wallet/withdraw
  Future<Response> withdraw(
    Map<String, dynamic> data, {
    String? pinToken,
    String? idempotencyKey,
  }) => _dio.post(
    '/wallet/withdraw',
    data: data,
    options: _moneyMovementOptions(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
    ),
  );

  // ── Exchange Rate ──

  /// GET /wallet/rate
  Future<Response> getExchangeRate() => _dio.get('/wallet/rate');

  /// GET /wallet/rate
  Future<Response> getRate() => _dio.get('/wallet/rate');

  // ── KYC ──

  /// GET /wallet/kyc/status
  Future<Response> getKycStatus() => _dio.get('/wallet/kyc/status');

  /// POST /wallet/kyc/submit
  Future<Response> submitKyc(Map<String, dynamic> data) =>
      _dio.post('/wallet/kyc/submit', data: data);

  // ── Limits ──

  /// GET /wallet/limits
  Future<Response> getLimits() => _dio.get('/wallet/limits');

  Options _moneyMovementOptions({String? pinToken, String? idempotencyKey}) {
    if (pinToken == null || pinToken.isEmpty) {
      return Options(
        headers: {
          'X-Idempotency-Key': idempotencyKey ?? generateIdempotencyKey(),
        },
      );
    }

    return Options(
      headers: transactionHeaders(
        pinToken: pinToken,
        idempotencyKey: idempotencyKey,
      ),
    );
  }
}

Map<String, dynamic> _depositPayload(Map<String, dynamic> data) {
  final payload = Map<String, dynamic>.from(data);
  final providerCode =
      payload.remove('providerCode') ?? payload.remove('provider');
  if (providerCode != null) {
    payload['providerCode'] = _mobileMoneyProviderCode(providerCode.toString());
  }
  payload.putIfAbsent(
    'currency',
    () => payload.remove('sourceCurrency') ?? 'XOF',
  );
  final phoneNumber = payload['phoneNumber'];
  if (phoneNumber is String && phoneNumber.trim().isNotEmpty) {
    payload['phoneNumber'] = _normalizePhoneNumber(
      phoneNumber,
      payload['currency'].toString(),
    );
  }
  return payload;
}

String _mobileMoneyProviderCode(String value) {
  switch (value.replaceAll('-', '_').toLowerCase()) {
    case 'omci':
    case 'orange':
    case 'orange_money':
    case 'mobile_money':
      return 'OMCI';
    case 'mtnci':
    case 'mtn':
    case 'mtn_momo':
    case 'mtn_mobile_money':
      return 'MTNCI';
    case 'moovci':
    case 'moov':
    case 'moov_money':
      return 'MOOVCI';
    case 'waveci':
    case 'wave':
      return 'WAVECI';
    default:
      return value.toUpperCase();
  }
}

String _normalizePhoneNumber(String value, String currency) {
  var phone = value.replaceAll(RegExp(r'[\s\-().]'), '');
  if (phone.startsWith('+')) return phone;

  if (currency.toUpperCase() == 'XOF') {
    if (phone.startsWith('225')) return '+$phone';
    if (phone.length == 10) return '+225$phone';
  }

  if (phone.startsWith('1') && phone.length == 11) return '+$phone';
  if (phone.length == 10) return '+1$phone';

  return phone;
}
