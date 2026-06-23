/// Transfers Mock Implementation
///
/// Mock handlers for transfer endpoints.
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_data_generator.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_mock.dart';
import 'package:usdc_wallet/mocks/services/transactions/transactions_mock.dart';
import 'package:usdc_wallet/mocks/services/wallet/wallet_mock.dart';

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
}

class TransfersMock {
  static void register(MockInterceptor interceptor) {
    // POST /wallet/transfer/internal - Internal transfer through the secured wallet route
    interceptor.register(
      method: 'POST',
      path: '/wallet/transfer/internal',
      handler: _handleInternalTransfer,
    );

    // POST /wallet/transfer/external - External transfer through the secured wallet route
    interceptor.register(
      method: 'POST',
      path: '/wallet/transfer/external',
      handler: _handleExternalTransfer,
    );
  }

  /// Check PIN verification header
  /// Returns error response if PIN token is missing or invalid
  static MockResponse? _checkPinVerification(RequestOptions options) {
    // Check if user is authenticated first
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized('Not authenticated');
    }

    // Get PIN token from header
    final pinToken =
        options.headers['X-Pin-Token'] ?? options.headers['x-pin-token'];

    if (pinToken == null || (pinToken is String && pinToken.isEmpty)) {
      return MockResponse(
        statusCode: 400,
        errorMessage: 'PIN verification required for this operation',
        data: {
          'message': 'PIN verification required for this operation',
          'code': 'PIN_REQUIRED',
          'hint':
              'Call POST /user/pin/verify first, then include the returned token in X-Pin-Token header',
        },
      );
    }

    // Validate token format (should be a hex string from mock PIN verify)
    final tokenStr = pinToken.toString();
    if (tokenStr.isEmpty ||
        (!tokenStr.startsWith('mock_pin_token_') && tokenStr.length < 16)) {
      return MockResponse(
        statusCode: 403,
        errorMessage: 'Invalid or expired PIN verification',
        data: {
          'message': 'Invalid or expired PIN verification',
          'code': 'PIN_INVALID',
          'hint': 'PIN verification has expired. Please verify your PIN again.',
        },
      );
    }

    // PIN verification passed
    return null;
  }

  /// Handle internal transfer
  static Future<MockResponse> _handleInternalTransfer(
    RequestOptions options,
  ) async {
    // Check PIN verification first
    final pinCheckResult = _checkPinVerification(options);
    if (pinCheckResult != null) {
      return pinCheckResult;
    }

    final data = options.data as Map<String, dynamic>;
    final userId = AuthMockState.currentUserId!;
    final recipientPhone =
        (data['toPhone'] ?? data['recipientPhone']) as String? ?? '';
    final amount = (data['amount'] as num).toDouble();
    final note = data['note'] as String?;

    // Validate
    if (recipientPhone.isEmpty) {
      return MockResponse.badRequest('Recipient phone is required');
    }

    if (amount <= 0) {
      return MockResponse.badRequest('Amount must be greater than 0');
    }

    // Create transfer
    final transfer = TransfersMockState.createTransfer(
      type: 'internal',
      recipientPhone: recipientPhone,
      amount: amount,
      note: note,
    );

    WalletMockState.updateBalance(userId, -amount, -(amount * 655.957));
    TransactionsMockState.addTransaction(
      userId,
      type: 'transfer_internal',
      amount: -amount,
      recipient: recipientPhone,
      note: note,
    );

    return MockResponse.success(transfer);
  }

  /// Handle external transfer
  static Future<MockResponse> _handleExternalTransfer(
    RequestOptions options,
  ) async {
    // Check PIN verification first
    final pinCheckResult = _checkPinVerification(options);
    if (pinCheckResult != null) {
      return pinCheckResult;
    }

    final data = options.data as Map<String, dynamic>;
    final userId = AuthMockState.currentUserId!;
    final recipientAddress =
        (data['toAddress'] ?? data['recipientAddress']) as String? ?? '';
    final amount = (data['amount'] as num).toDouble();
    final network =
        (data['network'] as String?) ?? (data['blockchain'] as String?);
    final note = data['note'] as String?;

    // Validate
    if (recipientAddress.isEmpty) {
      return MockResponse.badRequest('Recipient address is required');
    }

    if (amount <= 0) {
      return MockResponse.badRequest('Amount must be greater than 0');
    }

    // Create transfer
    final transfer = {
      'id': MockDataGenerator.uuid(),
      'reference': MockDataGenerator.transactionRef(),
      'type': 'external',
      'status': 'pending',
      'amount': amount,
      'fee': amount * 0.005, // 0.5% fee
      'currency': 'USDC',
      'recipientAddress': recipientAddress,
      'network': network ?? 'polygon',
      'blockchain': network ?? 'polygon',
      'note': note,
      'txHash': '0x${MockDataGenerator.uuid().replaceAll('-', '')}',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    TransfersMockState.transfers.add(transfer);
    WalletMockState.updateBalance(userId, -(amount + (amount * 0.005)), 0);
    TransactionsMockState.addTransaction(
      userId,
      type: 'transfer_external',
      amount: amount,
      fee: amount * 0.005,
      recipient: recipientAddress,
      note: note,
      status: 'pending',
    );

    return MockResponse.success(transfer);
  }
}
