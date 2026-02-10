import 'package:dio/dio.dart';

/// Bank Linking Service
///
/// Handles linking and managing bank accounts for deposits/withdrawals.
class BankLinkingService {
  final Dio _dio;

  BankLinkingService(this._dio);

  /// Get available banks for a country
  Future<Map<String, dynamic>> getBanks({String? country}) async {
    final response = await _dio.get(
      '/banks',
      queryParameters: {
        if (country != null) 'country': country,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get all linked bank accounts
  Future<Map<String, dynamic>> getLinkedAccounts() async {
    final response = await _dio.get('/bank-accounts');
    return response.data as Map<String, dynamic>;
  }

  /// Get a single linked bank account
  Future<Map<String, dynamic>> getLinkedAccount(String accountId) async {
    final response = await _dio.get('/bank-accounts/$accountId');
    return response.data as Map<String, dynamic>;
  }

  /// Link a new bank account
  Future<Map<String, dynamic>> linkBankAccount({
    required String bankCode,
    required String accountNumber,
    required String accountHolderName,
    required String countryCode,
  }) async {
    final response = await _dio.post(
      '/bank-accounts',
      data: {
        'bank_code': bankCode,
        'account_number': accountNumber,
        'account_holder_name': accountHolderName,
        'country_code': countryCode,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Verify a linked bank account with OTP
  Future<Map<String, dynamic>> verifyBankAccount({
    required String accountId,
    required String otp,
  }) async {
    final response = await _dio.post(
      '/bank-accounts/$accountId/verify',
      data: {'otp': otp},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Set a bank account as primary
  Future<Map<String, dynamic>> setPrimaryAccount(String accountId) async {
    final response = await _dio.post('/bank-accounts/$accountId/set-primary');
    return response.data as Map<String, dynamic>;
  }

  /// Get bank account balance
  Future<Map<String, dynamic>> getAccountBalance(String accountId) async {
    final response = await _dio.get('/bank-accounts/$accountId/balance');
    return response.data as Map<String, dynamic>;
  }

  /// Deposit from bank account to wallet
  Future<Map<String, dynamic>> depositFromBank({
    required String accountId,
    required double amount,
    String? description,
  }) async {
    final response = await _dio.post(
      '/bank-accounts/$accountId/deposit',
      data: {
        'amount': amount,
        if (description != null) 'description': description,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Withdraw from wallet to bank account
  Future<Map<String, dynamic>> withdrawToBank({
    required String accountId,
    required double amount,
    String? description,
  }) async {
    final response = await _dio.post(
      '/bank-accounts/$accountId/withdraw',
      data: {
        'amount': amount,
        if (description != null) 'description': description,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Unlink a bank account
  Future<Map<String, dynamic>> unlinkAccount(String accountId) async {
    final response = await _dio.delete('/bank-accounts/$accountId');
    return response.data as Map<String, dynamic>;
  }
}
