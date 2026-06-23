/// Bank Linking API — banks list, link/unlink accounts
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';

class BankLinkingApi {
  BankLinkingApi(this._dio);
  final Dio _dio;

  /// GET /banks — available banks
  Future<Response> listBanks() => _dio.get('/banks');

  /// GET /bank-accounts — linked accounts
  Future<Response> listAccounts() => _dio.get('/bank-accounts');

  /// POST /bank-accounts — link a bank account
  Future<Response> linkAccount(Map<String, dynamic> data) =>
      _dio.post('/bank-accounts', data: data);

  /// GET /bank-accounts/:id
  Future<Response> getAccount(String id) => _dio.get('/bank-accounts/$id');

  /// DELETE /bank-accounts/:id — unlink
  Future<Response> unlinkAccount(String id) =>
      _dio.delete('/bank-accounts/$id');

  /// POST /bank-accounts/:id/set-primary
  Future<Response> setPrimaryAccount(String id) =>
      _dio.post('/bank-accounts/$id/set-primary');

  /// GET /bank-accounts/:id/balance
  Future<Response> getBalance(String id) =>
      _dio.get('/bank-accounts/$id/balance');

  /// POST /bank-accounts/:id/deposit
  Future<Response> deposit(
    String id,
    Map<String, dynamic> data, {
    required String pinToken,
    required String idempotencyKey,
  }) => _dio.post(
    '/bank-accounts/$id/deposit',
    data: data,
    options: Options(
      headers: transactionHeaders(
        pinToken: pinToken,
        idempotencyKey: idempotencyKey,
      ),
    ),
  );

  /// POST /bank-accounts/:id/withdraw
  Future<Response> withdraw(
    String id,
    Map<String, dynamic> data, {
    required String pinToken,
    required String idempotencyKey,
  }) => _dio.post(
    '/bank-accounts/$id/withdraw',
    data: data,
    options: Options(
      headers: transactionHeaders(
        pinToken: pinToken,
        idempotencyKey: idempotencyKey,
      ),
    ),
  );
}
