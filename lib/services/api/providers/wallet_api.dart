/// Wallet API — balance, deposit, transfer, mobile money cash-out, exchange rate
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';

class WalletApi {
  WalletApi(this._dio);
  final Dio _dio;

  // ── Balance ──

  /// GET /wallet — balance + wallet info
  Future<Response> getWallet() => _dio.get(ApiEndpoints.walletBalance);

  /// POST /wallet/create
  Future<Response> createWallet() => _dio.post(ApiEndpoints.walletCreate);

  // ── Deposit ──

  /// GET /wallet/deposit/channels
  Future<Response> getDepositChannels() =>
      _dio.get(ApiEndpoints.depositChannels);

  /// GET /wallet/deposit/providers
  Future<Response> getDepositProviders() =>
      _dio.get(ApiEndpoints.depositProviders);

  /// POST /wallet/deposit
  Future<Response> initiateDeposit(Map<String, dynamic> data) => _dio.post(
    ApiEndpoints.depositInitiate,
    data: _depositPayload(data),
    options: Options(headers: {'X-Idempotency-Key': generateIdempotencyKey()}),
  );

  /// GET /wallet/deposit/:id
  Future<Response> getDepositStatus(String id) =>
      _dio.get(ApiEndpoints.depositById(id));

  // ── Transfer ──

  /// POST /wallet/transfer/internal
  Future<Response> transferInternal(
    Map<String, dynamic> data, {
    String? pinToken,
    String? idempotencyKey,
  }) => _dio.post(
    ApiEndpoints.transfersSend,
    data: _internalTransferPayload(data),
    options: _moneyMovementOptions(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// POST /wallet/transfer/external
  Future<Response> transferExternal(
    Map<String, dynamic> data, {
    String? pinToken,
    String? idempotencyKey,
  }) => _dio.post(
    ApiEndpoints.transfersExternal,
    data: _externalTransferPayload(data),
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
    ApiEndpoints.transfersEstimateFee,
    queryParameters: {'amount': amount, 'network': network},
  );

  // ── On-chain withdrawal / external transfer ──

  /// POST /wallet/transfer/external
  Future<Response> withdraw(
    Map<String, dynamic> data, {
    String? pinToken,
    String? idempotencyKey,
  }) => _dio.post(
    ApiEndpoints.transfersExternal,
    data: _externalTransferPayload(data),
    options: _moneyMovementOptions(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
    ),
  );

  // ── Exchange Rate ──

  /// GET /wallet/exchange-rate
  Future<Response> getExchangeRate({
    String sourceCurrency = 'XOF',
    String targetCurrency = 'USD',
    double amount = 10000,
    String direction = 'buy',
  }) => _dio.get(
    ApiEndpoints.walletExchangeRate,
    queryParameters: {
      'sourceCurrency': sourceCurrency,
      'targetCurrency': targetCurrency,
      'amount': amount,
      'direction': direction,
    },
  );

  /// GET /wallet/exchange-rate
  Future<Response> getRate({
    String sourceCurrency = 'XOF',
    String targetCurrency = 'USD',
    double amount = 10000,
    String direction = 'buy',
  }) => getExchangeRate(
    sourceCurrency: sourceCurrency,
    targetCurrency: targetCurrency,
    amount: amount,
    direction: direction,
  );

  // ── KYC ──

  /// GET /wallet/kyc/status
  Future<Response> getKycStatus() => _dio.get(ApiEndpoints.walletKycStatus);

  /// POST /wallet/kyc/submit
  Future<Response> submitKyc(Map<String, dynamic> data) =>
      _dio.post(ApiEndpoints.walletKycSubmit, data: data);

  // ── Limits ──

  /// GET /wallet/limits
  Future<Response> getLimits() => _dio.get(ApiEndpoints.walletLimits);

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
  final channelId =
      payload.remove('channelId') ??
      payload.remove('provider') ??
      payload.remove('providerCode');
  if (channelId != null) {
    payload['channelId'] = _mobileMoneyChannelId(channelId.toString());
  }
  payload.putIfAbsent(
    'sourceCurrency',
    () => payload.remove('currency') ?? 'XOF',
  );
  return payload;
}

Map<String, dynamic> _internalTransferPayload(Map<String, dynamic> data) {
  final payload = Map<String, dynamic>.from(data);
  final recipientPhone = payload.remove('recipientPhone');
  payload['toPhone'] = payload['toPhone'] ?? recipientPhone;
  return payload;
}

Map<String, dynamic> _externalTransferPayload(Map<String, dynamic> data) {
  final payload = Map<String, dynamic>.from(data);
  final recipientAddress = payload.remove('recipientAddress');
  payload['toAddress'] = payload['toAddress'] ?? recipientAddress;
  return payload;
}

String _mobileMoneyChannelId(String value) {
  switch (value.replaceAll('-', '_').toLowerCase()) {
    case 'orange_money_ci':
    case 'omci':
    case 'orange':
    case 'orange_money':
    case 'mobile_money':
      return 'orange_money_ci';
    case 'mtn_momo_ci':
    case 'mtnci':
    case 'mtn':
    case 'mtn_momo':
    case 'mtn_mobile_money':
      return 'mtn_momo_ci';
    case 'moov_money_ci':
    case 'moovci':
    case 'moov':
    case 'moov_money':
      return 'moov_money_ci';
    case 'wave_ci':
    case 'waveci':
    case 'wave':
      return 'wave_ci';
    default:
      return value;
  }
}
