import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/deposit/deposit_service.dart';

/// Repository for deposit operations.
class DepositRepository {
  final DepositService _service;

  DepositRepository(this._service);

  /// Initiate a deposit via mobile money.
  Future<Map<String, dynamic>> initiateMobileMoneyDeposit({
    required double amount,
    required String mobileNumber,
    required String provider,
  }) async {
    return _service.initiateMobileMoneyDeposit(
      amount: amount,
      mobileNumber: mobileNumber,
      provider: provider,
    );
  }

  /// Get available deposit methods.
  Future<List<Map<String, dynamic>>> getDepositMethods() async {
    return _service.getDepositMethods();
  }
}

final depositRepositoryProvider = Provider<DepositRepository>((ref) {
  final service = ref.watch(depositServiceProvider);
  return DepositRepository(service);
});
