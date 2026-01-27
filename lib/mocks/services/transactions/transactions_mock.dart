/// Transactions Mock Implementation
///
/// Mock handlers for transaction endpoints.
library;

import 'package:dio/dio.dart';
import '../../base/api_contract.dart';
import '../../base/mock_data_generator.dart';
import '../../base/mock_interceptor.dart';
import '../auth/auth_mock.dart';
import '../wallet/wallet_mock.dart';
import 'transactions_contract.dart';

/// Transactions mock state
class TransactionsMockState {
  static final Map<String, List<TransactionResponse>> userTransactions = {};

  static void reset() {
    userTransactions.clear();
  }

  /// Get transactions for user
  static List<TransactionResponse> getTransactions(String userId) {
    if (!userTransactions.containsKey(userId)) {
      // Generate some mock transactions
      userTransactions[userId] = _generateMockTransactions(userId);
    }
    return userTransactions[userId]!;
  }

  /// Add a transaction
  static TransactionResponse addTransaction(
    String userId, {
    required String type,
    required double amount,
    String status = 'completed',
    double? fee,
    String? recipient,
    String? sender,
    String? note,
  }) {
    final tx = TransactionResponse(
      id: MockDataGenerator.uuid(),
      userId: userId,
      type: type,
      status: status,
      amount: amount,
      fee: fee,
      currency: 'USDC',
      recipient: recipient,
      sender: sender,
      note: note,
      reference: MockDataGenerator.transactionRef(),
      createdAt: DateTime.now(),
      completedAt: status == 'completed' ? DateTime.now() : null,
    );

    userTransactions[userId] ??= [];
    userTransactions[userId]!.insert(0, tx);
    return tx;
  }

  /// Generate mock transactions for a user
  static List<TransactionResponse> _generateMockTransactions(String userId) {
    final types = ['deposit', 'withdrawal', 'transfer_in', 'transfer_out'];
    final statuses = ['completed', 'completed', 'completed', 'pending', 'failed'];

    return List.generate(25, (index) {
      final type = MockDataGenerator.pick(types);
      final status = MockDataGenerator.pick(statuses);
      final isIncoming = type == 'deposit' || type == 'transfer_in';

      return TransactionResponse(
        id: MockDataGenerator.uuid(),
        userId: userId,
        type: type,
        status: status,
        amount: MockDataGenerator.roundedAmount(min: 5, max: 500),
        fee: type == 'withdrawal' ? MockDataGenerator.roundedAmount(min: 0.5, max: 5) : null,
        currency: 'USDC',
        recipient: isIncoming ? null : MockDataGenerator.phoneNumber(),
        sender: isIncoming ? MockDataGenerator.phoneNumber() : null,
        note: MockDataGenerator.boolean() ? MockDataGenerator.transactionDescription() : null,
        reference: MockDataGenerator.transactionRef(),
        createdAt: MockDataGenerator.pastDate(maxDaysAgo: 60),
        completedAt: status == 'completed'
            ? MockDataGenerator.pastDate(maxDaysAgo: 60)
            : null,
      );
    })
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

/// Transactions mock handlers
class TransactionsMock {
  /// Register all transaction mock handlers
  static void register(MockInterceptor interceptor) {
    // GET /transactions
    interceptor.register(
      method: 'GET',
      path: '/transactions',
      handler: _handleGetTransactions,
    );

    // GET /transactions/:id
    interceptor.register(
      method: 'GET',
      path: '/transactions/:id',
      handler: _handleGetTransaction,
    );

    // POST /transactions/transfer
    interceptor.register(
      method: 'POST',
      path: '/transactions/transfer',
      handler: _handleTransfer,
    );

    // POST /transactions/transfer/external
    interceptor.register(
      method: 'POST',
      path: '/transactions/transfer/external',
      handler: _handleExternalTransfer,
    );

    // GET /transactions/export
    interceptor.register(
      method: 'GET',
      path: '/transactions/export',
      handler: _handleExport,
    );
  }

  static Future<MockResponse> _handleGetTransactions(
    RequestOptions options,
  ) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final page = int.tryParse(options.queryParameters['page']?.toString() ?? '1') ?? 1;
    final limit = int.tryParse(options.queryParameters['limit']?.toString() ?? '20') ?? 20;
    final type = options.queryParameters['type'] as String?;
    final status = options.queryParameters['status'] as String?;

    var transactions = TransactionsMockState.getTransactions(userId);

    // Apply filters
    if (type != null) {
      transactions = transactions.where((t) => t.type == type).toList();
    }
    if (status != null) {
      transactions = transactions.where((t) => t.status == status).toList();
    }

    // Pagination
    final total = transactions.length;
    final start = (page - 1) * limit;
    final end = start + limit;
    final paged = transactions.skip(start).take(limit).toList();

    return MockResponse.success(TransactionListResponse(
      transactions: paged,
      total: total,
      page: page,
      limit: limit,
      hasMore: end < total,
    ).toJson());
  }

  static Future<MockResponse> _handleGetTransaction(
    RequestOptions options,
  ) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    // Extract ID from path
    final pathParts = options.path.split('/');
    final txId = pathParts.last;

    final transactions = TransactionsMockState.getTransactions(userId);
    final tx = transactions.firstWhere(
      (t) => t.id == txId,
      orElse: () => throw Exception('Not found'),
    );

    return MockResponse.success(tx.toJson());
  }

  static Future<MockResponse> _handleTransfer(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final wallet = WalletMockState.getWallet(userId);
    if (wallet == null) {
      return MockResponse.notFound('Wallet not found');
    }

    final data = options.data as Map<String, dynamic>?;
    final recipientPhone = data?['recipientPhone'] as String?;
    final amount = (data?['amount'] as num?)?.toDouble() ?? 0;
    final note = data?['note'] as String?;

    if (recipientPhone == null || recipientPhone.isEmpty) {
      return MockResponse.badRequest('Recipient phone is required');
    }

    if (amount <= 0) {
      return MockResponse.badRequest('Invalid amount');
    }

    if (amount > wallet.balanceUsdc) {
      return MockResponse.badRequest('Insufficient balance');
    }

    // Deduct from sender
    WalletMockState.updateBalance(userId, -amount, 0);

    // Create transaction
    final tx = TransactionsMockState.addTransaction(
      userId,
      type: 'transfer_out',
      amount: amount,
      recipient: recipientPhone,
      note: note,
    );

    return MockResponse.created(tx.toJson());
  }

  static Future<MockResponse> _handleExternalTransfer(
    RequestOptions options,
  ) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final wallet = WalletMockState.getWallet(userId);
    if (wallet == null) {
      return MockResponse.notFound('Wallet not found');
    }

    final data = options.data as Map<String, dynamic>?;
    final walletAddress = data?['walletAddress'] as String?;
    final amount = (data?['amount'] as num?)?.toDouble() ?? 0;
    final note = data?['note'] as String?;

    if (walletAddress == null || !walletAddress.startsWith('0x')) {
      return MockResponse.badRequest('Invalid wallet address');
    }

    if (amount <= 0) {
      return MockResponse.badRequest('Invalid amount');
    }

    final networkFee = 0.5; // Mock network fee
    final totalCost = amount + networkFee;

    if (totalCost > wallet.balanceUsdc) {
      return MockResponse.badRequest('Insufficient balance (including network fee)');
    }

    // Deduct from sender (amount + fee)
    WalletMockState.updateBalance(userId, -totalCost, 0);

    // Create transaction
    final tx = TransactionsMockState.addTransaction(
      userId,
      type: 'transfer_out',
      amount: amount,
      fee: networkFee,
      recipient: walletAddress,
      note: note,
      status: 'pending', // External transfers start as pending
    );

    return MockResponse.created(tx.toJson());
  }

  static Future<MockResponse> _handleExport(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final format = options.queryParameters['format'] as String? ?? 'csv';

    // In a real implementation, this would generate a file
    return MockResponse.success({
      'downloadUrl': 'https://api.joonapay.com/transactions/export/${MockDataGenerator.uuid()}.$format',
      'expiresIn': 3600,
    });
  }
}
