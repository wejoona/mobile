/// Wallet API — balance, deposit, transfer, mobile money cash-out, exchange rate
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_channel_id.dart';

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
    required String pinToken,
    required String idempotencyKey,
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
    required String pinToken,
    required String idempotencyKey,
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
    required String pinToken,
    required String idempotencyKey,
    String? stepUpToken,
  }) => _dio.post(
    ApiEndpoints.transfersExternal,
    data: _externalTransferPayload(data),
    options: _moneyMovementOptions(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
      stepUpToken: stepUpToken,
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

  /// GET /kyc/status
  Future<Response> getKycStatus() => _dio.get(ApiEndpoints.kycStatus);

  /// POST /kyc/submit
  Future<Response> submitKyc(Map<String, dynamic> data) =>
      _dio.post(ApiEndpoints.kycSubmit, data: data);

  // ── Limits ──

  /// GET /user/limits
  Future<Response> getLimits() => _dio.get(ApiEndpoints.limits);

  Options _moneyMovementOptions({
    required String pinToken,
    required String idempotencyKey,
    String? stepUpToken,
  }) => Options(
    headers: transactionHeaders(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
      stepUpToken: stepUpToken,
    ),
  );
}

Map<String, dynamic> _depositPayload(Map<String, dynamic> data) {
  final payload = Map<String, dynamic>.from(data);
  final channelId =
      payload.remove('channelId') ??
      payload.remove('provider') ??
      payload.remove('providerCode');
  if (channelId != null) {
    payload['channelId'] = normalizeDepositChannelId(channelId.toString());
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
