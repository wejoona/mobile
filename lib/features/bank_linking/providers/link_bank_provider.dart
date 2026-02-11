import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/config/west_african_banks.dart';
import 'package:usdc_wallet/features/bank_linking/providers/bank_accounts_provider.dart';

/// Link bank account flow state.
class LinkBankState {
  final bool isLoading;
  final String? error;
  final WestAfricanBank? selectedBank;
  final String? accountNumber;
  final String? accountName;
  final bool isComplete;

  const LinkBankState({this.isLoading = false, this.error, this.selectedBank, this.accountNumber, this.accountName, this.isComplete = false});

  LinkBankState copyWith({bool? isLoading, String? error, WestAfricanBank? selectedBank, String? accountNumber, String? accountName, bool? isComplete}) => LinkBankState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    selectedBank: selectedBank ?? this.selectedBank,
    accountNumber: accountNumber ?? this.accountNumber,
    accountName: accountName ?? this.accountName,
    isComplete: isComplete ?? this.isComplete,
  );
}

/// Link bank notifier.
class LinkBankNotifier extends Notifier<LinkBankState> {
  @override
  LinkBankState build() => const LinkBankState();

  void selectBank(WestAfricanBank bank) => state = state.copyWith(selectedBank: bank);
  void setAccountNumber(String number) => state = state.copyWith(accountNumber: number);
  void setAccountName(String name) => state = state.copyWith(accountName: name);

  Future<void> link() async {
    if (state.selectedBank == null || state.accountNumber == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(bankLinkingServiceProvider);
      await service.linkBankAccount(
        bankCode: state.selectedBank!.swiftCode,
        accountNumber: state.accountNumber!,
        accountName: state.accountName,
      );
      state = state.copyWith(isLoading: false, isComplete: true);
      ref.invalidate(bankAccountsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const LinkBankState();
}

final linkBankProvider = NotifierProvider<LinkBankNotifier, LinkBankState>(LinkBankNotifier.new);
