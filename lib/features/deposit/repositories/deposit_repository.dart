import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';

class DepositRepository {
  final WalletService _service;
  DepositRepository(this._service);

  Future<dynamic> getDepositMethods() => _service.getDepositChannels();
  Future<dynamic> initiateMobileMoneyDeposit({
    String? amount,
    String? provider,
    String? mobileNumber,
    String? sourceCurrency,
    String? countryCode,
  }) {
    final channelId = provider?.trim();
    if (channelId == null || channelId.isEmpty) {
      throw ArgumentError('Deposit channel is required');
    }
    final currency = sourceCurrency?.trim().toUpperCase();
    if (currency == null || currency.isEmpty) {
      throw ArgumentError('Deposit source currency is required');
    }
    return _service.initiateDeposit(
      amount: double.tryParse(amount ?? '0') ?? 0,
      sourceCurrency: currency,
      channelId: channelId,
      phoneNumber: mobileNumber ?? '',
      countryCode: countryCode,
    );
  }
}

final depositRepositoryProvider = Provider<DepositRepository>((ref) {
  return DepositRepository(ref.watch(walletServiceProvider));
});
