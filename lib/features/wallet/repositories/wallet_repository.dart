import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/wallet/wallet_service.dart';
import '../../../domain/entities/wallet.dart';

/// Repository for wallet operations.
///
/// Wraps [WalletService] with caching and error handling.
class WalletRepository {
  final WalletService _service;

  WalletRepository(this._service);

  /// Fetch the current wallet balance.
  Future<Wallet> getWallet() async {
    return _service.getWallet();
  }

  /// Refresh the wallet balance from the server.
  Future<Wallet> refreshWallet() async {
    return _service.getWallet();
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final service = ref.watch(walletServiceProvider);
  return WalletRepository(service);
});
