/// Bank Linking Provider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bank.dart';
import '../models/linked_bank_account.dart';

// State
class BankLinkingState {
  final bool isLoading;
  final String? error;
  final List<Bank> availableBanks;
  final List<LinkedBankAccount> linkedAccounts;
  final Bank? selectedBank;
  final String? pendingAccountId;
  final String? verificationCode;

  const BankLinkingState({
    this.isLoading = false,
    this.error,
    this.availableBanks = const [],
    this.linkedAccounts = const [],
    this.selectedBank,
    this.pendingAccountId,
    this.verificationCode,
  });

  BankLinkingState copyWith({
    bool? isLoading,
    String? error,
    List<Bank>? availableBanks,
    List<LinkedBankAccount>? linkedAccounts,
    Bank? selectedBank,
    String? pendingAccountId,
    String? verificationCode,
  }) {
    return BankLinkingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      availableBanks: availableBanks ?? this.availableBanks,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      selectedBank: selectedBank ?? this.selectedBank,
      pendingAccountId: pendingAccountId ?? this.pendingAccountId,
      verificationCode: verificationCode ?? this.verificationCode,
    );
  }
}

// Notifier
class BankLinkingNotifier extends Notifier<BankLinkingState> {
  @override
  BankLinkingState build() => const BankLinkingState();

  /// Load available banks
  Future<void> loadBanks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // In real app, call SDK
      // final sdk = ref.read(sdkProvider);
      // final banks = await sdk.banks.getAvailableBanks();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - will be replaced by API call
      final banks = _getMockBanks();

      state = state.copyWith(
        isLoading: false,
        availableBanks: banks,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load linked accounts
  Future<void> loadLinkedAccounts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // In real app, call SDK
      // final sdk = ref.read(sdkProvider);
      // final accounts = await sdk.banks.getLinkedAccounts();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - will be replaced by API call
      final accounts = _getMockLinkedAccounts();

      state = state.copyWith(
        isLoading: false,
        linkedAccounts: accounts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Select bank for linking
  void selectBank(Bank bank) {
    state = state.copyWith(selectedBank: bank);
  }

  /// Link bank account
  Future<bool> linkBankAccount({
    required String accountNumber,
    required String accountHolderName,
  }) async {
    if (state.selectedBank == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // In real app, call SDK
      // final sdk = ref.read(sdkProvider);
      // final result = await sdk.banks.linkAccount(
      //   bankCode: state.selectedBank!.code,
      //   accountNumber: accountNumber,
      //   accountHolderName: accountHolderName,
      // );

      // Mock delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock pending account
      final pendingId = 'bank-${DateTime.now().millisecondsSinceEpoch}';

      state = state.copyWith(
        isLoading: false,
        pendingAccountId: pendingId,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Verify account with OTP
  Future<bool> verifyWithOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // In real app, call SDK
      // final sdk = ref.read(sdkProvider);
      // await sdk.banks.verifyWithOtp(
      //   accountId: state.pendingAccountId!,
      //   otp: otp,
      // );

      // Mock delay
      await Future.delayed(const Duration(seconds: 1));

      // Reload linked accounts
      await loadLinkedAccounts();

      state = state.copyWith(
        isLoading: false,
        pendingAccountId: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Unlink bank account
  Future<bool> unlinkAccount(String accountId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // In real app, call SDK
      // final sdk = ref.read(sdkProvider);
      // await sdk.banks.unlinkAccount(accountId);

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from list
      final updated = state.linkedAccounts
          .where((account) => account.id != accountId)
          .toList();

      state = state.copyWith(
        isLoading: false,
        linkedAccounts: updated,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Set primary account
  Future<bool> setPrimaryAccount(String accountId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // In real app, call SDK
      // final sdk = ref.read(sdkProvider);
      // await sdk.banks.setPrimaryAccount(accountId);

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local state
      final updated = state.linkedAccounts.map((account) {
        return account.copyWith(isPrimary: account.id == accountId);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        linkedAccounts: updated,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Mock data helpers (will be removed when API is ready)
  List<Bank> _getMockBanks() {
    return [
      const Bank(
        code: 'NSIA',
        name: 'NSIA Banque',
        logoUrl: 'https://via.placeholder.com/100x100?text=NSIA',
        country: 'CI',
        verificationMethods: [BankVerificationMethod.otp],
        supportsBalanceCheck: true,
        supportsDirectDebit: true,
      ),
      const Bank(
        code: 'ECOBANK',
        name: 'Ecobank',
        logoUrl: 'https://via.placeholder.com/100x100?text=ECO',
        country: 'CI',
        verificationMethods: [BankVerificationMethod.otp],
        supportsBalanceCheck: false,
        supportsDirectDebit: true,
      ),
      const Bank(
        code: 'SGCI',
        name: 'Société Générale',
        logoUrl: 'https://via.placeholder.com/100x100?text=SG',
        country: 'CI',
        verificationMethods: [BankVerificationMethod.otp],
        supportsBalanceCheck: false,
        supportsDirectDebit: true,
      ),
      const Bank(
        code: 'BOA',
        name: 'Bank of Africa',
        logoUrl: 'https://via.placeholder.com/100x100?text=BOA',
        country: 'CI',
        verificationMethods: [BankVerificationMethod.otp],
        supportsBalanceCheck: false,
        supportsDirectDebit: true,
      ),
    ];
  }

  List<LinkedBankAccount> _getMockLinkedAccounts() {
    return [
      LinkedBankAccount(
        id: 'bank-1',
        walletId: 'wallet-1',
        bankCode: 'NSIA',
        bankName: 'NSIA Banque',
        bankLogoUrl: 'https://via.placeholder.com/100x100?text=NSIA',
        accountNumber: 'CI123456789012345',
        accountNumberMasked: '****2345',
        accountHolderName: 'Jean Kouassi',
        status: BankAccountStatus.verified,
        availableBalance: 500000,
        currency: 'XOF',
        isPrimary: true,
        lastVerifiedAt: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  /// Clear state
  void reset() {
    state = const BankLinkingState();
  }
}

// Provider
final bankLinkingProvider =
    NotifierProvider<BankLinkingNotifier, BankLinkingState>(
  BankLinkingNotifier.new,
);
