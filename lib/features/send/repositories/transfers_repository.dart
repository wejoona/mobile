import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';

/// Repository for transfer operations.
class TransfersRepository {
  final TransfersService _service;

  TransfersRepository(this._service);

  /// Send an internal transfer to another Korido user.
  Future<dynamic> sendTransfer({
    String? recipientId,
    String? recipientPhone,
    String? recipientUsername,
    required double amount,
    required String pinToken,
    required String idempotencyKey,
    String currency = 'USDC',
    String? description,
  }) async {
    return _service.createInternalTransfer(
      recipientId: recipientId,
      recipientPhone: recipientPhone,
      recipientUsername: recipientUsername,
      amount: amount,
      note: description,
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
    );
  }

  /// Get transfer fee estimate from the backend.
  Future<double> estimateFee({
    required double amount,
    required String currency,
    String? recipientType,
  }) async {
    // Internal transfers are free in the current mobile flow. External fee
    // estimates are handled by WalletActionsProvider via the backend endpoint.
    return 0.0;
  }
}

final transfersRepositoryProvider = Provider<TransfersRepository>((ref) {
  final service = ref.watch(transfersServiceProvider);
  return TransfersRepository(service);
});
