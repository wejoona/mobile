import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/savings_pots/savings_pots_service.dart'
    as svc;
import 'package:usdc_wallet/domain/entities/savings_pot.dart';

/// Repository for savings pot operations.
class SavingsPotsRepository {
  final svc.SavingsPotsService _service;

  SavingsPotsRepository(this._service);

  /// Get all savings pots from the backend.
  Future<List<SavingsPot>> getSavingsPots() async {
    return _service.getAll();
  }

  /// Get a single savings pot by ID.
  Future<SavingsPot> getSavingsPot(String id) async {
    return _service.getById(id);
  }

  /// Create a new savings pot.
  Future<SavingsPot> createSavingsPot({
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String currency = 'USDC',
  }) async {
    return _service.create(
      name: name,
      targetAmount: targetAmount,
      targetDate: targetDate,
      currency: currency,
    );
  }

  /// Deposit into a savings pot.
  Future<SavingsPot> depositToPot(String potId, double amount) async {
    return _service.deposit(potId, amount);
  }

  /// Withdraw from a savings pot.
  Future<SavingsPot> withdrawFromPot(String potId, double amount) async {
    return _service.withdraw(potId, amount);
  }

  /// Delete a savings pot.
  Future<void> deletePot(String potId) async {
    return _service.delete(potId);
  }
}

final savingsPotsRepositoryProvider = Provider<SavingsPotsRepository>((ref) {
  final service = ref.watch(svc.savingsPotsServiceProvider);
  return SavingsPotsRepository(service);
});
