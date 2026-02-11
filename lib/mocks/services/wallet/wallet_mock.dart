/// Wallet Mock Implementation
///
/// Mock handlers for wallet endpoints.
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_data_generator.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_mock.dart';
import 'wallet_contract.dart';

/// Wallet mock state
class WalletMockState {
  static final Map<String, WalletResponse> wallets = {};
  static final Map<String, List<DepositResponse>> pendingDeposits = {};
  static final Map<String, List<WithdrawResponse>> pendingWithdrawals = {};

  static void reset() {
    wallets.clear();
    pendingDeposits.clear();
    pendingWithdrawals.clear();
  }

  /// Get or create wallet for user
  static WalletResponse? getWallet(String userId) {
    return wallets[userId];
  }

  /// Create wallet for user
  static WalletResponse createWallet(String userId, {String network = 'polygon'}) {
    final wallet = WalletResponse(
      id: MockDataGenerator.uuid(),
      userId: userId,
      address: MockDataGenerator.walletAddress(),
      network: network,
      balanceUsdc: MockDataGenerator.balance(min: 0, max: 5000),
      balanceLocal: MockDataGenerator.balance(min: 0, max: 3000000),
      localCurrency: 'XOF',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    wallets[userId] = wallet;
    return wallet;
  }

  /// Update wallet balance
  static void updateBalance(String userId, double usdcDelta, double localDelta) {
    final wallet = wallets[userId];
    if (wallet == null) return;

    wallets[userId] = WalletResponse(
      id: wallet.id,
      userId: wallet.userId,
      address: wallet.address,
      network: wallet.network,
      balanceUsdc: wallet.balanceUsdc + usdcDelta,
      balanceLocal: wallet.balanceLocal + localDelta,
      localCurrency: wallet.localCurrency,
      createdAt: wallet.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Wallet mock handlers
class WalletMock {
  /// Register all wallet mock handlers
  static void register(MockInterceptor interceptor) {
    // GET /wallet
    interceptor.register(
      method: 'GET',
      path: '/wallet',
      handler: _handleGetWallet,
    );

    // POST /wallet
    interceptor.register(
      method: 'POST',
      path: '/wallet',
      handler: _handleCreateWallet,
    );

    // GET /wallet/balance
    interceptor.register(
      method: 'GET',
      path: '/wallet/balance',
      handler: _handleGetBalance,
    );

    // POST /wallet/deposit
    interceptor.register(
      method: 'POST',
      path: '/wallet/deposit',
      handler: _handleDeposit,
    );

    // POST /wallet/withdraw
    interceptor.register(
      method: 'POST',
      path: '/wallet/withdraw',
      handler: _handleWithdraw,
    );

    // GET /wallet/deposit/providers
    interceptor.register(
      method: 'GET',
      path: '/wallet/deposit/providers',
      handler: _handleGetDepositProviders,
    );

    // GET /wallet/withdraw/providers
    interceptor.register(
      method: 'GET',
      path: '/wallet/withdraw/providers',
      handler: _handleGetWithdrawProviders,
    );

    // GET /wallet/limits
    interceptor.register(
      method: 'GET',
      path: '/wallet/limits',
      handler: _handleGetLimits,
    );
  }

  static Future<MockResponse> _handleGetWallet(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final wallet = WalletMockState.getWallet(userId);
    if (wallet == null) {
      return MockResponse.notFound('Wallet not found');
    }

    return MockResponse.success(wallet.toJson());
  }

  static Future<MockResponse> _handleCreateWallet(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    // Check if wallet already exists
    if (WalletMockState.getWallet(userId) != null) {
      return MockResponse.badRequest('Wallet already exists');
    }

    final data = options.data as Map<String, dynamic>?;
    final network = data?['network'] as String? ?? 'polygon';

    final wallet = WalletMockState.createWallet(userId, network: network);
    return MockResponse.created(wallet.toJson());
  }

  static Future<MockResponse> _handleGetBalance(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final wallet = WalletMockState.getWallet(userId);
    if (wallet == null) {
      return MockResponse.notFound('Wallet not found');
    }

    return MockResponse.success({
      'balanceUsdc': wallet.balanceUsdc,
      'balanceLocal': wallet.balanceLocal,
      'localCurrency': wallet.localCurrency,
    });
  }

  static Future<MockResponse> _handleDeposit(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final wallet = WalletMockState.getWallet(userId);
    if (wallet == null) {
      return MockResponse.notFound('Wallet not found');
    }

    final data = options.data as Map<String, dynamic>?;
    final amount = (data?['amount'] as num?)?.toDouble() ?? 0;
    final provider = data?['provider'] as String? ?? 'orange_money';
    // phoneNumber from data is stored in the deposit metadata on real backend

    if (amount <= 0) {
      return MockResponse.badRequest('Invalid amount');
    }

    final deposit = DepositResponse(
      id: MockDataGenerator.uuid(),
      status: 'pending',
      amount: amount,
      provider: provider,
      instructions: 'Dial *144*1*${MockDataGenerator.integer(min: 100000, max: 999999)}# to complete the deposit',
      reference: MockDataGenerator.transactionRef(),
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
    );

    WalletMockState.pendingDeposits[userId] ??= [];
    WalletMockState.pendingDeposits[userId]!.add(deposit);

    return MockResponse.created(deposit.toJson());
  }

  static Future<MockResponse> _handleWithdraw(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final wallet = WalletMockState.getWallet(userId);
    if (wallet == null) {
      return MockResponse.notFound('Wallet not found');
    }

    final data = options.data as Map<String, dynamic>?;
    final amount = (data?['amount'] as num?)?.toDouble() ?? 0;
    final provider = data?['provider'] as String? ?? 'orange_money';

    if (amount <= 0) {
      return MockResponse.badRequest('Invalid amount');
    }

    if (amount > wallet.balanceUsdc) {
      return MockResponse.badRequest('Insufficient balance');
    }

    final fee = amount * 0.01; // 1% fee

    final withdrawal = WithdrawResponse(
      id: MockDataGenerator.uuid(),
      status: 'pending',
      amount: amount,
      fee: fee,
      provider: provider,
    );

    // Deduct from balance
    WalletMockState.updateBalance(userId, -amount, 0);

    WalletMockState.pendingWithdrawals[userId] ??= [];
    WalletMockState.pendingWithdrawals[userId]!.add(withdrawal);

    return MockResponse.created(withdrawal.toJson());
  }

  static Future<MockResponse> _handleGetDepositProviders(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'providers': [
        {
          'id': 'orange_money',
          'name': 'Orange Money',
          'logo': 'https://example.com/orange.png',
          'minAmount': 500,
          'maxAmount': 1000000,
          'fee': 0.0,
          'feeType': 'percentage',
          'countries': ['CI', 'SN', 'ML'],
        },
        {
          'id': 'mtn_momo',
          'name': 'MTN Mobile Money',
          'logo': 'https://example.com/mtn.png',
          'minAmount': 500,
          'maxAmount': 500000,
          'fee': 0.0,
          'feeType': 'percentage',
          'countries': ['CI', 'GH'],
        },
        {
          'id': 'wave',
          'name': 'Wave',
          'logo': 'https://example.com/wave.png',
          'minAmount': 100,
          'maxAmount': 2000000,
          'fee': 0.0,
          'feeType': 'percentage',
          'countries': ['CI', 'SN'],
        },
      ],
    });
  }

  static Future<MockResponse> _handleGetWithdrawProviders(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'providers': [
        {
          'id': 'orange_money',
          'name': 'Orange Money',
          'logo': 'https://example.com/orange.png',
          'minAmount': 1000,
          'maxAmount': 500000,
          'fee': 1.0,
          'feeType': 'percentage',
          'countries': ['CI', 'SN', 'ML'],
        },
        {
          'id': 'mtn_momo',
          'name': 'MTN Mobile Money',
          'logo': 'https://example.com/mtn.png',
          'minAmount': 1000,
          'maxAmount': 300000,
          'fee': 1.5,
          'feeType': 'percentage',
          'countries': ['CI', 'GH'],
        },
      ],
    });
  }

  static Future<MockResponse> _handleGetLimits(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    // Mock KYC tier (can be stored in user state in the future)
    // For now, return Tier 1 limits with some usage
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final hoursUntilReset = midnight.difference(now).inHours;
    final minutesUntilReset = midnight.difference(now).inMinutes % 60;

    return MockResponse.success({
      'dailyLimit': 1000.0,
      'monthlyLimit': 10000.0,
      'singleTransactionLimit': 500.0,
      'withdrawalLimit': 800.0,
      'dailyUsed': 350.0,
      'monthlyUsed': 2400.0,
      'kycTier': 1,
      'tierName': 'Tier 1',
      'nextTierName': 'Tier 2',
      'nextTierDailyLimit': 5000.0,
      'nextTierMonthlyLimit': 50000.0,
      'resetTime': midnight.toIso8601String(),
      'hoursUntilReset': hoursUntilReset,
      'minutesUntilReset': minutesUntilReset,
    });
  }
}
