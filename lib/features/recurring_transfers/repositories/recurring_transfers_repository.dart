import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/recurring_transfers/recurring_transfers_service.dart';
import '../../../domain/entities/recurring_transfer.dart';

/// Repository for recurring transfer operations.
class RecurringTransfersRepository {
  final RecurringTransfersService _service;

  RecurringTransfersRepository(this._service);

  /// Get all recurring transfers.
  Future<List<RecurringTransfer>> getRecurringTransfers() async {
    return _service.getRecurringTransfers();
  }

  /// Cancel a recurring transfer.
  Future<void> cancelRecurringTransfer(String id) async {
    return _service.cancelRecurringTransfer(id);
  }
}

final recurringTransfersRepositoryProvider =
    Provider<RecurringTransfersRepository>((ref) {
  final service = ref.watch(recurringTransfersServiceProvider);
  return RecurringTransfersRepository(service);
});
