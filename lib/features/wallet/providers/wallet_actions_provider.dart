import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';
import 'balance_provider.dart';

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
    String? pin,
  }) async {
    final response = await _dio.post('/withdraw/request', data: {
      'amount': amount,
      'provider': provider,
      'phoneNumber': phoneNumber,
      'currency': 'USDC',
      if (pin != null) 'pin': pin,
    });
    _ref.invalidate(walletBalanceProvider);
    return response.data as Map<String, dynamic>;
  }

  /// Generate a receive address/QR for the wallet.
  Future<Map<String, dynamic>> getReceiveInfo() async {
    final response = await _dio.get('/wallet/receive');
    return response.data as Map<String, dynamic>;
  }

  /// Get fee estimate for a transfer.
  Future<double> estimateFee({
    required double amount,
    required String type, // internal, external, withdrawal
  }) async {
    final response = await _dio.post('/transfers/estimate-fee', data: {
      'amount': amount,
      'type': type,
      'currency': 'USDC',
    });
    return (response.data['fee'] as num).toDouble();
  }
}

final walletActionsProvider = Provider<WalletActions>((ref) {
  return WalletActions(ref.watch(dioProvider), ref);
});
