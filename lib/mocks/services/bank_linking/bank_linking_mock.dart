/// Bank Linking Mock Implementation
library;

import 'package:usdc_wallet/features/bank_linking/models/bank.dart';
import 'package:usdc_wallet/features/bank_linking/models/linked_bank_account.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Bank Linking Mock State
class BankLinkingMockState {
  static final List<Bank> _banks = [
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

  static final List<LinkedBankAccount> _linkedAccounts = [
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

  static List<Bank> get banks => List.unmodifiable(_banks);
  static List<LinkedBankAccount> get linkedAccounts =>
      List.unmodifiable(_linkedAccounts);

  static void reset() {
    // Reset to initial state if needed
  }

  static Bank? findBankByCode(String code) {
    try {
      return _banks.firstWhere((b) => b.code == code);
    } catch (e) {
      return null;
    }
  }

  static LinkedBankAccount? findAccountById(String id) {
    try {
      return _linkedAccounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  static void addLinkedAccount(LinkedBankAccount account) {
    _linkedAccounts.add(account);
  }

  static void removeLinkedAccount(String id) {
    _linkedAccounts.removeWhere((a) => a.id == id);
  }

  static void updateLinkedAccount(String id, LinkedBankAccount updated) {
    final index = _linkedAccounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _linkedAccounts[index] = updated;
    }
  }

  static void setPrimaryAccount(String id) {
    for (var i = 0; i < _linkedAccounts.length; i++) {
      _linkedAccounts[i] = _linkedAccounts[i].copyWith(
        isPrimary: _linkedAccounts[i].id == id,
      );
    }
  }
}

/// Bank Linking Mock Service
class BankLinkingMock {
  static void register(MockInterceptor interceptor) {
    // GET /api/v1/banks - Get available banks
    interceptor.register(
      method: 'GET',
      path: '/api/v1/banks',
      handler: _handleGetBanks,
    );

    // GET /api/v1/bank-accounts - Get linked accounts
    interceptor.register(
      method: 'GET',
      path: '/api/v1/bank-accounts',
      handler: _handleGetLinkedAccounts,
    );

    // GET /api/v1/bank-accounts/:id - Get single account
    interceptor.register(
      method: 'GET',
      path: '/api/v1/bank-accounts/:id',
      handler: _handleGetLinkedAccount,
    );

    // POST /api/v1/bank-accounts - Link new account
    interceptor.register(
      method: 'POST',
      path: '/api/v1/bank-accounts',
      handler: _handleLinkAccount,
    );

    // POST /api/v1/bank-accounts/:id/verify - Verify account
    interceptor.register(
      method: 'POST',
      path: '/api/v1/bank-accounts/:id/verify',
      handler: _handleVerifyAccount,
    );

    // DELETE /api/v1/bank-accounts/:id - Unlink account
    interceptor.register(
      method: 'DELETE',
      path: '/api/v1/bank-accounts/:id',
      handler: _handleUnlinkAccount,
    );

    // POST /api/v1/bank-accounts/:id/set-primary - Set primary account
    interceptor.register(
      method: 'POST',
      path: '/api/v1/bank-accounts/:id/set-primary',
      handler: _handleSetPrimary,
    );

    // GET /api/v1/bank-accounts/:id/balance - Get account balance
    interceptor.register(
      method: 'GET',
      path: '/api/v1/bank-accounts/:id/balance',
      handler: _handleGetBalance,
    );

    // POST /api/v1/bank-accounts/:id/deposit - Deposit from bank
    interceptor.register(
      method: 'POST',
      path: '/api/v1/bank-accounts/:id/deposit',
      handler: _handleDeposit,
    );

    // POST /api/v1/bank-accounts/:id/withdraw - Withdraw to bank
    interceptor.register(
      method: 'POST',
      path: '/api/v1/bank-accounts/:id/withdraw',
      handler: _handleWithdraw,
    );
  }

  /// Handle GET /api/v1/banks
  static Future<MockResponse> _handleGetBanks(options) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return MockResponse.success({
      'banks': BankLinkingMockState.banks.map((b) => b.toJson()).toList(),
    });
  }

  /// Handle GET /api/v1/bank-accounts
  static Future<MockResponse> _handleGetLinkedAccounts(options) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return MockResponse.success({
      'accounts': BankLinkingMockState.linkedAccounts
          .map((a) => a.toJson())
          .toList(),
    });
  }

  /// Handle GET /api/v1/bank-accounts/:id
  static Future<MockResponse> _handleGetLinkedAccount(options) async {
    // ignore: avoid_dynamic_calls
    final params = options.extractPathParams('/api/v1/bank-accounts/:id');
    // ignore: avoid_dynamic_calls
    final id = params['id'];

    final account = BankLinkingMockState.findAccountById(id);

    if (account == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Bank account not found'},
      );
    }

    return MockResponse.success(account.toJson());
  }

  /// Handle POST /api/v1/bank-accounts
  static Future<MockResponse> _handleLinkAccount(options) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // ignore: avoid_dynamic_calls
    final data = options.data as Map<String, dynamic>;

    final bankCode = data['bank_code'] as String;
    final bank = BankLinkingMockState.findBankByCode(bankCode);

    if (bank == null) {
      return MockResponse(
        statusCode: 400,
        data: {'message': 'Invalid bank code'},
      );
    }

    final newAccount = LinkedBankAccount(
      id: 'bank-${DateTime.now().millisecondsSinceEpoch}',
      walletId: 'wallet-1',
      bankCode: bankCode,
      bankName: bank.name,
      bankLogoUrl: bank.logoUrl,
      accountNumber: data['account_number'] as String,
      accountNumberMasked:
          '****${(data['account_number'] as String).substring((data['account_number'] as String).length - 4)}',
      accountHolderName: data['account_holder_name'] as String,
      status: BankAccountStatus.pending,
      currency: 'XOF',
      isPrimary: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    BankLinkingMockState.addLinkedAccount(newAccount);

    return MockResponse.created(newAccount.toJson());
  }

  /// Handle POST /api/v1/bank-accounts/:id/verify
  static Future<MockResponse> _handleVerifyAccount(options) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // ignore: avoid_dynamic_calls
    final params = options.extractPathParams('/api/v1/bank-accounts/:id/verify');
    // ignore: avoid_dynamic_calls
    final id = params['id'];
    // ignore: avoid_dynamic_calls
    final data = options.data as Map<String, dynamic>;
    final otp = data['otp'] as String;

    final account = BankLinkingMockState.findAccountById(id);

    if (account == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Bank account not found'},
      );
    }

    // Mock OTP validation (accept "123456")
    if (otp != '123456') {
      return MockResponse(
        statusCode: 400,
        data: {'message': 'Invalid OTP code'},
      );
    }

    final verified = account.copyWith(
      status: BankAccountStatus.verified,
      lastVerifiedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    BankLinkingMockState.updateLinkedAccount(id, verified);

    return MockResponse.success(verified.toJson());
  }

  /// Handle DELETE /api/v1/bank-accounts/:id
  static Future<MockResponse> _handleUnlinkAccount(options) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // ignore: avoid_dynamic_calls
    final params = options.extractPathParams('/api/v1/bank-accounts/:id');
    // ignore: avoid_dynamic_calls
    final id = params['id'];

    final account = BankLinkingMockState.findAccountById(id);

    if (account == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Bank account not found'},
      );
    }

    BankLinkingMockState.removeLinkedAccount(id);

    return MockResponse.success({
      'success': true,
      'message': 'Bank account unlinked successfully',
    });
  }

  /// Handle POST /api/v1/bank-accounts/:id/set-primary
  static Future<MockResponse> _handleSetPrimary(options) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final params =
        // ignore: avoid_dynamic_calls
        options.extractPathParams('/api/v1/bank-accounts/:id/set-primary');
    // ignore: avoid_dynamic_calls
    final id = params['id'];

    final account = BankLinkingMockState.findAccountById(id);

    if (account == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Bank account not found'},
      );
    }

    BankLinkingMockState.setPrimaryAccount(id);

    return MockResponse.success({
      'success': true,
      'message': 'Primary account updated',
    });
  }

  /// Handle GET /api/v1/bank-accounts/:id/balance
  static Future<MockResponse> _handleGetBalance(options) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // ignore: avoid_dynamic_calls
    final params = options.extractPathParams('/api/v1/bank-accounts/:id/balance');
    // ignore: avoid_dynamic_calls
    final id = params['id'];

    final account = BankLinkingMockState.findAccountById(id);

    if (account == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Bank account not found'},
      );
    }

    if (account.status != BankAccountStatus.verified) {
      return MockResponse(
        statusCode: 400,
        data: {'message': 'Account not verified'},
      );
    }

    // Mock balance
    return MockResponse.success({
      'balance': 500000.0,
      'currency': 'XOF',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Handle POST /api/v1/bank-accounts/:id/deposit
  static Future<MockResponse> _handleDeposit(options) async {
    await Future.delayed(const Duration(seconds: 2));

    // ignore: avoid_dynamic_calls
    final params = options.extractPathParams('/api/v1/bank-accounts/:id/deposit');
    // ignore: avoid_dynamic_calls
    final id = params['id'];
    // ignore: avoid_dynamic_calls
    final data = options.data as Map<String, dynamic>;
    final amount = data['amount'] as double;

    final account = BankLinkingMockState.findAccountById(id);

    if (account == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Bank account not found'},
      );
    }

    if (account.status != BankAccountStatus.verified) {
      return MockResponse(
        statusCode: 400,
        data: {'message': 'Account not verified'},
      );
    }

    // Mock successful deposit
    return MockResponse.success({
      'transaction_id': 'tx-${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'status': 'completed',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Handle POST /api/v1/bank-accounts/:id/withdraw
  static Future<MockResponse> _handleWithdraw(options) async {
    await Future.delayed(const Duration(seconds: 2));

    final params =
        // ignore: avoid_dynamic_calls
        options.extractPathParams('/api/v1/bank-accounts/:id/withdraw');
    // ignore: avoid_dynamic_calls
    final id = params['id'];
    // ignore: avoid_dynamic_calls
    final data = options.data as Map<String, dynamic>;
    final amount = data['amount'] as double;

    final account = BankLinkingMockState.findAccountById(id);

    if (account == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Bank account not found'},
      );
    }

    if (account.status != BankAccountStatus.verified) {
      return MockResponse(
        statusCode: 400,
        data: {'message': 'Account not verified'},
      );
    }

    // Mock successful withdrawal
    return MockResponse.success({
      'transaction_id': 'tx-${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'status': 'pending',
      'estimated_completion': DateTime.now()
          .add(const Duration(hours: 2))
          .toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
