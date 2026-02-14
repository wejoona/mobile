import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';

/// Repository for transfer operations.
class TransfersRepository {
  final TransfersService _service;
  final Dio _dio;

  TransfersRepository(this._service, this._dio);

  /// Send an internal transfer to another Korido user.
  Future<dynamic> sendTransfer({
    required String recipientPhone,
    required double amount,
    String currency = 'USDC',
    String? description,
  }) async {
    return _service.createInternalTransfer(
      recipientPhone: recipientPhone,
      amount: amount,
      note: description,
    );
  }

  /// Get transfer fee estimate from the backend.
  Future<double> estimateFee({
    required double amount,
    required String currency,
    String? recipientType,
  }) async {
    try {
      final response = await _dio.post('/transfers/estimate-fee', data: {
        'amount': amount,
        'currency': currency,
        if (recipientType != null) 'recipientType': recipientType,
      });
      final data = response.data as Map<String, dynamic>;
      return (data['fee'] as num?)?.toDouble() ?? 0.0;
    } on DioException {
      // Fallback: free internal transfers
      return 0.0;
    }
  }
}

final transfersRepositoryProvider = Provider<TransfersRepository>((ref) {
  final service = ref.watch(transfersServiceProvider);
  final dio = ref.watch(dioProvider);
  return TransfersRepository(service, dio);
});
