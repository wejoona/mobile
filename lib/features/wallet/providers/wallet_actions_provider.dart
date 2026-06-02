import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/utils/amount_conversion.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';

/// Wallet-level actions (withdraw, request money).
class WalletActions {
  final dynamic _dio;
  final Ref _ref;

  WalletActions(this._dio, this._ref);

  /// Request a withdrawal to mobile money.
  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String provider, // orangeMoney, mtnMomo, wave, moovMoney
    required String phoneNumber,
    String? pinToken,
    String? idempotencyKey,
  }) async {
    // ignore: avoid_dynamic_calls
    final response = await _dio.post(
      '/withdrawals/initiate',
      data: {
        'amount': toCents(amount),
        'providerCode': _providerToCode(provider),
        'phoneNumber': phoneNumber,
        'currency': 'XOF',
      },
      options: pinToken == null
          ? null
          : Options(
              headers: transactionHeaders(
                pinToken: pinToken,
                idempotencyKey: idempotencyKey,
              ),
            ),
    );
    _ref.invalidate(walletBalanceProvider);
    // ignore: avoid_dynamic_calls
    return response.data as Map<String, dynamic>;
  }

  /// Generate a receive address/QR for the wallet.
  Future<Map<String, dynamic>> getReceiveInfo() async {
    // ignore: avoid_dynamic_calls
    final response = await _dio.get('/wallet/receive');
    // ignore: avoid_dynamic_calls
    return response.data as Map<String, dynamic>;
  }

  /// Get fee estimate for a transfer.
  Future<double> estimateFee({
    required double amount,
    required String type, // internal, external, withdrawal
  }) async {
    if (type == 'external') {
      // ignore: avoid_dynamic_calls
      final response = await _dio.get(
        '/wallet/transfer/external/estimate-fee',
        queryParameters: {'amount': amount, 'network': 'polygon'},
      );
      // ignore: avoid_dynamic_calls
      return (response.data['estimatedFee'] as num?)?.toDouble() ?? 0.0;
    }
    if (type == 'withdrawal') {
      return amount * 0.005;
    }
    return 0.0;
  }

  String _providerToCode(String provider) {
    switch (provider.toLowerCase().replaceAll('_', '')) {
      case 'omci':
      case 'orangemoney':
        return 'OMCI';
      case 'mtnci':
      case 'mtnmomo':
        return 'MTNCI';
      case 'moovci':
      case 'moovmoney':
        return 'MOOVCI';
      case 'waveci':
      case 'wave':
        return 'WAVECI';
      default:
        return provider;
    }
  }
}

final walletActionsProvider = Provider<WalletActions>((ref) {
  return WalletActions(ref.watch(dioProvider), ref);
});
