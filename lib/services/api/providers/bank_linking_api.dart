/// Bank Linking API — banks list, link/unlink accounts
library;

import 'package:dio/dio.dart';

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
}
