/// Wallet API — balance, deposit, transfer, withdraw, exchange rate
library;

import 'package:dio/dio.dart';

class WalletApi {
  WalletApi(this._dio);
  final Dio _dio;

  // ── Balance ──

  /// GET /wallet — balance + wallet info
  Future<Response> getWallet() => _dio.get('/wallet');

  /// POST /wallet/create
  Future<Response> createWallet() => _dio.post('/wallet/create');

  // ── Deposit ──

  /// GET /wallet/deposit/channels
  Future<Response> getDepositChannels() => _dio.get('/wallet/deposit/channels');

  /// GET /wallet/deposit/providers
  Future<Response> getDepositProviders() => _dio.get('/wallet/deposit/providers');

  /// POST /wallet/deposit
  Future<Response> initiateDeposit(Map<String, dynamic> data) =>
      _dio.post('/wallet/deposit', data: data);

  /// GET /wallet/deposit/:id
  Future<Response> getDepositStatus(String id) =>
      _dio.get('/wallet/deposit/$id');

  // ── Transfer ──

  /// POST /wallet/transfer/internal
  Future<Response> transferInternal(Map<String, dynamic> data) =>
      _dio.post('/wallet/transfer/internal', data: data);

  /// POST /wallet/transfer/external
  Future<Response> transferExternal(Map<String, dynamic> data) =>
      _dio.post('/wallet/transfer/external', data: data);

  /// GET /wallet/transfer/external/estimate-fee
  Future<Response> estimateExternalFee({
    required double amount,
    required String network,
  }) =>
      _dio.get('/wallet/transfer/external/estimate-fee', queryParameters: {
        'amount': amount,
        'network': network,
      });

  // ── Withdraw ──

  /// POST /wallet/withdraw
  Future<Response> withdraw(Map<String, dynamic> data) =>
      _dio.post('/wallet/withdraw', data: data);

  // ── Exchange Rate ──

  /// GET /wallet/exchange-rate
  Future<Response> getExchangeRate() => _dio.get('/wallet/exchange-rate');

  /// GET /wallet/rate
  Future<Response> getRate() => _dio.get('/wallet/rate');

  // ── KYC ──

  /// GET /wallet/kyc/status
  Future<Response> getKycStatus() => _dio.get('/wallet/kyc/status');

  /// POST /wallet/kyc/submit
  Future<Response> submitKyc(Map<String, dynamic> data) =>
      _dio.post('/wallet/kyc/submit', data: data);

  // ── PIN ──

  /// POST /wallet/pin/set
  Future<Response> setPin(String pin) =>
      _dio.post('/wallet/pin/set', data: {'pin': pin});

  /// POST /wallet/pin/verify
  Future<Response> verifyPin(String pin) =>
      _dio.post('/wallet/pin/verify', data: {'pin': pin});

  // ── Limits ──

  /// GET /wallet/limits
  Future<Response> getLimits() => _dio.get('/wallet/limits');
}
