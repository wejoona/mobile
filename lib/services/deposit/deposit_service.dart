import 'package:dio/dio.dart';
import '../../features/deposit/models/deposit_request.dart';
import '../../features/deposit/models/deposit_response.dart';
import '../../features/deposit/models/exchange_rate.dart';

/// Deposit Service
///
/// Handles mobile money deposit operations.
class DepositService {
  final Dio _dio;

  DepositService(this._dio);

  /// Initiate a deposit
  Future<DepositResponse> initiateDeposit(DepositRequest request) async {
    final response = await _dio.post(
      '/wallet/deposit',
      data: request.toJson(),
    );
    return DepositResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get deposit status
  Future<DepositResponse> getDepositStatus(String depositId) async {
    final response = await _dio.get('/wallet/deposit/$depositId');
    return DepositResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get deposit channels
  Future<Map<String, dynamic>> getDepositChannels({String? currency}) async {
    final response = await _dio.get(
      '/wallet/deposit/channels',
      queryParameters: {
        if (currency != null) 'currency': currency,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get exchange rate (XOF to USD)
  Future<ExchangeRate> getExchangeRate({
    String from = 'XOF',
    String to = 'USD',
  }) async {
    final response = await _dio.get(
      '/wallet/rate',
      queryParameters: {
        'sourceCurrency': from,
        'targetCurrency': to,
      },
    );
    return ExchangeRate.fromJson(response.data as Map<String, dynamic>);
  }
}
