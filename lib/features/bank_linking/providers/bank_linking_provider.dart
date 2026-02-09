/// Bank Linking Provider
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';
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

  Dio get _dio => ref.read(dioProvider);

  /// Load available banks
  /// GET /banks?country=CI
  Future<void> loadBanks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/banks', queryParameters: {
        'country': 'CI',
      });

      final data = response.data as Map<String, dynamic>;
      final banksJson = data['banks'] as List;
      final banks = banksJson
          .map((json) => Bank.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        availableBanks: banks,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load linked accounts
  /// GET /bank-accounts
  Future<void> loadLinkedAccounts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/bank-accounts');

      final data = response.data as Map<String, dynamic>;
      final accountsJson = data['accounts'] as List;
      final accounts = accountsJson
          .map((json) => LinkedBankAccount.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        linkedAccounts: accounts,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
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
  /// POST /bank-accounts { bank_code, account_number, account_holder_name, country_code }
  Future<bool> linkBankAccount({
    required String accountNumber,
    required String accountHolderName,
  }) async {
    if (state.selectedBank == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/bank-accounts', data: {
        'bank_code': state.selectedBank!.code,
        'account_number': accountNumber,
        'account_holder_name': accountHolderName,
        'country_code': state.selectedBank!.country,
      });

      final linkData = response.data as Map<String, dynamic>;
      final accountId = linkData['id'] as String?;

      state = state.copyWith(
        isLoading: false,
        pendingAccountId: accountId,
      );

      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Verify account with OTP
  /// POST /bank-accounts/:id/verify { otp }
  Future<bool> verifyWithOtp(String otp) async {
    if (state.pendingAccountId == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.post(
        '/bank-accounts/${state.pendingAccountId}/verify',
        data: {'otp': otp},
      );

      // Reload linked accounts to get updated list
      await loadLinkedAccounts();

      state = state.copyWith(
        isLoading: false,
        pendingAccountId: null,
      );

      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Unlink bank account
  /// DELETE /bank-accounts/:id
  Future<bool> unlinkAccount(String accountId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.delete('/bank-accounts/$accountId');

      // Remove from local list
      final updated = state.linkedAccounts
          .where((account) => account.id != accountId)
          .toList();

      state = state.copyWith(
        isLoading: false,
        linkedAccounts: updated,
      );

      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Set primary account
  /// POST /bank-accounts/:id/set-primary
  Future<bool> setPrimaryAccount(String accountId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.post('/bank-accounts/$accountId/set-primary');

      // Update local state
      final updated = state.linkedAccounts.map((account) {
        return account.copyWith(isPrimary: account.id == accountId);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        linkedAccounts: updated,
      );

      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiException.fromDioError(e).message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
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
