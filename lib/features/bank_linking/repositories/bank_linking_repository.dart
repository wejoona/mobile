import 'package:usdc_wallet/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/bank_linking/bank_linking_service.dart';
import 'package:usdc_wallet/domain/entities/bank_account.dart';

/// Repository for bank linking operations.
class BankLinkingRepository {
  final BankLinkingService _service;

  BankLinkingRepository(this._service);

  /// Get all linked bank accounts.
  Future<List<BankAccount>> getBankAccounts() async {
    return _service.getBankAccounts();
  }

  /// Link a new bank account.
  Future<BankAccount> linkBankAccount({
    required String bankName,
    required String accountNumber,
    String? accountName,
    String? routingNumber,
  }) async {
    return _service.linkBankAccount(
      bankName: bankName,
      accountNumber: accountNumber,
      accountName: accountName,
      routingNumber: routingNumber,
    );
  }

  /// Remove a linked bank account.
  Future<void> unlinkBankAccount(String id) async {
    return _service.unlinkBankAccount(id);
  }
}

final bankLinkingRepositoryProvider = Provider<BankLinkingRepository>((ref) {
  final service = ref.watch(bankLinkingServiceProvider);
  return BankLinkingRepository(service);
});
