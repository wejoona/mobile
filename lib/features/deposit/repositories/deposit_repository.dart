import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';

class DepositRepository {
  final WalletService _service;
  DepositRepository(this._service);

  Future<dynamic> getDepositMethods() => _service.getDepositChannels();
  Future<dynamic> initiateMobileMoneyDeposit({String? amount, String? provider, String? mobileNumber}) =>
    _service.initiateDeposit(amount: double.tryParse(amount ?? '0') ?? 0, sourceCurrency: 'XOF', channelId: provider ?? 'orange_money');
}

final depositRepositoryProvider = Provider<DepositRepository>((ref) {
  return DepositRepository(ref.watch(walletServiceProvider));
});
