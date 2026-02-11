import 'package:usdc_wallet/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/bank_linking/bank_linking_service.dart';

class BankLinkingRepository {
  final BankLinkingService _service;
  BankLinkingRepository(this._service);

  Future<dynamic> getBankAccounts() => _service.getLinkedAccounts();
  Future<dynamic> linkBankAccount({
    String? bankName, String? accountNumber, String? accountName,
    String? accountHolderName, String? bankCode, String? countryCode,
    String? routingNumber,
  }) => _service.linkBankAccount(
    accountNumber: accountNumber ?? '',
    bankCode: bankCode ?? bankName ?? '',
    accountHolderName: accountHolderName ?? accountName ?? '',
    countryCode: countryCode ?? 'CI',
  );
  Future<void> unlinkBankAccount(String id) => _service.unlinkAccount(id);
}

final bankLinkingRepositoryProvider = Provider<BankLinkingRepository>((ref) {
  return BankLinkingRepository(ref.watch(bankLinkingServiceProvider));
});
