/// Transfers Mock Implementation
///
/// Mock handlers for transfer endpoints.
library;

import 'package:dio/dio.dart';
import '../../base/api_contract.dart';
import '../../base/mock_data_generator.dart';
import '../../base/mock_interceptor.dart';
import '../auth/auth_mock.dart';

/// Transfers mock state
class TransfersMockState {
  static final List<Map<String, dynamic>> transfers = [];

  static void reset() {
    transfers.clear();
  }

  /// Add a transfer
  static Map<String, dynamic> createTransfer({
    required String type,
    required String recipientPhone,
    required double amount,
    String? note,
  }) {
    final transfer = {
      'id': MockDataGenerator.uuid(),
      'reference': MockDataGenerator.transactionRef(),
      'type': type,
      'status': 'completed',
      'amount': amount,
      'fee': 0.0,
      'currency': 'USDC',
      'recipientPhone': recipientPhone,
      'note': note,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    transfers.add(transfer);
    return transfer;
  }

  /// Get recent transfers
  static List<Map<String, dynamic>> getRecentTransfers({
    int limit = 10,
    String? type,
  }) {
    var filtered = transfers;
    if (type != null) {
      filtered = transfers.where((t) => t['type'] == type).toList();
    }
    return filtered.take(limit).toList();
  }
}

class TransfersMock {
  static void register(MockInterceptor interceptor) {
    // POST /transfers/internal - Internal transfer
    interceptor.register(
      method: 'POST',
      path: '/transfers/internal',
      handler: _handleInternalTransfer,
    );

    // POST /transfers/external - External transfer
    interceptor.register(
      method: 'POST',
      path: '/transfers/external',
      handler: _handleExternalTransfer,
    );

    // GET /transfers - Get transfers
    interceptor.register(
      method: 'GET',
      path: r'/transfers$',
      handler: _handleGetTransfers,
    );

    // GET /transfers/:id - Get transfer by ID
    interceptor.register(
      method: 'GET',
      path: r'/transfers/[\w-]+',
      handler: _handleGetTransferById,
    );
  }

  /// Handle internal transfer
  static Future<MockResponse> _handleInternalTransfer(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>;
    final recipientPhone = data['recipientPhone'] as String;
    final amount = (data['amount'] as num).toDouble();
    final note = data['note'] as String?;

    // Validate
    if (recipientPhone.isEmpty) {
      return MockResponse.badRequest('Recipient phone is required');
    }

    if (amount <= 0) {
      return MockResponse.badRequest('Amount must be greater than 0');
    }

    // Check if user is authenticated
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized('Not authenticated');
    }

    // Simulate insufficient balance check (optional)
    // For now, always succeed

    // Create transfer
    final transfer = TransfersMockState.createTransfer(
      type: 'internal',
      recipientPhone: recipientPhone,
      amount: amount,
      note: note,
    );

    return MockResponse.success(transfer);
  }

  /// Handle external transfer
  static Future<MockResponse> _handleExternalTransfer(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>;
    final recipientAddress = data['recipientAddress'] as String;
    final amount = (data['amount'] as num).toDouble();
    final blockchain = data['blockchain'] as String?;
    final note = data['note'] as String?;

    // Validate
    if (recipientAddress.isEmpty) {
      return MockResponse.badRequest('Recipient address is required');
    }

    if (amount <= 0) {
      return MockResponse.badRequest('Amount must be greater than 0');
    }

    // Check if user is authenticated
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized('Not authenticated');
    }

    // Create transfer
    final transfer = {
      'id': MockDataGenerator.uuid(),
      'reference': MockDataGenerator.transactionRef(),
      'type': 'external',
      'status': 'pending',
      'amount': amount,
      'fee': amount * 0.001, // 0.1% fee
      'currency': 'USDC',
      'recipientAddress': recipientAddress,
      'blockchain': blockchain ?? 'polygon',
      'note': note,
      'txHash': '0x${MockDataGenerator.uuid().replaceAll('-', '')}',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    TransfersMockState.transfers.add(transfer);

    return MockResponse.success(transfer);
  }

  /// Handle get transfers
  static Future<MockResponse> _handleGetTransfers(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized('Not authenticated');
    }

    final queryParams = options.queryParameters;
    final page = int.tryParse(queryParams['page']?.toString() ?? '1') ?? 1;
    final pageSize =
        int.tryParse(queryParams['pageSize']?.toString() ?? '20') ?? 20;
    final type = queryParams['type'] as String?;

    final transfers = TransfersMockState.getRecentTransfers(
      limit: pageSize,
      type: type,
    );

    return MockResponse.success({
      'items': transfers,
      'total': transfers.length,
      'page': page,
      'pageSize': pageSize,
      'totalPages': (transfers.length / pageSize).ceil(),
    });
  }

  /// Handle get transfer by ID
  static Future<MockResponse> _handleGetTransferById(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized('Not authenticated');
    }

    final id = options.path.split('/').last;
    final transfer = TransfersMockState.transfers.firstWhere(
      (t) => t['id'] == id,
      orElse: () => {},
    );

    if (transfer.isEmpty) {
      return MockResponse.notFound('Transfer not found');
    }

    return MockResponse.success(transfer);
  }
}
