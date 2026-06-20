/// Wallet Mock Implementation
///
/// Mock handlers for wallet endpoints.
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_data_generator.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_mock.dart';
import 'package:usdc_wallet/mocks/services/wallet/wallet_contract.dart';

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
  static WalletResponse createWallet(
    String userId, {
    String network = 'polygon',
  }) {
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
  static void updateBalance(
    String userId,
    double usdcDelta,
    double localDelta,
  ) {
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

    // POST /wallet/create
    interceptor.register(
      method: 'POST',
      path: '/wallet/create',
      handler: _handleCreateWallet,
    );

    // GET /wallet/exchange-rate
    interceptor.register(
      method: 'GET',
      path: '/wallet/exchange-rate',
      handler: _handleGetRate,
    );

    // POST /wallet/deposit
    interceptor.register(
      method: 'POST',
      path: '/wallet/deposit',
      handler: _handleDeposit,
    );

    // POST /wallet/transfer/external
    interceptor.register(
      method: 'POST',
      path: '/wallet/transfer/external',
      handler: _handleWithdraw,
    );

    // POST /wallet/cash-out/mobile-money
    interceptor.register(
      method: 'POST',
      path: '/wallet/cash-out/mobile-money',
      handler: _handleWithdraw,
    );

    // POST /wallet/cash-out/mobile-money/quote
    interceptor.register(
      method: 'POST',
      path: '/wallet/cash-out/mobile-money/quote',
      handler: _handleWithdrawQuote,
    );

    // GET /wallet/deposit/channels
    interceptor.register(
      method: 'GET',
      path: '/wallet/deposit/channels',
      handler: _handleGetDepositChannels,
    );

    // GET /wallet/deposit/providers
    interceptor.register(
      method: 'GET',
      path: '/wallet/deposit/providers',
      handler: _handleGetDepositProviders,
    );

    // GET /wallet/cash-out/mobile-money/options
    interceptor.register(
      method: 'GET',
      path: '/wallet/cash-out/mobile-money/options',
      handler: _handleGetWithdrawOptions,
    );

    // GET /user/limits
    interceptor.register(
      method: 'GET',
      path: '/user/limits',
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

  static Future<MockResponse> _handleCreateWallet(
    RequestOptions options,
  ) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    // Check if wallet already exists
    final existingWallet = WalletMockState.getWallet(userId);
    if (existingWallet != null && options.path == '/wallet/create') {
      return MockResponse.success(existingWallet.toJson());
    }
    if (existingWallet != null) {
      return MockResponse.badRequest('Wallet already exists');
    }

    final data = options.data as Map<String, dynamic>?;
    final network = data?['network'] as String? ?? 'polygon';

    final wallet = WalletMockState.createWallet(userId, network: network);
    return MockResponse.created(wallet.toJson());
  }

  static Future<MockResponse> _handleGetRate(RequestOptions options) async {
    final query = options.queryParameters;
    final sourceCurrency =
        query['sourceCurrency'] as String? ??
        query['fromCurrency'] as String? ??
        'XOF';
    final targetCurrency =
        query['targetCurrency'] as String? ??
        query['toCurrency'] as String? ??
        'USD';
    final sourceAmount =
        double.tryParse(query['amount']?.toString() ?? '') ?? 10000;
    const xofPerUsd = 655.957;
    final isXofToUsd = sourceCurrency == 'XOF' && targetCurrency == 'USD';
    final targetAmount = isXofToUsd
        ? sourceAmount / xofPerUsd
        : sourceAmount * xofPerUsd;
    final canonicalRate = isXofToUsd ? 1 / xofPerUsd : xofPerUsd;

    if (options.path.endsWith('/exchange-rate')) {
      return MockResponse.success({
        'fromCurrency': sourceCurrency,
        'toCurrency': targetCurrency,
        'rate': xofPerUsd,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    return MockResponse.success({
      'sourceCurrency': sourceCurrency,
      'targetCurrency': targetCurrency,
      'rate': canonicalRate,
      'sourceAmount': sourceAmount,
      'targetAmount': targetAmount,
      'fee': 0,
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 5))
          .toIso8601String(),
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
    final rawAmount = (data?['amount'] as num?)?.toDouble() ?? 0;
    final amount = options.path == '/wallet/cash-out/mobile-money'
        ? rawAmount / 100
        : rawAmount;
    final provider =
        (data?['providerCode'] as String?) ??
        (data?['provider'] as String?) ??
        'OMCI';
    // phoneNumber from data is stored in the deposit metadata on real backend

    if (amount <= 0) {
      return MockResponse.badRequest('Invalid amount');
    }

    final deposit = DepositResponse(
      id: MockDataGenerator.uuid(),
      status: 'pending',
      amount: amount,
      provider: provider,
      instructions:
          'Dial *144*1*${MockDataGenerator.integer(min: 100000, max: 999999)}# to complete the deposit',
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
    final rawAmount = (data?['amount'] as num?)?.toDouble() ?? 0;
    final amount = options.path == '/wallet/cash-out/mobile-money'
        ? rawAmount / 100
        : rawAmount;
    final provider =
        (data?['providerCode'] as String?) ??
        (data?['provider'] as String?) ??
        'OMCI';

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

    if (options.path == '/wallet/cash-out/mobile-money') {
      return MockResponse.created({
        'id': withdrawal.id,
        'status': withdrawal.status,
        'amount': rawAmount,
        'fiatAmount': (rawAmount * 600).round(),
        'currency': data?['currency'] as String? ?? 'XOF',
        'providerCode': provider,
        'phoneNumber': data?['phoneNumber'] as String? ?? '+2250700000000',
        'providerReference': MockDataGenerator.transactionRef(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    return MockResponse.success({
      'transactionId': withdrawal.id,
      'toAddress': data?['toAddress'] as String? ?? data?['destinationAddress'],
      'amount': amount,
      'amountDecimal': amount.toStringAsFixed(2),
      'currency': data?['currency'] as String? ?? 'USDC',
      'fee': fee,
      'feeDecimal': fee.toStringAsFixed(2),
      'status': withdrawal.status,
      'network': data?['network'] as String? ?? 'polygon',
    });
  }

  static Future<MockResponse> _handleWithdrawQuote(
    RequestOptions options,
  ) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final data = options.data as Map<String, dynamic>?;
    final amountCents = (data?['amount'] as num?)?.round() ?? 0;
    final provider = data?['providerCode'] as String? ?? 'OMCI';
    if (amountCents <= 0) {
      return MockResponse.badRequest('Invalid amount');
    }

    final feeCents = (amountCents * 0.01).ceil();
    return MockResponse.success({
      'amount': amountCents,
      'fee': feeCents,
      'totalAmount': amountCents + feeCents,
      'fiatAmount': ((amountCents / 100) * 600).round(),
      'currency': data?['currency'] as String? ?? 'XOF',
      'providerCode': provider,
      'exchangeRate': 600,
      'commercialTermId': 'mock_mobile_money_withdrawal',
      'commercialFeeSource': 'local_fallback',
      'commercialRiskTier': 'medium',
      'commercialFeeBearer': 'sender',
    });
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

  static Future<MockResponse> _handleGetDepositChannels(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'channels': [
        {
          'id': 'OMCI',
          'name': 'Orange Money',
          'type': 'mobile_money',
          'provider': 'orange',
          'country': 'CI',
          'minAmount': 500,
          'maxAmount': 1000000,
          'fee': 0.0,
          'feeType': 'percentage',
          'currency': 'XOF',
        },
        {
          'id': 'MTNCI',
          'name': 'MTN Mobile Money',
          'type': 'mobile_money',
          'provider': 'mtn',
          'country': 'CI',
          'minAmount': 500,
          'maxAmount': 500000,
          'fee': 0.0,
          'feeType': 'percentage',
          'currency': 'XOF',
        },
        {
          'id': 'WAVECI',
          'name': 'Wave',
          'type': 'mobile_money',
          'provider': 'wave',
          'country': 'CI',
          'minAmount': 100,
          'maxAmount': 2000000,
          'fee': 0.0,
          'feeType': 'percentage',
          'currency': 'XOF',
        },
      ],
    });
  }

  static Future<MockResponse> _handleGetWithdrawOptions(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'country': 'CI',
      'currency': 'USDC',
      'status': 'available',
      'reason': null,
      'retryable': false,
      'supportReviewRequired': false,
      'options': [
        {
          'id': 'orange_money_ci',
          'name': 'Orange Money',
          'type': 'mobile_money',
          'providerCode': 'OMCI',
          'country': 'CI',
          'currency': 'USDC',
          'payoutCurrency': 'XOF',
          'minAmount': 1000,
          'maxAmount': 500000,
          'fee': 1.0,
          'feeType': 'percentage',
          'enabled': true,
        },
        {
          'id': 'mtn_momo_ci',
          'name': 'MTN Mobile Money',
          'type': 'mobile_money',
          'providerCode': 'MTNCI',
          'country': 'CI',
          'currency': 'USDC',
          'payoutCurrency': 'XOF',
          'minAmount': 1000,
          'maxAmount': 300000,
          'fee': 1.5,
          'feeType': 'percentage',
          'enabled': true,
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
