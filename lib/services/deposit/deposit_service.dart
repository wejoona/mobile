import 'package:dio/dio.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_request.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';

/// Deposit Service
///
/// Handles mobile money deposit operations via the Korido API.
/// Mobile only talks to /deposits/* — never to payment providers directly.
class DepositService {
  final Dio _dio;

  DepositService(this._dio);

  /// Get available deposit providers
  Future<List<Map<String, dynamic>>> getProviders() async {
    final response = await _dio.get('/deposits/providers');
    final data = response.data;
    if (data is Map<String, dynamic> && data['providers'] != null) {
      return List<Map<String, dynamic>>.from(data['providers'] as List);
    }
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  /// Initiate a deposit — returns payment method type + instructions
  Future<DepositResponse> initiateDeposit(InitiateDepositRequest request) async {
    final response = await _dio.post(
      '/deposits/initiate',
      data: request.toJson(),
    );
    return DepositResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Confirm a deposit (submit OTP or trigger PUSH)
  Future<DepositResponse> confirmDeposit(ConfirmDepositRequest request) async {
    final response = await _dio.post(
      '/deposits/confirm',
      data: request.toJson(),
    );
    return DepositResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get deposit status (for polling)
  Future<DepositResponse> getDepositStatus(String depositId) async {
    final response = await _dio.get('/deposits/$depositId');
    return DepositResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// List user's deposits
  Future<List<DepositResponse>> listDeposits({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/deposits',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['deposits'] != null) {
      return (data['deposits'] as List)
          .map((e) => DepositResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is List) {
      return data
          .map((e) => DepositResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Initiate a mobile money deposit
  Future<DepositResponse> initiateMobileMoneyDeposit(Map<String, dynamic> data) async {
    final response = await _dio.post('/deposits/initiate', data: data);
    return DepositResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get available deposit methods (alias for getProviders)
  Future<List<Map<String, dynamic>>> getDepositMethods() async {
    return getProviders();
  }

  /// Get exchange rate (XOF to USD)
  Future<ExchangeRate> getExchangeRate({
    String from = 'XOF',
    String to = 'USD',
  }) async {
    final response = await _dio.get(
      '/deposits/rate',
      queryParameters: {
        'sourceCurrency': from,
        'targetCurrency': to,
      },
    );
    return ExchangeRate.fromJson(response.data as Map<String, dynamic>);
  }
}
