import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/transfers/transfers_service.dart';
import '../../../domain/dto/requests/send_transfer_request.dart';
import '../../../domain/entities/transfer.dart';

/// Repository for transfer operations.
class TransfersRepository {
  final TransfersService _service;

  TransfersRepository(this._service);

  /// Send a transfer to another Korido user.
  Future<Transfer> sendTransfer(SendTransferRequest request) async {
    return _service.sendTransfer(
      recipientPhone: request.recipientPhone,
      amount: request.amount,
      currency: request.currency,
      description: request.description,
    );
  }

  /// Get transfer fee estimate.
  Future<double> estimateFee({
    required double amount,
    required String currency,
  }) async {
    return _service.estimateFee(amount: amount, currency: currency);
  }
}

final transfersRepositoryProvider = Provider<TransfersRepository>((ref) {
  final service = ref.watch(transfersServiceProvider);
  return TransfersRepository(service);
});
