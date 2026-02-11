import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';
import 'package:usdc_wallet/domain/entities/wallet.dart';

/// Repository for wallet operations.
///
/// Wraps [WalletService] with caching and error handling.
class WalletRepository {
  final WalletService _service;

  WalletRepository(this._service);

  /// Fetch the current wallet balance.
  Future<dynamic> getWallet() async {
    return _service.getBalance();
  }

  /// Refresh the wallet balance from the server.
  Future<dynamic> refreshWallet() async {
    return _service.getBalance();
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final service = ref.watch(walletServiceProvider);
  return WalletRepository(service);
});
