import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';

/// Repository for transfer operations.
class TransfersRepository {
  final TransfersService _service;

  TransfersRepository(this._service);

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

  /// Get transfer fee estimate (flat for now).
  Future<double> estimateFee({
    required double amount,
    required String currency,
  }) async {
    // TODO: Call backend fee endpoint when available
    return 0.0;
  }
}

final transfersRepositoryProvider = Provider<TransfersRepository>((ref) {
  final service = ref.watch(transfersServiceProvider);
  return TransfersRepository(service);
});
