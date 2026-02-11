import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/wallet/wallet_service.dart';
import '../../../domain/entities/savings_pot.dart';

/// Repository for savings pot operations.
class SavingsPotsRepository {
  final WalletService _walletService;

  SavingsPotsRepository(this._walletService);

  /// Get all savings pots.
  Future<List<SavingsPot>> getSavingsPots() async {
    // Savings pots are fetched as part of wallet data
    final wallet = await _walletService.getWallet();
    return wallet.savingsPots ?? [];
  }
}

final savingsPotsRepositoryProvider = Provider<SavingsPotsRepository>((ref) {
  final walletService = ref.watch(walletServiceProvider);
  return SavingsPotsRepository(walletService);
});
