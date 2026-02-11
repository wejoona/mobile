import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// External Transfer Mock Service
class ExternalTransferMock {
  static void register(MockInterceptor interceptor) {
    // POST /api/v1/wallet/transfer/external - Execute external transfer
    interceptor.register(
      method: 'POST',
      path: '/api/v1/wallet/transfer/external',
      handler: _handleExternalTransfer,
    );

    // GET /api/v1/wallet/transfer/external/estimate-fee - Estimate fee (optional)
    interceptor.register(
      method: 'GET',
      path: '/api/v1/wallet/transfer/external/estimate-fee',
      handler: _handleEstimateFee,
    );
  }

  /// Handle external transfer
  static Future<MockResponse> _handleExternalTransfer(RequestOptions options) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    final data = options.data as Map<String, dynamic>;
    final address = data['address'] as String;
    final amount = data['amount'] as num;
    final network = data['network'] as String? ?? 'polygon';

    // Generate mock transaction hash
    final txHash = _generateMockTxHash();

    return MockResponse.success({
      'transactionId': 'ext_${DateTime.now().millisecondsSinceEpoch}',
      'id': 'ext_${DateTime.now().millisecondsSinceEpoch}',
      'txHash': txHash,
      'status': 'pending',
      'fee': network == 'polygon' ? 0.01 : 2.5,
      'network': network,
      'amount': amount,
      'recipientAddress': address,
      'timestamp': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Handle estimate fee
  static Future<MockResponse> _handleEstimateFee(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final network = options.queryParameters['network'] as String? ?? 'polygon';
    final fee = network == 'polygon' ? 0.01 : 2.5;

    return MockResponse.success({
      'network': network,
      'estimatedFee': fee,
      'estimatedTime': network == 'polygon' ? '1-2 minutes' : '5-10 minutes',
    });
  }

  static String _generateMockTxHash() {
    // Generate a realistic-looking transaction hash (0x + 64 hex chars)
    const chars = '0123456789abcdef';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = StringBuffer('0x');

    for (var i = 0; i < 64; i++) {
      hash.write(chars[int.parse(random[i % random.length]) % chars.length]);
    }

    return hash.toString();
  }
}
